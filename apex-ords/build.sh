#!/bin/bash

DOCKER=/usr/bin/docker

#Source of binary packages
# - latest from web
APEX_ZIP="https://download.oracle.com/otn_software/apex/apex-latest.zip"
ORDS_ZIP="https://download.oracle.com/otn_software/java/ords/ords-latest.zip"
# - downloaded locally with specific version (?)
#APEX_ZIP="apex*.zip"
#ORDS_ZIP="ords-*.zip"

DOCKER_BUILDKIT=1 $DOCKER build \
	--progress=auto \
	--build-arg DONT_INSTALL_PATCHSET="false" \
	--build-arg INSTALL_APEX="false" \
	--build-arg APEX_ZIP="$APEX_ZIP" --build-arg ORDS_ZIP="$ORDS_ZIP" \
	-f Dockerfile \
	-t chaosengine/apex-ords .

