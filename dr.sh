#!/bin/sh

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
CONTAINER_PREFIX=$(basename $(pwd))

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
        CONTAINER="node"
        ACTION="fixperms"
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

# fix perms action
if [ $ACTION = "fixperms" ]; then
    #get sudo perms
    sudo echo "" > /dev/null
    echo "Fixing $PWD"
    # set perms for project directory
    sudo chown -Rf 1000:1000 .
    sudo chmod -Rf 755 .
    # get shared root (expanding '~')
    SHARED=$(eval ls -d -- "$DOCKER_SHARED_PATH")
    # set blanket perms everything in shared
    sudo chown -Rf 1000:33 $SHARED
    sudo chmod -Rf 775 $SHARED
    # loop all dirs in shared
    for DIR in $SHARED/*/; do
        echo "Fixing $DIR"
        # into dir
        cd $DIR
        # set perms for snowflake dirs 
        sudo chown -Rf 999:999 mysql-data
        sudo chown -Rf 8983:8983 solr-data solr-logs
        sudo chmod -Rf 777 logs
        # back out
        cd ..
    done
    exit 1;
fi

if [ $CONTAINER = "none" ]; then
    echo "Please provide a container or a command to be run - ./dr.sh {container|command} [arguments] "
    echo "Available containers are as follows; any arguments will be used as docker exec parameters : "
    echo "  php, fpm, mysql, node"
    echo "Available commands are below; any arguments are passed to these commands in the container "
    echo "  composer, phing, codecept, mysqlimport, yarn"
    echo "Usage: ./dr.sh container [arguments]"
    echo "       ./dr.sh command"
    echo "       ./dr.sh <args>"
    echo ""
    echo "container  : { apache | adminer | php | phpcli | mysql | node }"
    echo "arguments  : { cli | exec [<args>] | [<args] }"
    echo ""
    echo "<args>     : free-form - will be passed as-is to the container"
    echo ""
    echo "commands   : { php | composer | sspak | phing | codecept | task | fpm"
    echo "             | fpmreload | mysql | mysqlimport | sel | node | yarn }"
    echo ""
    echo "Command are just shortcuts:"
    echo "php           = phpcli php"
    echo "composer      = phpcli composer"
    echo "sspak         = phpcli sspak"
    echo "phing         = phpcli phing"
    echo "codecept      = phpcli vendor/bin/codecept"
    echo "task          = phpcli task"
    echo "fpm           = php bash"
    echo "fpmreload     = php reload"
    echo "mysql         = mysql mysql"
    echo "mysqlimport   = mysql mysql (with docker exec --interactive)"
    echo "sel           = selenium"
    echo "node          = node bash"
    echo "yarn          = node yarn"
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
        docker exec ${RUN_OPTS} -u ${DOCKER_EXEC_IDS} ${CONTAINER_NAME} bash -c "cd $DOCKER_YARN_PATH; yarn $@"
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
