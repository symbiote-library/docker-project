#!/bin/sh

CONTAINER="none"
ACTION="pass"
RUN_OPTS="-it"

case "$1"
in
    php) 
        CONTAINER="phpcli"
        ACTION="php"
        ;;
    composer)
        CONTAINER="phpcli"
        ACTION="composer"
        ;;
    phing)
        CONTAINER="phpcli"
        ACTION="phing"
        ;;
    fpm) 
        CONTAINER="php"
        ACTION="bash"
        ;;
    mysql) 
        CONTAINER="mysql56"
        ACTION="mysql"
        ;;
    sel) 
        CONTAINER="selenium"
        ;;
    yarn) 
        CONTAINER="node"
        ACTION="yarn"
        ;;
esac

case "$2"
in
    cli) 
        ACTION="cli"
    ;;
esac

if [ $CONTAINER = "none" ]; then
    echo "Valid containers are php, fpm, mysql, sel, yarn"
    exit 1;
fi

if [ $ACTION = "cli" ]; then
    echo "Dropping to shell in $CONTAINER"
    docker exec -it -u `id -u`:`id -g` $(basename $(pwd))_${CONTAINER}_1 /bin/bash
else
    shift
    echo "Running command $CONTAINER $ACTION $@"
    docker exec -it -u `id -u`:`id -g` $(basename $(pwd))_${CONTAINER}_1 ${ACTION} "$@"
fi
