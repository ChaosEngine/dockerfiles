#!/bin/bash

function gracefulshutdown {
	echo "Caught SIGTERM signal!"
	kill -TERM "$child_pid" 2>/dev/null
}
#param $1 - option key
#param $2 - option value
function setOrdsGlobalOption {
	local file="$ORDS_CONFIG/global/settings.xml"
	grep -i "$1" $file && return;

	sed -i '/<\/properties>/i\'"<entry key=\"$1\">$2</entry>" $file
}
#param $1 - option key
#param $2 - option value
#param $3 - DB pool name
function setOrdsPoolOption {
	local file="$ORDS_CONFIG/databases/${3:-default}/pool.xml"
	grep -i "$1" $file && return;

	sed -i '/<\/properties>/i\'"<entry key=\"$1\">$2</entry>" $file
}

trap gracefulshutdown SIGINT
trap gracefulshutdown SIGTERM
trap gracefulshutdown SIGKILL

#set vars based on passed env variables or assume reasonable defaults
ORDS_BIN=/srv/ords/bin/ords
DB_PORT=${DB_PORT:-1521}
SYS_USER=${SYS_USER:-sys}
APEX_TABLESPACE=${APEX_TABLESPACE:-SYSAUX}
TEMP_TABLESPACE=${TEMP_TABLESPACE:-TEMP}
PUBLIC_USER=${PUBLIC_USER:-ORDS_PUBLIC_USER}
ORDS_CONFIG=${ORDS_CONFIG:-${HOME}/config}
ORDS_LOGS=${ORDS_LOGS:-${HOME}/logs}
CONTEXT_PATH=${CONTEXT_PATH:-""}
WALLET_DATA=${WALLET_DATA:-""}


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
        p_change_password_on_first_use => 'N',
        p_developer_privs => 'ADMIN' );

    APEX_UTIL.set_security_group_id( null );
    COMMIT;
END;
/

@apex_rest_config.sql "${APEX_LISTENER_PASSWORD}" "${APEX_REST_PASSWORD}"

alter user APEX_PUBLIC_USER identified by "${PUBLIC_PASSWORD}" account unlock;
alter user APEX_REST_PUBLIC_USER identified by "${APEX_REST_PASSWORD}" account unlock;

exit;
EOF

    echo "******************************************************************************"
    echo "Install ORDS." `date`
    echo "******************************************************************************"
	#standalone using built in jetty: https://docs.oracle.com/en/database/oracle/oracle-rest-data-services/22.1/ordig/installing-and-configuring-oracle-rest-data-services.html
	#probably not needed, conflicts with below config settings one-by-one, also requires that ORDS_PUBLIC_USER is used and APEX_PUBLIC_USER is unlocked and log into it. Why? who knows!
	$ORDS_BIN --config "${ORDS_CONFIG}" install --admin-user "${SYS_USER}" --proxy-user --db-hostname "${DB_HOSTNAME}" --db-port "${DB_PORT}" --db-servicename "${DB_SERVICE}" --log-folder "${ORDS_LOGS}" --feature-sdw true --password-stdin <<EOF
${SYS_PASSWORD}
${PUBLIC_PASSWORD}
EOF

	popd

	pushd /srv/apex/utilities/
 	echo "******************************************************************************"
	echo "Resetting image prefix." `date`
	echo "******************************************************************************"
	/srv/sqlcl/bin/sql ${SYS_USER}/${SYS_PASSWORD}@//${DB_HOSTNAME}:${DB_PORT}/${DB_SERVICE} as sysdba @reset_image_prefix_core.sql "${CONTEXT_PATH}/i/"
	popd

else
	$ORDS_BIN config set db.hostname "${DB_HOSTNAME}"
	#setOrdsPoolOption db.hostname "${DB_HOSTNAME}"
	$ORDS_BIN config set db.port "${DB_PORT}"
	#setOrdsPoolOption db.port "${DB_PORT}"
	$ORDS_BIN config set db.servicename "${DB_SERVICE}"
	#setOrdsPoolOption db.servicename "${DB_SERVICE}"
	$ORDS_BIN config set feature.sdw true
	#setOrdsPoolOption feature.sdw true
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


#setup config entries using "ords config set" option
$ORDS_BIN config secret --password-stdin db.password <<EOF
${PUBLIC_PASSWORD}
EOF
#$ORDS_BIN config set restEnabledSql.active true
setOrdsPoolOption restEnabledSql.active true
setOrdsPoolOption jdbc.MaxLimit 25
#$ORDS_BIN config set database.api.enabled true
setOrdsGlobalOption database.api.enabled true
#$ORDS_BIN config set --global instance.api.enabled true
setOrdsGlobalOption instance.api.enabled true
#$ORDS_BIN config set db.username "${PUBLIC_USER}"
setOrdsPoolOption db.username "${PUBLIC_USER}"
#$ORDS_BIN config set debug.printDebugToScreen true
setOrdsGlobalOption debug.printDebugToScreen true
#$ORDS_BIN config set cache.metadata.enabled true
setOrdsGlobalOption cache.metadata.enabled true
#$ORDS_BIN config set cache.metadata.timeout 60s
setOrdsGlobalOption cache.metadata.timeout 600s


#if wallet_datta exists make a file out of it and set entries in config
if [ "$WALLET_DATA" != "" ]; then
	$ORDS_BIN config set db.wallet.zip.service "${DB_SERVICE}"
	$ORDS_BIN config set db.wallet.zip.path "${ORDS_CONFIG}/wallet.zip"
	echo "${WALLET_DATA}" | base64 -d - > "${ORDS_CONFIG}/wallet.zip"
fi

#start ords normally: https://docs.oracle.com/en/database/oracle/oracle-rest-data-services/22.1/ordig/deploying-and-monitoring-oracle-rest-data-services.html
#but with memory limitation
#export _JAVA_OPTIONS="-Xms384M -Xmx384M"
export _JAVA_OPTIONS="-Djava.util.logging.config.file=${ORDS_CONFIG}/logging.properties"
cat <<EOF >> "${ORDS_CONFIG}/logging.properties"
handlers=java.util.logging.ConsoleHandler

.level=WARNING

java.util.logging.ConsoleHandler.level=WARNING
EOF
#passs in images and context variables
echo "******************************************************************************"
echo "Serving ORDS" `date`
echo "******************************************************************************"

$ORDS_BIN --verbose --config "${ORDS_CONFIG}" serve --apex-images "images" --context-path "${CONTEXT_PATH}/ords" --apex-images-context-path "${CONTEXT_PATH}/i" &
#/opt/java/openjdk/bin/java -Doracle.dbtools.cmdline.home=/srv/ords -Duser.language=en -Duser.region=US -Dfile.encoding=UTF-8 -Djava.awt.headless=true -Dnashorn.args=--no-deprecation-warning -Doracle.dbtools.cmdline.ShellCommand=ords -Duser.timezone=UTC \
#	-Xdebug -Xrunjdwp:transport=dt_socket,address=62911,server=y,suspend=n \
#	-Dcom.sun.management.jmxremote= \
#	-Dcom.sun.management.jmxremote.port=1898 -Dcom.sun.management.jmxremote.rmi.port=1898 -Dcom.sun.management.jmxremote.ssl=false -Dcom.sun.management.jmxremote.authenticate=false \
#	-Djava.rmi.server.hostname=192.168.0.2 \
#	-jar /srv/ords/ords.war --verbose --config "${ORDS_CONFIG}" serve --apex-images images --context-path "${CONTEXT_PATH}/ords" --apex-images-context-path "${CONTEXT_PATH}/i" &

child_pid="$!"
wait "${child_pid}"
