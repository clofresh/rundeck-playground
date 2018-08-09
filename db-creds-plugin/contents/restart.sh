#!/bin/bash

NAME=$1
HEALTH_URL=$2

APP_PID=$(pgrep $NAME)
echo "Restarting $NAME app"
kill -HUP 1
if [ -z $APP_PID ]; then
    echo "App wasn't running"
else
    echo "Waiting for app to stop"
    while kill -0 $APP_PID 2>/dev/null; do
        sleep 1
    done
fi
echo "Waiting for app to start and return 200"
START_TIME=$(date +%s)
TIMEOUT=10
ELAPSED=0
TIMED_OUT=0
until [ $(curl -s -o /dev/null $HEALTH_URL -w "%{http_code}") == "200" ]; do
    if [ $(( $(date +%s) - $START_TIME  )) -gt $TIMEOUT ]; then
        echo "Took too long starting up, exiting"
        exit 1
    fi
    sleep 1
done
echo "Done"
