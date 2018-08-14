#!/bin/sh

#containers to run
CONTAINERS="apache php phpcli adminer mysql selenium mailhog node"

#get flags
while getopts 'ks' flag; do
    case "${flag}" in
        k) KILL=1 ;;
        s) STOP=1 ;;
    esac
done

#handle flags
if [ $STOP -eq 1 ]; then
    echo "Stopping all containers:"
    docker stop $(docker ps -aq)
fi

if [ $KILL -eq 1 ]; then
    echo "Killing all containers:"
    docker kill $(docker ps -aq)
fi

#set default for undefined vars
if [ -z "$DOCKER_SHARED_PATH" ]; then
    DOCKER_SHARED_PATH=~/docker
    echo "Setting default shared path to $DOCKER_SHARED_PATH"
fi

if [ -z "$DOCKER_PROJECT_PATH" ]; then
    DOCKER_PROJECT_PATH=${DOCKER_SHARED_PATH}/$(basename $(pwd))
    echo "Setting default project data path to $DOCKER_PROJECT_PATH"
fi

if [ -z "$DOCKER_PHP_VERSION" ]; then
    DOCKER_PHP_VERSION=7.1
    echo "Setting default PHP version to $DOCKER_PHP_VERSION"
fi

if [ -z "$DOCKER_MYSQL_VERSION" ]; then
    DOCKER_MYSQL_VERSION=5.6
    echo "Setting default MySQL version to $DOCKER_MYSQL_VERSION"
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
export DOCKER_PHP_COMAND="$DOCKER_PHP_COMAND"

#run containers
echo "Creating services: ${CONTAINERS}"
docker-compose up -d ${CONTAINERS}
