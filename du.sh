#!/bin/sh
CONTAINERS="apache php phpcli adminer mysql56 selenium mailhog node"

echo "Creating services: ${CONTAINERS}"
docker-compose up -d ${CONTAINERS}
