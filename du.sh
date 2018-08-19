#!/bin/sh

PULL="FALSE"

#handle cmd flags
while getopts 'skrp' flag; do
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
        p)
            PULL="TRUE"
            ;;
    esac
done

#loads user env vars into this process
ENV="./.env"
if [ -e $ENV ]; then
    . $ENV
fi

#loads docker env vars into this process
DENV="./docker.env"
if [ -e $DENV ]; then
    . $DENV
fi

#set default for undefined vars
if [ -z "$DOCKER_CONTAINERS" ]; then
    echo "Setting DOCKER_CONTAINERS to $DOCKER_CONTAINERS"
    DOCKER_CONTAINERS="apache php phpcli adminer mysql node"
fi

if [ -z "$DOCKER_SHARED_PATH" ]; then
    echo "Setting DOCKER_SHARED_PATH to $DOCKER_SHARED_PATH"
    DOCKER_SHARED_PATH=~/docker
fi

if [ -z "$DOCKER_PROJECT_PATH" ]; then
    echo "Setting DOCKER_PROJECT_PATH to $DOCKER_PROJECT_PATH"
    DOCKER_PROJECT_PATH=${DOCKER_SHARED_PATH}/$(basename $(pwd))
fi

if [ -z "$DOCKER_PHP_VERSION" ]; then
    echo "Setting DOCKER_PHP_VERSION to $DOCKER_PHP_VERSION"
    DOCKER_PHP_VERSION=7.1
fi

if [ -z "$DOCKER_MYSQL_VERSION" ]; then
    echo "Setting DOCKER_MYSQL_VERSION to $DOCKER_MYSQL_VERSION"
    DOCKER_MYSQL_VERSION=5.6
fi

if [ -z "$DOCKER_NODE_VERSION" ]; then
    echo "Setting DOCKER_NODE_VERSION to $DOCKER_NODE_VERSION"
    DOCKER_NODE_VERSION=8.11
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
export DOCKER_PHP_COMMAND="$DOCKER_PHP_COMMAND"

#docker pull
if [ "$PULL" = "TRUE" ]; then
    echo "Pulling latest images:"
    docker-compose pull ${DOCKER_CONTAINERS}
fi

#run containers
if [ -z "$DOCKER_ATTACHED_MODE" ]; then
    echo "Starting detached containers: ${DOCKER_CONTAINERS}"
    docker-compose up -d ${DOCKER_CONTAINERS}
else
    echo "Starting attached containers: ${DOCKER_CONTAINERS}"
    docker-compose up ${DOCKER_CONTAINERS}
fi
