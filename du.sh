#!/bin/sh
CONTAINERS="apache php phpcli adminer mysql56 selenium mailhog node"

if [ -z "$DOCKER_SHARED_PATH" ]; then
    DOCKER_SHARED_PATH=~/docker
    echo "Setting default shared path to $DOCKER_SHARED_PATH "
fi

export DOCKER_SHARED_PATH=$DOCKER_SHARED_PATH

echo "Creating services: ${CONTAINERS}"
docker-compose up -d ${CONTAINERS}
