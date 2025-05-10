#!/bin/bash

docker compose -f /opt/jellyfin-docker-compose/config/docker-compose.yml down
HOSTNAME=$(hostname -i | awk '{print $1;}') \
LISTENING_HOSTNAME=$(hostname -i | awk '{print $1;}') \
docker compose \
    -f /opt/jellyfin-docker-compose/config/docker-compose.yml \
    --env-file /opt/jellyfin-docker-compose/config/.env \
    up \
    -d
