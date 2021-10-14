# syntax = docker/dockerfile:experimental
FROM openjdk:jdk-buster AS build
LABEL maintainer="andrzej.pauli@gmail.com"

WORKDIR /build

#get all binaries and latest patch set
ADD https://download.oracle.com/otn_software/apex/apex-latest.zip .
ADD https://download.oracle.com/otn_software/java/ords/ords-latest.zip .
ADD p32598392_2110_Generic.zip .
ADD start.sh .

#unpack
RUN unzip apex-latest.zip && unzip -d ords ords-latest.zip && unzip p32598392_2110_Generic.zip && \
	cp -r apex/images/ ords/ && cp -rf 32598392/images ords



FROM openjdk:11.0-jre-slim-buster
ENV ORDS_HOME="/srv/ords" USER=nobody
COPY --from=build --chown="$USER":"$USER" /build/ords /build/start.sh $ORDS_HOME
WORKDIR $ORDS_HOME

USER "$USER"
EXPOSE 8080

ENTRYPOINT [ "/srv/ords/start.sh" ]
