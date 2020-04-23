# Symbiote PHP FPM

## Build

`docker build -t symbiote/php-fpm:7.1`

## Run

It is highly recommended to run this from a docker-compose alongside 
symbiote/php-fpm, as the default vhost configs reference the "php" 
hostname created by docker

```
version: '2'
services:
  apache:
    image: "symbiote/apache2:latest"
    ports:
      - "80:80"
      - "443:443"
    links:
      - php:php
    working_dir: /var/www/html
    volumes:
      - .:/var/www/html
  php:
    image: "symbiote/php-fpm:7.1"
    volumes:
      - '.:/var/www/html'

```
