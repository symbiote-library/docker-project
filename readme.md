# Symbiote PHP project docker

A collection of docker containers used by a single web project. Tailored to suit SilverStripe applications, but usable by other PHP apps. 

## Running

#### Step 1

Copy these files into the root of your SilverStripe project folder:

* docker-compose.yml
* du.sh
* dr.sh

#### Step 2

Create a `docker.env` file in your project root and define the docker configuration.

Example config:
```
DOCKER_CONTAINERS="apache php phpcli adminer mysql node"
DOCKER_PHP_VERSION="7.1"
DOCKER_MYSQL_VERSION="5.6"
DOCKER_NODE_VERSION="8.11"
DOCKER_YARN_PATH="path/to/yarn/"
DOCKER_CLISCRIPT_PATH="path/to/cli-script.php"
```

#### Step 3

Run `./du.sh` to create/start the chosen set of containers. 

There are several flags you can give to du.sh to perform additional functionality:

- `-s` Stops all running containers before starting new containers.
- `-k` Kills all running containers before starting new containers.
- `-r` Removes all stopped containers before starting new containers.
- `-p` Pulls down latest images for new containers before starting them.
- `-c` Cancel starting containers (like doing 'ctrl+c' right before containers start).

You can combine these flags and each flag will be executed in the given order.

