# syntax = docker/dockerfile:experimental
FROM openjdk:jdk-buster AS build
LABEL maintainer="andrzej.pauli@gmail.com"
ARG DONT_INSTALL_PATCHSET
ARG INSTALL_APEX
WORKDIR /build

#get all binaries and latest patch set
ADD https://download.oracle.com/otn_software/apex/apex-latest.zip .
ADD https://download.oracle.com/otn_software/java/ords/ords-latest.zip .
ADD https://download.oracle.com/otn_software/java/sqldeveloper/sqlcl-latest.zip .
COPY start.sh p*.zip* .

#unpack regular apex and ords zips
RUN unzip -q apex-latest.zip && unzip -q -d ords ords-latest.zip && cp -r apex/images/ ords/
#unpack and apply latest patch files
RUN	if [ "$DONT_INSTALL_PATCHSET" != "true" ] ; then unzip -q -d patch p*.zip && cp -rf patch/*/images ords || echo "patch non existing"; fi
RUN if [ "$INSTALL_APEX" = "true" ] ; then unzip -q -d sqlcl sqlcl-latest.zip && rm -f sqlcl-latest.zip; fi
RUN if [ "$INSTALL_APEX" != "true" ] ; then rm -rf /build/sqlcl* /build/apex*; fi


FROM openjdk:11.0-jre-slim-buster
#installer prerequisities
ARG INSTALL_APEX
RUN if [ "$INSTALL_APEX" = "true" ] ; then apt-get update && apt-get install -y unzip libfreetype6 fontconfig; fi
RUN mkdir -p /nonexistent && chown nobody:nogroup /nonexistent;
ENV INSTALL_APEX=${INSTALL_APEX:-false}
ENV USER=nobody
COPY --from=build --chown="$USER":"$USER" /build/ords /build/start.sh /srv/ords
COPY --from=build --chown="$USER":"$USER" /build/apex* /srv/apex
COPY --from=build --chown="$USER":"$USER" /build/sqlcl* /srv
WORKDIR /srv/ords

USER "$USER"
EXPOSE 8080

ENTRYPOINT [ "/srv/ords/start.sh" ]
