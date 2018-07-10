#!/bin/sh

docker build -t symbiote/cordova:8.0 .

# and the latest tag also
docker build -t symbiote/cordova .