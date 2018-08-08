function start_web() {
  /usr/bin/web &
  PIDS[web]=$!
  echo "Started web (pid: ${PIDS[web]})"
}
