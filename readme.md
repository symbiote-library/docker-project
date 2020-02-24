# Symbiote PHP project docker

A collection of docker containers used by a single web project. Tailored to suit SilverStripe applications, but usable by other PHP apps.

## Running

#### Step 1

Copy these files into the root of your SilverStripe project folder:

* docker-compose.yml
* du.sh
* dr.sh

#### Step 2

Create a `docker.env` file in your project root to define the docker configuration.

Example config:
```
DOCKER_CONTAINERS="apache php phpcli adminer mysql node"
DOCKER_PHP_VERSION="7.1"
DOCKER_MYSQL_VERSION="5.7"
DOCKER_NODE_VERSION="8.11"
DOCKER_YARN_PATH="themes/my-theme"
DOCKER_CLISCRIPT_PATH="vendor/silverstripe/framework/cli-script.php"
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
- `./du.sh -s` when swapping projects (or `-k` if you don't care to gracefully shutdown).
- `./du.sh -kr` when you want to recreate containers.
- `./du.sh -p` to check for image updates on a project you haven't used in a while.
- `./du.sh -pc` when you want to update a project's images, but not start the containers.

#### Step 4

Define local `.env` variables to customise your experience. See *Environment Variables* for a full list.

Mac users will need to:
- Set `DOCKER_SSH_VOLUME="~/.ssh:/var/www/.ssh"` in `.env` (where the first path points to your ssh folder).
- Set `DOCKER_EXEC_IDS="1000:1000"` in `.env` (uid:gid).

#### Step 5

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

The following environment variables are exported to `docker-compose.yml` and can/should be defined:

#### Project variables (defined in remote `docker.env` file)
* `DOCKER_CONTAINERS`: List of containers to start when you run `du.sh`. Defaults to `apache php phpcli adminer mysql node`.
* `DOCKER_PHP_VERSION`: Options are [5.6, 7.1] Defaults to `7.1`.
* `DOCKER_MYSQL_VERSION`: Defaults to `5.6`.
* `DOCKER_NODE_VERSION`: Options are [6.14, 8.11] Defaults to `8.11`.
* `DOCKER_YARN_PATH`: Project relative path to yarn for running yarn commands via `dr.sh`.
* `DOCKER_CLISCRIPT_PATH`: Project relative path to silverstripe's `cli-script.php` for `dr.sh`.

#### User variables (defined in local `.env` file):
* `DOCKER_SHARED_PATH`: Where shared data (such as the composer cache) is stored. Defaults to `~/docker-data`.
* `DOCKER_PROJECT_PATH`: Where project specific data is stored. Defaults to `DOCKER_SHARED_PATH/(basename pwd)` (define pull path when overriding).
* `DOCKER_ATTACHED_MODE`: If defined (any value), starts all containers in attached mode.
* `DOCKER_PHP_COMMAND`: Used to add extra commands to the php fpm startup, in particular extensions. Defaults to nothing. Note that you _must_ include a trailing `&&`.
* `DOCKER_SSH_VOLUME`: Mounts ssh keys into phpcli container (mac users see *Step 4*).
* `DOCKER_EXEC_IDS`: uid and gui used when running `exec` on a container (mac users see *Step 4*).
* `DOCKER_COMPOSER_TIMEOUT`: Sets the composer process timeout. Use this if your composer intall is timing out. Defaults to `300`.

Notes:
- You can use SilverStripe's `.env` file as they both follow the same formatting rules.
- It is recommended that you wrap values in quotes.

## Executing commands

Note that anything in `{}` is supplied by the user.

#### In short:

* `./dr.sh [action] {...}`
* `./dr.sh [container] [action] {...}`

#### Containers

* php
* fpm
* mysql
* node
* sel

If not specified, the container is automatically chosen based on the supplied action

#### Actions:

* **cli** - Drop into the given container in a bash shell.
  * `./dr.sh {container} cli`.
* **exec** - Runs `{cmd}` in the given container (basically `docker exec`).
  * `./dr.sh {container} exec {cmd}`.
* **php** - Executes `php {cmd}` in the phpcli container.
  * `./dr.sh php {script.php}`.
  * `./dr.sh php -r {php code}`.
* **composer** - Executes `composer {cmd}` in the phpcli container.
  * `./dr.sh composer install`.
  * `./dr.sh composer update {package}`.
* **phing** - Runs phing in the phpcli container.
  * `./dr.sh phing`.
* **codecept** - Executes `./vendor/bin/codecept {cmd}` in the phpcli container.
  * `./dr.sh codecept build`.
* **mysqlimport** - Executes `mysql {cmd} < {file}`.
  * `./dr.sh mysqlimport -u{user} -p{password} {db} < {db.sql}`.
* **yarn** - Execute `yarn {cmd}` in the node container.
  * `./dr.sh yarn install`.
* **task** - Executes `dev/tasks` or `dev/tasks {task}`.
  * `./dr.sh task {task}`.
* **sspak** - Executes an `sspak {cmd}` in the phpcli container.
  * `./dr.sh sspak load {file} {webroot}`
* **fpm** - Executes `{cmd}` in the php container.
  * `./dr.sh fpm cli`.
* **fpmreload** - Sends `kill -USR2 1` to the php container.
  * `./dr.sh fpmreload`.
* **sel** - Executes `{cmd}` in the selenium container.
  * `./dr.sh sel cli`.
* **fixperms** - Fixes permissions for the docker-date directory and project directory.
  * `./dr.sh fixperms`.

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
    command: bash -c "cd ${DOCKER_YARN_PATH} && yarn install && yarn start"
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
`./dr.sh mysqlimport -u[USERNAME] -p[YOUR_PASSWORD] [DATABASE_NAME] < inputfile-on-host.sql`

E.g. I copy a *.sql file into the root of my project folder, run the following command, and then delete the *.sql file.
`./dr.sh mysqlimport -uroot -ppassword db-name < backup.sql`.

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
      - ~/docker-data/logs:/var/log/silverstripe
    command: bash -c "${DOCKER_PHP_COMMAND} && php-fpm"
```

