#!/bin/bash

set -e

echo "Starting RavenDB..."
echo "Don't forget to set access permissions for for the chosen group"

cat /opt/raven-compose/base.env /opt/raven-compose/secrets.env > /opt/raven-compose/.env
HOSTNAME=$(hostname -i | awk '{print $1;}') \
LISTENING_HOSTNAME=$(hostname -i | awk '{print $1;}') \
echo "HOSTNAME=$HOSTNAME" >> /opt/raven-compose/.env
echo "LISTENING_HOSTNAME=$LISTENING_HOSTNAME" >> /opt/raven-compose/.env

docker compose -f /opt/raven-compose/docker-compose.yml down "${@}"
docker compose \
    -f /opt/raven-compose/docker-compose.yml \
    --env-file /opt/raven-compose/.env \
    up \
    -d \
    "${@}"
