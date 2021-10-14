#!/bin/bash

function gracefulshutdown {
	echo "Caught SIGTERM signal!"
	kill -TERM "$child_pid" 2>/dev/null
}

trap gracefulshutdown SIGINT
trap gracefulshutdown SIGTERM
trap gracefulshutdown SIGKILL


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
standalone.http.port=8080
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
