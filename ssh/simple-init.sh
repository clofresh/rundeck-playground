#!/bin/bash

declare -A PIDS

RUN=1

function start() {
  RUN=0
  for f in /etc/simple-init.d/*; do
    app=$(basename $f)
    stop_${app}
    source $f
    start_${app}
  done
  RUN=1
}
trap 'start' SIGHUP

function cleanup() {
    RUN=0
    echo "Terminating"
    kill ${PIDS[@]}
    wait ${PIDS[@]}
    exit 0
}
trap 'cleanup' SIGTERM SIGINT

function main() {
  start

  while [ $RUN -eq 1 ]; do
    wait -n ${PIDS[@]}
    CHILD_EXIT=$?
    if [ $RUN -eq 1 ]; then
      for app in "${!PIDS[@]}"; do
        if ! kill -0 ${PIDS[$app]} 2> /dev/null; then
          echo "$app exited with code $CHILD_EXIT. Restarting"
          start_${app}
          break
        fi
      done
    fi
  done
}

main
