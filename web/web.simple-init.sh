function start_web() {
  python3 -u /usr/bin/web.py &
  PIDS[web]=$!
  echo "Started web! (pid: ${PIDS[web]})"
}

function stop_web() {
  local pid=${PIDS[web]}
  if [ ! -z $pid ] && kill -0 $pid 2>/dev/null; then
    kill $pid
  fi
}
