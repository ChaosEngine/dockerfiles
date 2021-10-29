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

    /srv/sqlcl/bin/sql SYS/${SYS_PASSWORD}@//${DB_HOSTNAME}:${DB_PORT}/${DB_SERVICE} as sysdba <<EOF
alter session set container = ${DB_SERVICE};
@apexins.sql SYSAUX SYSAUX TEMP /i/

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

#standalone using built in jetty: https://docs.oracle.com/en/database/oracle/oracle-rest-data-services/19.1/aelig/installing-REST-data-services.html#GUID-3DB75A67-3E66-48EF-87AC-6948DE796588
cat > params/ords_params.properties <<EOF
db.hostname=${DB_HOSTNAME}
db.port=${DB_PORT}
db.servicename=${DB_SERVICE}
#db.sid=
db.username=APEX_PUBLIC_USER
db.password=${APEX_PUBLIC_USER_PASSWORD}
migrate.apex.rest=false
plsql.gateway.add=true
rest.services.apex.add=true
rest.services.ords.add=true
schema.tablespace.default=${APEX_TABLESPACE}
schema.tablespace.temp=${TEMP_TABLESPACE}
standalone.mode=true
standalone.use.https=false
standalone.http.port=${HTTP_PORT}
standalone.static.images=images
user.apex.listener.password=${APEX_LISTENER_PASSWORD}
user.apex.restpublic.password=${APEX_REST_PASSWORD}
user.public.password=${PUBLIC_PASSWORD}
user.tablespace.default=${TEMP_TABLESPACE}
user.tablespace.temp=${TEMP_TABLESPACE}
sys.user=SYS
sys.password=${SYS_PASSWORD}
restEnabledSql.active=true
feature.sdw=true
database.api.enabled=true
EOF

java -jar ords.war configdir config

java -jar -Xms256m -Xmx256m -server ords.war &

child_pid="$!"
wait "${child_pid}"
