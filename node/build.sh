#!/bin/sh

docker build -t symbiote/node:10.15 ./10.15/

# and the latest tag also
docker build -t symbiote/node ./10.15/