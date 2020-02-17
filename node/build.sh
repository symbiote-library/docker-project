#!/bin/sh

docker build -t symbiote/node:12.10 .

# and the latest tag also
docker build -t symbiote/node .