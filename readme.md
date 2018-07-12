# Symbiote PHP project docker

A collection of docker containers used by a single web project. Tailored
to suit SilverStripe applications, but usable by other PHP apps. 


## Running

**1** 

Copy 

* docker-compose.yml
* du.sh
* dr.sh

files into the root of your SilverStripe project folder. 

**2**

Run `./du.sh` to start with the initial set of containers; you can modify this
launch file for your project config if you need a different set of services. 

**3**

To get into the containers, or run commands against the containers, the `./dr.sh`
script is available. See below in **Executing commands** for specifics, but

`./dr.sh php cli`

will get you into the PHP cli for things you need to install. 


**Other points**

To provide environment specific options, the following properties can be added
to your `.env` file. Yes, this file overlaps with SilverStripe's `.env` file,
but conveniently they both follow the same formatting rules

Note that it will _not_ be necessary in every case to run _all_ the associated 
services. The du.sh script defines a list of _just_ the services you 
decide are necessary for your project

```
#!/bin/sh

docker-compose up -d apache php phpcli adminer mysql56 selenium mailhog
```


## Containers

The following can be included as needed in the `./du.sh` script. 

Note for those containers below that have different versions, simply change the docker-compose file 
to reference the older version where needed. 

* apache - apache 2 connecting to FPM  (**symbiote/apache2**)
* phpfpm - PHP 7.1 and 5.6, http(s)://localhost (**symbiote/php-fpm:5.6** or **symbiote/php-fpm:7.1**)
* phpcli - PHP 7.1 and 5.6 (**symbiote/php-cli:5.6** or **symbiote/php-cli:7.1**)
* node - 8.11 and 6.14 available with yarn, grunt-cli, brunch and bower (**symbiote/node:6.14** or **symbiote/node:8.11**)
* queuedjobs - Based on phpcli, runs with SilverStripe's queuedjobs
* sqsrunner - A file-based queue executor, for testing with the Sqs module
* adminer - web based interface for mysql, http://localhost:8080
* mysql56 - Aliased as mysql, a mysql 5.6 instance
* redis - redis 3.2, available on redis:6379  from other containers
* elastic - elastic search 5.3 (AWS compatible) available via 
  http://localhost:9200 and elastic:9200 from other containers
* solr - A solr 5.5 instance - TODO adding custom solr.xml and creating new
  cores
* selenium - remaps requests to symlocal back to the webserver container
* mailhog - mail capture, web interface available on http://localhost:8025



## Environment variables

Note: All environment variables are read AS DEFINED in .env, meaning you should
_not_ include quotes

The following environment variables are used by the docker-compose file

* `PHP_FPM_EXTENSIONS` - Used to add extra commands to the php fpm startup, in
  particular extensions. Note that you _must_ include a trailing `&&` or `;` eg `PHP_FPM_EXTENSIONS=docker-php-ext-enable xdebug &&`
* `DOCKER_SHARED_PATH` - A file system path which is used for shared data 
  between all containers. The `du.sh` script will default this to `~/docker.sh`
  if you do _not_ have it set in your shell environment


## Executing commands

_In short_

`./dr.sh {command} [cli]`

Where {service} is one of

* php
* composer
* phing
* codecept
* fpm
* mysql
* sel
* yarn

If the argument passed is "cli", you will be dropped to a bash shell
inside the given container, eg

`./dr.sh php cli` 

will give you a bash shell inside the container. 

Otherwise, the command will be executed as though it is the raw binary, eg

`./dr.sh composer update package/name`

will run the composer update command directly. 


_A little more detail_

Some commands can be run by executing containers in isolation, but as they're
likely to touch on services defined in docker compose, you'll more often than
not choose to execute them in context of a running docker-compose session. 

Eg

* ``docker exec -it -u `id -u`:`id -g` project_phpcli_1 phing``

Alternatively, you can execute a bare container by binding to the shared
network

Eg

* ``docker run --rm -it --network project_default -v $(pwd):/tmp -w /tmp -u `id -u`:`id -g` symbiote/php-cli:5.6 phing``

Note that in the first example, the execution occurs in the context of the 
mounted volumes specified in docker-compose; the second allows you to
execute in _any_ location by mounting the current directory. For the second you
must know the name of the network; for most cases, this will be something like
{project_dir_name}_default 

 

## Handy commands

### PHP commands

`./dr.sh php [and-your-commands]`

* `./dr.sh php -a` for an interactive prompt
* ``docker exec -it -u `id -u`:`id -g` {project}_phpcli_1 phing``
* ``docker exec -it -u `id -u`:`id -g` {project}_phpcli_1 composer update {package_name}``


### SSPak

The PHP CLI container bundles the `sspak` utility for packing and unpacking 
SilverStripe CMS sites. 


### Node

`./dr.sh node [arguments]`


Executing node commands is again performed using `./dr.sh` - to drop to a command line with all node based tools,
execute `./dr.sh node cli`

The following binaries are available in the node environment

* node
* npm
* yarn
* brunch
* gulp
* grunt
* cordova



