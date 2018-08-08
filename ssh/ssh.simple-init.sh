function start_ssh() {
  /usr/sbin/sshd -D &
  PIDS[ssh]=$!
  echo "Started sshd (pid: ${PIDS[ssh]})"
}

function stop_ssh() {
  local pid=${PIDS[ssh]}
  if [ ! -z $pid ] && kill -0 $pid 2>/dev/null; then
    kill $pid
  fi
}
