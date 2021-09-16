#!/bin/bash

sudo COMPOSE_HTTP_TIMEOUT=300 ./docker-compose down
sudo COMPOSE_HTTP_TIMEOUT=300 ./docker-compose up -d
