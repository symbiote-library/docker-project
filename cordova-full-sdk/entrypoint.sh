#!/bin/bash

adb start-server

exec "$@"