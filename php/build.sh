#!/bin/sh

docker build -t symbiote/php-fpm:7.1 .

# and the latest tag also
docker build -t symbiote/php-fpm .