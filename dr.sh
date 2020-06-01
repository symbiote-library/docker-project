#!/bin/sh

#loads docker env vars into this process
DENV="./docker.env"
if [ -e $DENV ]; then
    . $DENV
fi

#loads user env vars into this process
ENV="./.env"
if [ -e $ENV ]; then
    . $ENV
fi

#handle env vars
if [ -z "$DOCKER_YARN_PATH" ]; then
    DOCKER_YARN_PATH="themes/"
fi
if [ -z "$DOCKER_CLISCRIPT_PATH" ]; then
    DOCKER_CLISCRIPT_PATH="framework/cli-script.php"
fi
if [ -z "$DOCKER_EXEC_IDS" ]; then
    DOCKER_EXEC_IDS="`id -u`:`id -g`"
fi
if [ -z "$DOCKER_SHARED_PATH" ]; then
    DOCKER_SHARED_PATH="~/docker-data"
fi

CMD=$1
CONTAINER="none"
ACTION="pass"
RUN_OPTS="-it"
CONTAINER_PREFIX=$(basename "$(pwd)")

case "$CMD"
in
    php)
        CONTAINER="phpcli"
        ACTION="php"
        ;;
    composer)
        CONTAINER="phpcli"
        ACTION="composer"
        ;;
    sspak)
        CONTAINER="phpcli"
        ACTION="sspak"
        ;;
    phing)
        CONTAINER="phpcli"
        ACTION="phing"
        ;;
    codecept)
        CONTAINER="phpcli"
        ACTION="vendor/bin/codecept"
        ;;
    task)
        CONTAINER="phpcli"
        ACTION="task"
        ;;
    fpm)
        CONTAINER="php"
        ACTION="bash"
        ;;
    fpmreload)
        CONTAINER="php"
        ACTION="reload"
        ;;
    mysql)
        CONTAINER="mysql"
        ACTION="mysql"
        ;;
    mysqlimport)
        CONTAINER="mysql"
        ACTION="mysql"
        RUN_OPTS="-i"
        ;;
    sel)
        CONTAINER="selenium"
        ;;
    node)
        CONTAINER="node"
        ACTION="bash"
        ;;
    yarn)
        CONTAINER="node"
        ACTION="yarn"
        ;;
    fixperms)
        ACTION="fixperms"
        ;;
    help)
        ACTION="help"
        ;;
esac

case "$2"
in
    cli)
        ACTION="cli"
        ;;
    exec)
        ACTION="exec"
        ;;
esac

# help action
if [ $ACTION = "help" ]; then
    echo "Usage: ./dr.sh <container> <action> [args]"
    echo "       ./dr.sh <action> [args]"
    echo ""
    echo "<container> : { apache | adminer | php | phpcli | mysql | node | sel }"
    echo "<arguments> : { cli | exec [args] | [args] }"
    echo ""
    echo "[args]      : free-form - will be passed as-is to the container"
    echo ""
    echo "commands    : { composer | sspak | phing | codecept | task | fpm"
    echo "              | fpmreload | mysqlimport | yarn | fixperms | help }"
    echo ""
    echo "See the readme for more information:"
    echo " - https://github.com/symbiote/docker-project/blob/master/readme.md"
    exit 1;
fi

# fix perms action
if [ $ACTION = "fixperms" ]; then
    #get sudo perms
    sudo echo "" > /dev/null
    # set perms for project directory
    echo "Fixing $PWD"
    sudo chown -Rf `id -u`:1000 .
    # get shared root (expanding '~')
    SHARED=$(eval ls -d -- "$DOCKER_SHARED_PATH")
    # shared perms are OS specific (to work around silly mac)
    NOT_MAC=$(echo `uname -a` | grep "Darwin")
    if [ -z "$NOT_MAC" ]; then
        PERMS="775"
    else
        PERMS="777"
    fi
    # set blanket perms everything in shared
    sudo chown -Rf 1000:33 $SHARED
    sudo chmod -Rf $PERMS $SHARED
    # loop all dirs in shared
    for DIR in $SHARED/*/; do
        echo "Fixing $DIR"
        # into dir
        cd $DIR
        # set perms for snowflake dirs
        sudo chown -Rf 999:999 mysql-data
        sudo chown -Rf 8983:8983 solr-data solr-logs
        sudo chmod -Rf 777 logs solr-logs
        sudo chmod -Rf 100:101 redis-data
        # back out
        cd ..
    done
    exit 1;
fi

# check for container
if [ $CONTAINER = "none" ]; then
    echo "Please provide a container or a command to be run. Use the 'dr.sh help' for more information."
    exit 1;
fi

# check whether we're running in CI on gitlab
if [ ! -z "${CI}" ]; then
    # noop
    RUN_OPTS="-i"
    echo "Executing in CI, setting to no TTY"
fi

CONTAINER_NAME=${CONTAINER_PREFIX}_${CONTAINER}_1

if [ $ACTION = "cli" ]; then
    echo "Dropping to shell in $CONTAINER"
    docker exec ${RUN_OPTS} -u ${DOCKER_EXEC_IDS} ${CONTAINER_NAME} /bin/bash
elif [ $ACTION = "exec" ]; then
    echo "Execute bash wrapped command on $CONTAINER" && shift && shift
    docker exec ${RUN_OPTS} -u ${DOCKER_EXEC_IDS} ${CONTAINER_NAME} bash -c "$@"
else
    echo "Running command $ACTION in $CONTAINER" && shift
    if [ "yarn" = $CMD ]; then
        docker exec ${RUN_OPTS} -u ${DOCKER_EXEC_IDS} ${CONTAINER_NAME} bash -c "cd $DOCKER_YARN_PATH; yarn $*"
    elif [ "task" = $CMD ]; then
        docker exec ${RUN_OPTS} -u ${DOCKER_EXEC_IDS} ${CONTAINER_NAME} bash -c "php $DOCKER_CLISCRIPT_PATH dev/tasks/$@"
    elif [ "mysqlimport" = $CMD ]; then
        docker exec ${RUN_OPTS} -u ${DOCKER_EXEC_IDS} ${CONTAINER_NAME} ${ACTION} "$@" < /proc/$$/fd/0
    elif [ "fpmreload" = $CMD ]; then
        docker exec ${RUN_OPTS} -u ${DOCKER_EXEC_IDS} ${CONTAINER_NAME} ${ACTION} bash -c kill -USR2 1
    else
        docker exec ${RUN_OPTS} -u ${DOCKER_EXEC_IDS} ${CONTAINER_NAME} ${ACTION} "$@"
    fi
fi
