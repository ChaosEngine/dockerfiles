# syntax = docker/dockerfile:experimental
FROM openjdk:11.0-jdk-buster AS build
LABEL maintainer="andrzej.pauli@gmail.com"

ARG DONT_INSTALL_PATCHSET
ARG INSTALL_APEX
ARG APEX_ZIP
ARG ORDS_ZIP
WORKDIR /build

#get all binaries and latest patch set
ADD "$APEX_ZIP" .
ADD "$ORDS_ZIP" .
ADD https://download.oracle.com/otn_software/java/sqldeveloper/sqlcl-latest.zip .
COPY start.sh *.patch p*.zip* .

#unpack regular apex and ords zips
RUN unzip -q apex*.zip && unzip -q -d ords ords-*.zip && cp -r apex/images/ ords/
#unpack and apply latest patch files
RUN	if [ "$DONT_INSTALL_PATCHSET" != "true" ] ; then unzip -q -d patch p*.zip && cp -rf patch/*/images ords || echo "patch non existing"; \
	else rm -rf /build/p* || echo "patch non existing"; fi
RUN if [ "$INSTALL_APEX" = "true" ] || [ "$DONT_INSTALL_PATCHSET" != "true" ] ; then unzip -q -d sqlcl sqlcl-latest.zip && rm -f sqlcl-latest.zip; \
	else rm -rf /build/sqlcl*; fi
RUN if [ "$INSTALL_APEX" != "true" ] ; then rm -rf /build/apex*; fi


FROM openjdk:11.0-jre-slim-buster
#installer prerequisities
ARG INSTALL_APEX
ARG DONT_INSTALL_PATCHSET

RUN if [ "$INSTALL_APEX" = "true" ] ; then apt-get update && apt-get install -y unzip libfreetype6 fontconfig; fi
RUN mkdir -p /nonexistent && chown nobody:nogroup /nonexistent;

ENV INSTALL_APEX=${INSTALL_APEX:-false} DONT_INSTALL_PATCHSET=${DONT_INSTALL_PATCHSET:-false}
ENV USER=nobody

COPY --from=build --chown="$USER":"$USER" /build/ords /build/start.sh /srv/ords
COPY --from=build --chown="$USER":"$USER" /build/apex* /srv/apex
COPY --from=build --chown="$USER":"$USER" /build/sqlcl* /srv
COPY --from=build --chown="$USER":"$USER" /build/patch* /srv/patch

WORKDIR /srv/ords

USER "$USER"
EXPOSE 8080

ENTRYPOINT [ "/srv/ords/start.sh" ]
