#!/bin/bash
set -e

DOCKER_RUN_IMAGE=michaelscz/nedi

sudo docker build ./ -t "${DOCKER_RUN_IMAGE}" --no-cache=true
