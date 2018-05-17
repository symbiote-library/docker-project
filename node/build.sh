#!/bin/sh

docker build -t symbiote/node:8.11 .

# and the latest tag also
docker build -t symbiote/node .