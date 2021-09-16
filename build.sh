#!/bin/bash
set -e

DOCKER_RUN_IMAGE=michaelscz/nedi

sudo docker build \
    --build-arg http_proxy=${HTTP_PROXY} \
    --build-arg https_proxy=${HTTP_PROXY} \
    ./ -t "${DOCKER_RUN_IMAGE}" --no-cache=true