### Yarn commands

`./dr.sh yarn [other-arguments]``

Note that the first time you run this in a project, you'll be prompted to update dr.sh with a directory containing
the yarn package.json. 

``docker exec -it -u `id -u`:`id -g` {project}_node_1 bash -c "cd themes/site-theme && yarn install && yarn start"``

Optionally, you can set up your docker-compose with a command like the following

```
services:
  node: 
    etc: as_per_default_config
    command: bash -c "cd themes/site-theme && yarn install && yarn start"
```

### Running codeception

Assuming your project has codeception tests defined

`./dr.sh codecept [other-arguments]`

Or manually,

``docker exec -it -u `id -u`:`id -g` project_phpcli_1 vendor/bin/codecept run -c module-folder/codeception/codeception.yml``

### Running queuejobs for a SilverStripe project

To use it, just add "queuedjobs" to the list of containers in `./du.sh`

The base docker-compose file contains a container definition for running queuedjobs. In short, this creates an instance of the PHP CLI container, then runs a bash script that will execute the job queue task every 30 seconds for as long as the container exists. 

```
queuedjobs:
    image: "symbiote/php-cli:5.6"
    # other things left out for brevity ... 
    command: [
      "/bin/bash",
      "-c",
      "while :; do php /var/www/html/framework/cli-script.php dev/tasks/ProcessJobQueueTask queue=2 >> /var/log/php/queuedjob.log; php /var/www/html/framework/cli-script.php dev/tasks/ProcessJobQueueTask queue=3 >> /var/log/php/queuedjob.log; sleep 30; done"  
    ]
```

### Running SQS tasks from a container for a SilverStripe project

To use it, 

* add "sqsrunner" to the list of containers in `./du.sh`
* Make sure your project is configured to use the FileBasedSqsQueue for local development via yml config (see below)
* Make sure your sqs module is at least version ?? - you can confirm by checking that the sqs-jobqueue/central-runner is set to look in `__DIR__ . '/fake-sqs-queues';` for jobs


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


**Connect into the mysql client**


`./dr.sh mysql [connection-parameters]`


**Import a database file**

`./dr.sh mysqlimport [connection-parameters] databasename < inputfile-on-host.sql`



From the docker examples;

The following command starts another mysql container instance and runs the 
mysql command line client against your original mysql container, allowing 
you to execute SQL statements against your database instance:


`$ docker run -it --network project_default --rm mysql:5.6 sh -c 'exec mysql -h"$MYSQL_TCP_ADDR" -P"$MYSQL_TCP_PORT" -uroot -p"$MYSQL_ENV_MYSQL_ROOT_PASSWORD"'`


Or to just execute a command

`docker run -it --network project_default --rm mysql mysql -hmysql56 -uroot -p`

Loading a database file

`docker run -i --network project_default --rm mysql:5.6 mysql -hmysql56 -uroot -ppassword databasename < dbfile.sql`


## XDebug and other extensions

Enabling xdebug needs to be done as part of the relevant PHP containers' 
startup commands. The default php images are configured with some modules 
disabled as per production requirements. These can be enabled as part of the
docker-compose used locally in the project

```
  php:
    image: "symbiote/php-fpm:7.1"
    volumes:
      - '.:/var/www/html'
      - ~/docker/logs:/var/log/silverstripe
    command: bash -c "docker-php-ext-enable xdebug && php-fpm"
```

The default `docker-compose.yml` file comes with this parameterised as `PHP_FPM_EXTENSIONS`, 
and can be set in your `.env` file. 

Note you'll need to destroy the containers (`docker-compose down` should do, otherwise `docker ps -a` and `docker rm {id}`)

If using vscode, remember you'll need to set a `pathMapping` option in launch.json

```
{
    "pathMappings": 
    { 
      "/var/www/html": "${workspaceRoot}" 
    }
}
```

After starting the debugger in your IDE, you'll need to open your browser using a URL parameter as xdebug is _not_ configured for auto-run, eg

`https://mysite.symlocal/?XDEBUG_SESSION_START=1`



## Building the images


Contains Docker file definitions for

* Apache2
* PHP FPM 
* Selenium
* Node (in particular, yarn toolset)

Apache2 is built from a base ubuntu 16.04, rather than library/httpd. This
maintains consistency with Symbiote's standard environment configuration. 


Each sub-folder contains their own specific dockerfile definitions.

Built images can then be pushed to docker-hub; please speak to marcus@symbiote.com.au before doing so!


The recommended docker-compose structure uses the above, as well as references 
to the following from upstream docker repositories

* MySQL 
* mailhog
* Adminer
* Elastic Search



## Customising images on a per-project basis

For some projects, it will be necessary to add additional PHP dependencies; 
you can define these by specifying a custom image from docker-compose

Create a "docker" directory under your project. Add the following `build` 
config to docker-compose, and change the image project-name accordingly

```
  php:
    build: 
      context: ./docker
      dockerfile: Dockerfile.php
    image: "symbiote/{project-name}-php-fpm:7.1"
```
