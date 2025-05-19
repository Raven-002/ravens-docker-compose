#!/bin/bash

docker compose -f /opt/raven-compose/docker-compose.yml down "${@}"
