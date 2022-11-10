#!/bin/bash

DOCKER=/usr/bin/docker

#Source of binary packages
# - latest from web
APEX_ZIP="https://download.oracle.com/otn_software/apex/apex-latest.zip"
ORDS_ZIP="https://download.oracle.com/otn_software/java/ords/ords-latest.zip"
# - downloaded locally with specific version (?)
#APEX_ZIP="apex*.zip"
#ORDS_ZIP="ords-*.zip"

DONT_INSTALL_PATCHSET="false"
INSTALL_APEX="true"
EXPAND_IMAGES="true"

DOCKER_BUILDKIT=1 $DOCKER build \
	--progress=auto \
	--build-arg DONT_INSTALL_PATCHSET="$DONT_INSTALL_PATCHSET" \
	--build-arg INSTALL_APEX="$INSTALL_APEX" \
	--build-arg APEX_ZIP="$APEX_ZIP" --build-arg ORDS_ZIP="$ORDS_ZIP" \
	--build-arg EXPAND_IMAGES="$EXPAND_IMAGES" \
	-f Dockerfile \
	-t chaosengine/apex-ords .

