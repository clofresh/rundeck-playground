function start_web() {
  nodejs /usr/local/lib/web.js &
  PIDS[web]=$!
  echo "Started web (pid: ${PIDS[web]})"
}

function stop_web() {
  local pid=${PIDS[web]}
  if [ ! -z $pid ] && kill -0 $pid 2>/dev/null; then
    kill $pid
  fi
}
