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

Please use the same docker-compose.yml for your project, and adjust as needed
on a per-project basis. Note that it will _not_ be necessary in every case to
run _all_ the associated services. 


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
