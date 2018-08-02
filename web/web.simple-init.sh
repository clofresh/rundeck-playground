function start_web() {
  /usr/bin/web.py &
  PIDS[web]=$!
  echo "Started web! (pid: ${PIDS[web]})"
}
