#!/bin/sh

#handle cmd flags
while getopts 'skr' flag; do
    case "${flag}" in
        s)
            echo "Stopping all containers:"
            docker stop $(docker ps -q)
            ;;
        k)
            echo "Killing all containers:"
            docker kill $(docker ps -q)
            ;;
        r)
            echo "Removing all containers:"
            docker rm $(docker ps -aq --filter "status=exited")
            ;;
    esac
done

#loads env vars into this process
ENV="./.env"
if [ -e $ENV ]; then
    . $ENV
fi

#set default for undefined vars
if [ -z "$DOCKER_CONTAINERS" ]; then
    DOCKER_CONTAINERS="apache php phpcli adminer mysql node"
    echo "Setting DOCKER_CONTAINERS to $DOCKER_CONTAINERS"
fi

if [ -z "$DOCKER_SHARED_PATH" ]; then
    DOCKER_SHARED_PATH=~/docker
    echo "Setting DOCKER_SHARED_PATH to $DOCKER_SHARED_PATH"
fi

if [ -z "$DOCKER_PROJECT_PATH" ]; then
    DOCKER_PROJECT_PATH=${DOCKER_SHARED_PATH}/$(basename $(pwd))
    echo "Setting DOCKER_PROJECT_PATH to $DOCKER_PROJECT_PATH"
fi

if [ -z "$DOCKER_PHP_VERSION" ]; then
    DOCKER_PHP_VERSION=7.1
    echo "Setting DOCKER_PHP_VERSION to $DOCKER_PHP_VERSION"
fi

if [ -z "$DOCKER_MYSQL_VERSION" ]; then
    DOCKER_MYSQL_VERSION=5.6
    echo "Setting DOCKER_MYSQL_VERSION to $DOCKER_MYSQL_VERSION"
fi

if [ -z "$DOCKER_NODE_VERSION" ]; then
    DOCKER_NODE_VERSION=8.11
    echo "Setting DOCKER_NODE_VERSION to $DOCKER_NODE_VERSION"
fi

#handle solr dir/perms
case "$CONTAINERS" in 
    *solr*)
        if [ -d ${DOCKER_PROJECT_PATH}/solr-data ]; then
            echo "Solr data dir found, if solr does _NOT_ start, please sudo chown 8983:8983 ${DOCKER_SHARED_PATH}/solr-data"
        else
            echo "Creating solr data-dir, sudo chown'd as the solr user (8983)"
            mkdir ${DOCKER_PROJECT_PATH}/solr-data
            sudo chown 8983:8983 ${DOCKER_PROJECT_PATH}/solr-data
        fi
    ;;
esac

#export all docker vars
export DOCKER_SHARED_PATH="$DOCKER_SHARED_PATH"
export DOCKER_PROJECT_PATH="$DOCKER_PROJECT_PATH"
export DOCKER_PHP_VERSION="$DOCKER_PHP_VERSION"
export DOCKER_MYSQL_VERSION="$DOCKER_MYSQL_VERSION"
export DOCKER_NODE_VERSION="$DOCKER_NODE_VERSION"
export DOCKER_PHP_COMAND="$DOCKER_PHP_COMAND"

#run containers
if [ -z "$DOCKER_ATTACHED_MODE" ]; then
    echo "Creating detached services: ${DOCKER_CONTAINERS}"
    docker-compose up -d ${DOCKER_CONTAINERS}
else
    echo "Creating attached services: ${DOCKER_CONTAINERS}"
    docker-compose up ${DOCKER_CONTAINERS}
fi
