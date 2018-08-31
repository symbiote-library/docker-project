#!/bin/sh

#loads docker env vars into this process
DENV="./docker.env"
if [ -e $DENV ]; then
    . $DENV
fi

#handle env vars
if [ -z "$DOCKER_YARN_PATH" ]; then
    DOCKER_YARN_PATH=""
fi

CMD=$1
CONTAINER="none"
ACTION="pass"
RUN_OPTS="-it"
CONTAINER_PREFIX=$(basename $(pwd))

# run pre-defined shortcut commands
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
    fpm) 
        CONTAINER="php"
        ACTION="bash"
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
esac

# function: check if given full name container exist
fn_container_exists() {        
        container_name_match=$(docker ps --filter="name=$1" --format "{{.Names}}")
        lines=$(echo $container_name_match | grep "$1" | wc -l)
        if [ "$container_name_match" = "$1" ] && [ "$lines" = "1" ]; then
                return 0; 
        else
                return 1;
        fi
}

if [ $CONTAINER = "none" ]; then
    # First parameter is not a command, so check if it's a container name
    if fn_container_exists "$CMD"; then        
        CONTAINER_NAME="$CMD"
        CONTAINER=$(echo "$CONTAINER_NAME" | sed -e 's/^.*_\(.*\)_[[:digit:]]$/\1/')          
    else
        CONTAINER_LIST=$(docker ps --filter="name=$CONTAINER_PREFIX" --format "{{.Names}}")
        echo "Usage  ./dr.sh command"
        echo "       ./dr.sh container [arguments]"
        echo ""    
        echo "commands   : { php | composer | sspak | phing | codecept | task | fpm"
        echo "             | fpmreload | mysql | mysqlimport | sel | node | yarn }"
        echo ""
        echo "Command are shortcuts to:"
        echo "php         = phpcli php"
        echo "composer    = phpcli composer"
        echo "sspak       = phpcli sspak"
        echo "phing       = phpcli phing"
        echo "codecept    = phpcli vendor/bin/codecept"
        echo "task        = phpcli task"
        echo "fpm         = php bash"
        echo "fpmreload   = php reload"
        echo "mysql       = mysql mysql"
        echo "mysqlimport = mysql mysql (with docker exec --interactive)"
        echo "sel         = selenium"
        echo "node        = node bash"
        echo "yarn        = node yarn"
        echo ""
        echo "Alternatively, run commands directly on containers if needed:"
        echo "container  : { $(echo $CONTAINER_LIST | sed -e 's/\ /\ \|\ /g') }" #apache | adminer | php | phpcli | mysql | node }"
        echo "arguments  : { cli | exec [<args>] | [<args>] }"
        echo "<args>     : free-form - will be passed as-is to the container"
        echo ""
        exit 1;
    fi
fi

# check whether we're running in CI on gitlab
if [ ! -z "${CI}" ]; then
    # noop
    RUN_OPTS="-i"
    echo "Executing in CI, setting to no TTY"
fi

case "$2"
in
    cli) 
        ACTION="cli"
        ;;
    exec) 
        ACTION="exec"
        ;;
esac

CONTAINER_NAME=${CONTAINER_PREFIX}_${CONTAINER}_1

if [ $ACTION = "cli" ]; then
    echo "Dropping to shell in $CONTAINER"
    docker exec ${RUN_OPTS} -u `id -u`:`id -g` ${CONTAINER_NAME} /bin/bash
elif [ $ACTION = "exec" ]; then
    # double shift
    shift
    shift
    echo "Execute bash wrapped command on $CONTAINER"
    docker exec ${RUN_OPTS} -u `id -u`:`id -g` ${CONTAINER_NAME} bash -c "$@"
else
    shift
    echo "Running command $ACTION in $CONTAINER"
    if [ "mysqlimport" = $CMD ]; then
        docker exec ${RUN_OPTS} -u `id -u`:`id -g` ${CONTAINER_NAME} ${ACTION} "$@" < /proc/$$/fd/0
    elif [ "yarn" = $CMD ]; then
        if [ "$DOCKER_YARN_PATH" = "" ]; then
            echo "Please add the DOCKER_YARN_PATH env var"
            exit 1;
        else
            docker exec ${RUN_OPTS} -u `id -u`:`id -g` ${CONTAINER_NAME} bash -c "cd $DOCKER_YARN_PATH; yarn $@"
        fi
    else
        docker exec ${RUN_OPTS} -u `id -u`:`id -g` ${CONTAINER_NAME} ${ACTION} "$@"
    fi
fi
