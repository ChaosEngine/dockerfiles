# syntax = docker/dockerfile:experimental
FROM eclipse-temurin:17-jdk-alpine AS build
LABEL maintainer="andrzej.pauli@gmail.com"
#flags for build stage with default values
ARG DONT_INSTALL_PATCHSET=true
ARG INSTALL_APEX=false
#downloadable bits
ARG APEX_ZIP=https://download.oracle.com/otn_software/apex/apex-latest.zip
ARG ORDS_ZIP=https://download.oracle.com/otn_software/java/ords/ords-latest.zip
ARG SQLCL_ZIP=https://download.oracle.com/otn_software/java/sqldeveloper/sqlcl-latest.zip
ARG EXPAND_IMAGES=false
WORKDIR /build

#get all binaries and latest patch set
ADD "$APEX_ZIP" .
ADD "$ORDS_ZIP" .
ADD "$SQLCL_ZIP" .
COPY start.sh *.patch p*.zip* .

#prerequisities
RUN apk add unzip;
#unpack regular ords zips
RUN unzip -q -d ords ords-*.zip
#depending on flags unpack apex, images
RUN if [ "$INSTALL_APEX" = "true" ] || [ "$EXPAND_IMAGES" = "true" ] ; then unzip -q apex*.zip && cp -r apex/images/ ords/; fi
#unpack and apply latest patch files
RUN	if [ "$DONT_INSTALL_PATCHSET" != "true" ] ; then unzip -q -d patch p*.zip && [ "$EXPAND_IMAGES" != "true" ] || cp -rf patch/*/images ords || echo "patch non existing"; \
	else rm -rf /build/p* || echo "patch non existing"; fi
#depending on flags unpack sqlcl for use
RUN if [ "$INSTALL_APEX" = "true" ] || [ "$DONT_INSTALL_PATCHSET" != "true" ] ; then unzip -q -d sqlcl sqlcl-latest.zip && rm -f sqlcl-latest.zip; \
	else rm -rf /build/sqlcl*; fi
#cleanup
RUN if [ "$INSTALL_APEX" != "true" ] ; then rm -rf /build/apex*; fi
RUN rm -rf /build/apex-latest.zip /build/apex/images /build/patch/*/images





FROM eclipse-temurin:17-jre
#flags for run stage with default values
ARG INSTALL_APEX=false
ARG DONT_INSTALL_PATCHSET=true
ARG HTTP_PORT=8080

#prerequisities only when installing apex
RUN if [ "$INSTALL_APEX" = "true" ] ; then apt-get update && apt-get install -y unzip libfreetype6 fontconfig; fi
#set env variables on runtime visible in all login sessions
ENV USER=nobody HOME=/nonexistent INSTALL_APEX=$INSTALL_APEX DONT_INSTALL_PATCHSET=$DONT_INSTALL_PATCHSET
#ensure home dir for nobody user exists and with proper rights
RUN mkdir -p "$HOME" && chown nobody:nogroup "$HOME";
#copy required ords bits
COPY --from=build --chown="$USER":"$USER" /build/ords /build/start.sh /srv/ords/
#conditionally copy files only if they exists in build stage
COPY --from=build --chown="$USER":"$USER" /build/apex* /srv/apex
COPY --from=build --chown="$USER":"$USER" /build/sqlcl* /srv
COPY --from=build --chown="$USER":"$USER" /build/patch* /srv/patch
#setup final runtime workdir
WORKDIR /srv/ords
#change to runtime user and export config, logs env variables
USER "$USER"
ENV ORDS_CONFIG="$HOME/config" ORDS_LOGS="$HOME/logs"
#expose http port
EXPOSE $HTTP_PORT


ENTRYPOINT [ "/srv/ords/start.sh" ]
