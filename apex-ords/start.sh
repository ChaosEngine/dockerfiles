#!/bin/bash

function gracefulshutdown {
	echo "Caught SIGTERM signal!"
	kill -TERM "$child_pid" 2>/dev/null
}

trap gracefulshutdown SIGINT
trap gracefulshutdown SIGTERM
trap gracefulshutdown SIGKILL

if [ "$INSTALL_APEX" == "true" ]; then
    echo "******************************************************************************"
    echo "Install APEX." `date`
    echo "******************************************************************************"
    pushd /srv/apex

    /srv/sqlcl/bin/sql ${SYS_USER}/${SYS_PASSWORD}@//${DB_HOSTNAME}:${DB_PORT}/${DB_SERVICE} as sysdba <<EOF
alter session set container = ${DB_SERVICE};
@apexins.sql ${APEX_TABLESPACE} ${APEX_TABLESPACE} ${TEMP_TABLESPACE} /i/

BEGIN
    APEX_UTIL.set_security_group_id( 10 );

    APEX_UTIL.create_user(
        p_user_name       => 'ADMIN',
        p_email_address   => 'admin@someemail.com',
        p_web_password    => '${APEX_PUBLIC_USER_PASSWORD}',
        p_developer_privs => 'ADMIN' );

    APEX_UTIL.set_security_group_id( null );
    COMMIT;
END;
/

@apex_rest_config.sql "${APEX_LISTENER_PASSWORD}" "${APEX_REST_PASSWORD}"
--@apex_epg_config.sql ${ORACLE_HOME}

alter user APEX_PUBLIC_USER identified by "${PUBLIC_PASSWORD}" account unlock;
alter user APEX_REST_PUBLIC_USER identified by "${APEX_REST_PASSWORD}" account unlock;

exit;
EOF
		popd
fi

if [ "$DONT_INSTALL_PATCHSET" != "true" ] ; then
	echo "******************************************************************************"
	echo "Install PATCHSET." `date`
	echo "******************************************************************************"
	pushd /srv/patch/*

    	/srv/sqlcl/bin/sql ${SYS_USER}/${SYS_PASSWORD}@//${DB_HOSTNAME}:${DB_PORT}/${DB_SERVICE} as sysdba <<EOF
alter session set container = ${DB_SERVICE};
@catpatch.sql
exit;
EOF
	popd
fi


#standalone using built in jetty: https://docs.oracle.com/en/database/oracle/oracle-rest-data-services/22.1/ordig/installing-and-configuring-oracle-rest-data-services.html
/srv/ords/bin/ords --config ./config install --admin-user "${SYS_USER}" --proxy-user --db-hostname "${DB_HOSTNAME}" --db-port "${DB_PORT}" --db-servicename "${DB_SERVICE}" --log-folder ./logs --feature-sdw true --password-stdin <<EOF
${SYS_PASSWORD}
${PUBLIC_PASSWORD}
EOF

#start ords normally: https://docs.oracle.com/en/database/oracle/oracle-rest-data-services/22.1/ordig/deploying-and-monitoring-oracle-rest-data-services.html
export _JAVA_OPTIONS="-Xms256M -Xmx256M"
/srv/ords/bin/ords --verbose --config /srv/ords/./config serve --apex-images "images" --context-path "${CONTEXT_PATH}/ords" --apex-images-context-path "${CONTEXT_PATH}/i" &

child_pid="$!"
wait "${child_pid}"
