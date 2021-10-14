#!/bin/bash

DOCKER=/usr/bin/docker

DOCKER_BUILDKIT=1 $DOCKER build \
   --progress=auto \
    -f Dockerfile \
    -t chaosengine/apex-ords .