Common uses:
- `./du.sh -s` when swapping projects (or `-k` when you don't care to retain container states).
- `./du.sh -kr` when you want to reset the container environment (like after adding .env vars).
- `./du.sh -p` when starting a project you haven't used in a while.
- `./du.sh -pc` when you want to update a project's images, but not start the containers.

#### Step 4

To get into the containers, or run commands against the containers, the `./dr.sh` script is available. See below in **Executing commands** for specifics.

Common uses:
- `./dr.sh phing` to build your silverstripe project.
- `./dr.sh yarn build` to run yarn build inside the node container.
- `./dr.sh php cli` to bash into the phpcli container.

## Containers

The following can be included as needed in the `./du.sh` script.  

* __apache__: apache 2 connecting to FPM  (*symbiote/apache2*).
* __phpfpm__: PHP 7.1 and 5.6 (*symbiote/php-fpm:5.6* or *symbiote/php-fpm:7.1*).
* __phpcli__: PHP 7.1 and 5.6 (*symbiote/php-cli:5.6* or *symbiote/php-cli:7.1*).
* __node__: 8.11 and 6.14 available with yarn, grunt-cli, brunch and bower (*symbiote/node:6.14* or *symbiote/node:8.11*).
* __queuedjobs__: Based on phpcli, runs with SilverStripe's queuedjobs.
* __sqsrunner__: A file-based queue executor, for testing with the SQS module.
* __adminer__: web based interface for mysql. Available on `localhost:8080`.
* __mysql__: MySQL image (defaults to version 5.6).
* __redis__: redis 3.2, available on `redis:6379` from other containers.
* __elastic__: elastic search 5.3 (AWS compatible). Available on `localhost:9200` and `elastic:9200` from other containers.
* __solr__: A solr 5.5 instance - TODO adding custom solr.xml and creating new cores.
* __selenium__: remaps requests to symlocal back to the webserver container.
* __mailhog__: mail capture, web interface. Available on `localhost:8025`.

Note for those containers below that have different versions, simply change the docker-compose file 
to reference the older version where needed.

## Environment variables

The following environment variables are used by the `docker-compose.yml` and can be overriden:

#### Project variables (defined in remote `docker.env` file)
* `DOCKER_CONTAINERS`: List of containers to start when you run `du.sh`. Defaults to `apache php phpcli adminer mysql node`.
* `DOCKER_PHP_VERSION`: Options are [5.6, 7.1] Defaults to `7.1`.
* `DOCKER_MYSQL_VERSION`: Defaults to `5.6`.
* `DOCKER_NODE_VERSION`: Options are [6.14, 8.11] Defaults to `8.11`.
* `DOCKER_YARN_PATH`: Project relative path to yarn for running yarn commands via `dr.sh`.
* `DOCKER_CLISCRIPT_PATH`: Project relative path to silverstripe's `cli-script.php`.

#### User variables (defined in local `.env` file):
* `DOCKER_SHARED_PATH`: Where shared data (such as the composer cache) is stored. Defaults to `~/docker`.
* `DOCKER_PROJECT_PATH`: Where project specific data is stored. Defaults to `DOCKER_SHARED_PATH/(basename pwd)` (define pull path when overriding).
* `DOCKER_ATTACHED_MODE`: If defined (any value), starts all containers in attached mode.
* `DOCKER_PHP_COMMAND`: Used to add extra commands to the php fpm startup, in particular extensions. Defaults to `""`. Note that you _must_ include a trailing `&&`.

Notes:
- You can use SilverStripe's `.env` file as they both follow the same formatting rules.
- It is recommended that you wrap values in quotes.

## Executing commands

 #### In short:

`./dr.sh [container] action [arguments]`

Where **container** is one of

* php
* fpm
* mysql
* node
* sel

If not specified, the container is automatically chosen based on the supplied action

#### Actions:

* cli - drop into the container in a bash shell.
* exec - execute a command in that container (basically `docker exec`).
* composer - runs composer in the php container.
* phing - runs phing in the php container.
* codecept - runs ./vendor/bin/codecept in the php container.
* mysqlimport - runs `mysql` with any piped in file sent through to the mysql container.
* yarn - runs yarn in the node container.
* task - lists all dev/tasks, or runs a dev/task when supplied, e.g. `./dr.sh task MyTask`.

See `dr.sh` for more details.

#### Arguments:

Any extra arguments are passed through to the relevant container / execution statement, e.g. 

`./dr.sh composer update package/name`

will run the `composer update package/name` command directly in the php container. 

If the action passed is "cli", you will be dropped to a bash shell inside the given container, e.g.

`./dr.sh php cli` 

will give you a bash shell inside that container, but no arguments are passed. 

For the `exec` action, you can execute arbitrary executables inside the named container, e.g.

`./dr.sh php exec "ls -l"` 

will output the `ls -l` result to screen. 

#### A little more detail:

Some commands can be run by executing containers in isolation, but as they're likely to touch on services defined in docker compose, you'll more often than not choose to execute them in context of a running docker-compose session. 

E.g.

* ``docker exec -it -u `id -u`:`id -g` project_phpcli_1 phing``

Alternatively, you can execute a bare container by binding to the shared network.

E.g.

* ``docker run --rm -it --network project_default -v $(pwd):/tmp -w /tmp -u `id -u`:`id -g` symbiote/php-cli:5.6 phing``

Note that in the first example, the execution occurs in the context of the mounted volumes specified in docker-compose; the second allows you to execute in _any_ location by mounting the current directory. For the second you must know the name of the network; for most cases, this will be something like {project_dir_name}_default 

## Handy commands

#### PHP commands

`./dr.sh php [and-your-commands]`

* `./dr.sh php -a` for an interactive prompt.
* ``docker exec -it -u `id -u`:`id -g` {project}_phpcli_1 phing``.
* ``docker exec -it -u `id -u`:`id -g` {project}_phpcli_1 composer update {package_name}``.

#### SSPak

The PHP CLI container bundles the `sspak` utility for packing and unpacking SilverStripe CMS sites. 

#### Node

`./dr.sh node [arguments]`

Executing node commands is again performed using `./dr.sh` - to drop to a command line with all node based tools,
execute `./dr.sh node cli`

The following binaries are available in the node environment:

* node
* npm
* yarn
* brunch
* gulp
* grunt
* cordova

#### Yarn commands

`./dr.sh yarn [other-arguments]``

Note that the first time you run this in a project, you'll be prompted to update dr.sh with a directory containing
the yarn package.json. 

``docker exec -it -u `id -u`:`id -g` {project}_node_1 bash -c "cd themes/site-theme && yarn install && yarn start"``

Optionally, you can set up your docker-compose with a command like the following:

```
services:
  node: 
    etc: as_per_default_config
    command: bash -c "cd themes/site-theme && yarn install && yarn start"
```

#### Running codeception

Assuming your project has codeception tests defined:

`./dr.sh codecept [other-arguments]`

Or manually:

``docker exec -it -u `id -u`:`id -g` project_phpcli_1 vendor/bin/codecept run -c module-folder/codeception/codeception.yml``

#### Running queuejobs for a SilverStripe project

To use it, just add "queuedjobs" to the list of containers in `docker.env`.

The base docker-compose file contains a container definition for running queuedjobs. In short, this creates an instance of the PHP CLI container, then runs a bash script that will execute the job queue task every 30 seconds for as long as the container exists. 

**Note:** You will need to set the `DOCKER_CLISCRIPT_PATH` env var in `docker.env` (pointint to silverstipe's `cli-script.php`).

```
queuedjobs:
    image: "symbiote/php-cli:5.6"
    # other things left out for brevity ... 
    command: [
      "/bin/bash",
      "-c",
      "while :; do php /var/www/html/${DOCKER_PROJECT_PATH} dev/tasks/ProcessJobQueueTask queue=2 >> /var/log/php/queuedjob.log; php /var/www/html/${DOCKER_PROJECT_PATH} dev/tasks/ProcessJobQueueTask queue=3 >> /var/log/php/queuedjob.log; sleep 30; done"
    ]
```

#### Running SQS tasks from a container for a SilverStripe project

To use it: 

* add "sqsrunner" to the list of containers in `./du.sh`.
* Make sure your project is configured to use the FileBasedSqsQueue for local development via yml config (see below).
* Make sure your sqs module is at least version ?? - you can confirm by checking that the sqs-jobqueue/central-runner is set to look in `__DIR__ . '/fake-sqs-queues';` for jobs.

```
---
Name: sqs_location
After: sqs-jobqueue
---
Injector:
  FileBasedSqsQueue:
    properties:
      queuePath: /var/www/html/sqs-jobqueue/fake-queue
  QueueHandler:
    class: SqsQueueHandler
    properties:
      sqsService: %$SqsService
  SqsService:
    properties:
      client: %$FileBasedSqsQueue
```

### MySQL

#### Connect into the mysql client


`./dr.sh mysql [connection-parameters]`


#### Import a database file
`./dr.sh mysqlimport -u [USERNAME] -p[YOUR_PASSWORD] [DATABASE_NAME] < inputfile-on-host.sql`

E.g. I copy a *.sql file into the root of my project folder, run the following command, and then delete the *.sql file.
`./dr.sh mysqlimport -u root -ppassword project-name < backup.sql`.

From the docker examples:

The following command starts another mysql container instance and runs the mysql command line client against your original mysql container, allowing you to execute SQL statements against your database instance:

`$ docker run -it --network project_default --rm mysql:5.6 sh -c 'exec mysql -h"$MYSQL_TCP_ADDR" -P"$MYSQL_TCP_PORT" -uroot -p"$MYSQL_ENV_MYSQL_ROOT_PASSWORD"'`

Or to just execute a command:

`docker run -it --network project_default --rm mysql mysql -hmysql -uroot -p`

Loading a database file:

`docker run -i --network project_default --rm mysql:5.6 mysql -hmysql -uroot -ppassword databasename < dbfile.sql`

#### XDebug and other extensions or configuration

Enabling extensions and specific PHP config needs to be done as part of the relevant PHP containers' startup commands. The default php images are configured with some modules disabled as per production requirements. These can be enabled as part of the docker-compose used locally in the project.

```
  php:
    image: "symbiote/php-fpm:7.1"
    volumes:
      - '.:/var/www/html'
      - ~/docker/logs:/var/log/silverstripe
    command: bash -c "docker-php-ext-enable xdebug && php-fpm"
```

The default `docker-compose.yml` file comes with this parameterised as `PHP_FPM_EXTENSIONS`, and can be set in your `.env` file. This also allows for the specification of specific PHP config options, for example to set `display_errors=On`.

```
PHP_FPM_EXTENSIONS=docker-php-ext-enable xdebug && printf "display_errors=1" >> /usr/local/etc/php/php.ini &&
```

Note: you'll need to destroy the containers (`docker-compose down` should do, otherwise `docker ps -a` and `docker rm {id}`).

#### XDebug configuration 

The default XDebug configuration has remote autostart = 1. Note that _if_ you're planning to run a production image, ensure it is created after starting _without_ the debug enable options highlighted above, so that debugging is _not_ a thing that is startable by default on production. 

If using vscode, remember you'll need to set a `pathMapping` option in launch.json

```
{
    "pathMappings": 
    { 
      "/var/www/html": "${workspaceRoot}" 
    }
}
```

Or alternatively, user profile wide by changing user settings:

```
{
  "launch": {
        // Use IntelliSense to learn about possible attributes.
        // Hover to view descriptions of existing attributes.
        // For more information, visit: https://go.microsoft.cmo/fwlink/?linkid=830387
        "version": "0.2.0",
        "configurations": [
            {
                "name": "Listen for XDebug",
                "type": "php",
                "request": "launch",
                "port": 9000,
                "pathMappings": {
                    "/var/www/html": "${workspaceRoot}"
                }
            }
        ]
    }
}
```

Note that XDebug is configured to automatically start, so once enabled via docker compose, it _will_ attempt
to connect back to your IDE. 

[//]: # (After starting the debugger in your IDE, you'll need to open your browser using a URL parameter as xdebug is _not_ configured for auto-run, eg)
[//]: # (https://mysite.symlocal/?XDEBUG_SESSION_START=1)

## Building the images

Contains Docker file definitions for

* Apache2
* PHP FPM 
* Selenium
* Node (in particular, yarn toolset)

Apache2 is built from a base ubuntu 16.04, rather than library/httpd. This maintains consistency with Symbiote's standard environment configuration. 

Each sub-folder contains their own specific dockerfile definitions.

Built images can then be pushed to docker-hub; please speak to marcus@symbiote.com.au before doing so!

The recommended docker-compose structure uses the above, as well as references to the following from upstream docker repositories:

* MySQL 
* mailhog
* Adminer
* Elastic Search

## Customising images on a per-project basis

For some projects, it will be necessary to add additional PHP dependencies; you can define these by specifying a custom image from docker-compose.

Create a "docker" directory under your project. Add the following `build` config to docker-compose, and change the image project-name accordingly.

```
  php:
    build: 
      context: ./docker
      dockerfile: Dockerfile.php
    image: "symbiote/{project-name}-php-fpm:7.1"
```

## Troubleshooting

Before `docker-compose down`, make sure to run `docker logs my_container_number` to get the most recent dump of data from the containers.
