#!/bin/sh

docker build -t symbiote/cordova-full-sdk:8.0 .

# and the latest tag also
docker build -t symbiote/cordova-full-sdk .