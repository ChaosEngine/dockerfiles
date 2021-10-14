#!/bin/bash

DOCKER=/usr/bin/docker

#    --build-arg SOURCE_BRANCH="$(git rev-parse --abbrev-ref HEAD)" \
#    --build-arg SOURCE_COMMIT="$(git rev-parse HEAD)" $dockerfile_args \
DOCKER_BUILDKIT=1 $DOCKER build \
   --progress=auto \
    -f Dockerfile \
    -t "chaosengine/apex-ords" .

