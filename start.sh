#!/bin/bash

echo "Starting RavenDB..."
echo "Don't forget to set access permissions for for the chosen group"

docker compose -f /opt/raven-compose/docker-compose.yml down
HOSTNAME=$(hostname -i | awk '{print $1;}') \
LISTENING_HOSTNAME=$(hostname -i | awk '{print $1;}') \
docker compose \
    -f /opt/raven-compose/docker-compose.yml \
    --env-file /opt/raven-compose/.env \
    --env-file /opt/raven-compose/.env-secrets \
    up \
    -d
