# Symbiote PHP project docker

A collection of docker containers used by a single web project. Tailored
to suit SilverStripe applications, but usable by other PHP apps. 

Contains Docker file definitions for

* Apache2
* PHP FPM 
* Selenium

Apache2 is built from a base ubuntu 16.04, rather than library/httpd. This
maintains consistency with Symbiote's standard environment configuration. 

The recommended docker-compose structure uses the above, as well as references 
to the following 

* MySQL 
* mailhog
* Adminer
* Elastic Search

## Building

Each sub-folder contains their own specific dockerfile definitions. 

## Running

Simply copy this `docker-compose.yml` file into the root of your SilverStripe
project folder. You may need to adjust for your specific needs around the 
volume locations. 

Note that it will _not_ be necessary in every case to run _all_ the associated 
services. You can create a startup script to only launch those services you 
decide are necessary

```
#!/bin/sh

docker-compose up apache php phpcli adminer mysql56 selenium mailhog
```



## Customising 

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

## Executing commands

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

``docker exec -it -u `id -u`:`id -g` {project}_phpcli_1 phing``

``docker exec -it -u `id -u`:`id -g` {project}_phpcli_1 composer update {package_name}``

### XDebug

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

### Yarn commands

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

``docker exec -it -u `id -u`:`id -g` project_phpcli_1 vendor/bin/codecept run -c module-folder/codeception/codeception.yml``

### MySQL

From the docker examples;

The following command starts another mysql container instance and runs the 
mysql command line client against your original mysql container, allowing 
you to execute SQL statements against your database instance:


`$ docker run -it --network project_default --rm mysql:5.6 sh -c 'exec mysql -h"$MYSQL_TCP_ADDR" -P"$MYSQL_TCP_PORT" -uroot -p"$MYSQL_ENV_MYSQL_ROOT_PASSWORD"'`


Or to just execute a command

`docker run -it --network project_default --rm mysql mysql -hmysql56 -uroot -p`

Loading a database file

`docker run -i --network project_default --rm mysql:5.6 mysql -hmysql56 -uroot -ppassword databasename < dbfile.sql`
