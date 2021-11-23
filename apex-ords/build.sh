#!/bin/bash

DOCKER=/usr/bin/docker

DOCKER_BUILDKIT=1 $DOCKER build \
	--progress=auto \
	--build-arg DONT_INSTALL_PATCHSET="true" \
	--build-arg INSTALL_APEX="true" \
	-f Dockerfile \
	-t chaosengine/apex-ords .

