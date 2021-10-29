# syntax = docker/dockerfile:experimental
FROM openjdk:jdk-buster AS build
LABEL maintainer="andrzej.pauli@gmail.com"

WORKDIR /build

#get all binaries and latest patch set
ADD https://download.oracle.com/otn_software/apex/apex-latest.zip .
ADD https://download.oracle.com/otn_software/java/ords/ords-latest.zip .
ADD https://download.oracle.com/otn_software/java/sqldeveloper/sqlcl-latest.zip .
COPY start.sh p*.zip* .

#unpack regular apex and ords zips
RUN unzip apex-latest.zip && unzip -d ords ords-latest.zip && cp -r apex/images/ ords/
#unpack and apply latest patch files
RUN	unzip -d patch p*.zip && cp -rf patch/*/images ords || echo "patch non existing";
RUN unzip -d sqlcl sqlcl-latest.zip && rm -f sqlcl-latest.zip


FROM openjdk:11.0-jre-slim-buster
#installer prerequisities
RUN apt-get update && apt-get install -y unzip libfreetype6 fontconfig
ENV USER=root
COPY --from=build --chown="$USER":"$USER" /build/ords /build/start.sh /srv/ords
COPY --from=build --chown="$USER":"$USER" /build/apex /srv/apex
COPY --from=build --chown="$USER":"$USER" /build/sqlcl /srv
WORKDIR /srv/ords

USER "$USER"
EXPOSE 8080

ENTRYPOINT [ "/srv/ords/start.sh" ]