The default `docker-compose.yml` file comes with this parameterised as `DOCKER_PHP_COMMAND`, and can be set in your `.env` file. This also allows for the specification of specific PHP config options, for example to set `display_errors = On`.
Echoed lines must be wrapped in `'` single quotes and the entire string must be wrapped in `"` double quotes.

A recommendation for development;

```
DOCKER_PHP_COMMAND="docker-php-ext-enable xdebug && echo 'display_errors = 1' >> /usr/local/etc/php/php.ini && echo 'error_reporting = E_ALL' >> /usr/local/etc/php/php.ini && "
```

Note: You should be able to just run `./du.sh` to apply the config but you may need to destroy the containers (`./du.sh -kr` should do it, otherwise `docker ps -a` and `docker rm {id}`).

#### XDebug configuration

The default XDebug configuration has:

```
xdebug.remote_enable=on
xdebug.remote_autostart=on
xdebug.remote_connect_back=on
xdebug.remote_handler=dbgp
xdebug.remote_host=host.docker.internal
xdebug.remote_port=9000
xdebug.idekey=VSCODE
```

Notes:

- _if_ you're planning to run a **production** image, ensure it is created _without_ `remote_enable=on`, so that debugging is _not_ startable by default on production.
- By default XDebug is configured to automatically start, so once enabled via docker compose, it _will_ attempt to connect back to your IDE.
- You may need to change `idekey=VSCODE` as to cater for your IDE.
- If using vscode, remember you'll need to set a `pathMapping` option in launch.json
  ```
  {
      "pathMappings":
      {
        "/var/www/html": "${workspaceFolder}"
      }
  }
  ```

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

### Solr

- If it's starting the container, but a `docker ps` doesn't show the container, make sure you run `./dr.sh fixperms` and then try again. Hitting `http://localhost:8983/solr/` should let you know this is working.
- The following configuration is needed to actually start indexing things, so make sure it's present if you're seeing connection errors https://github.com/symbiote/docker-project/blob/4925b8ed587eda388d1a910c646e22362a1b83ce/gitlab-ci.sample.yml#L164.
