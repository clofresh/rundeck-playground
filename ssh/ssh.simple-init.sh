function start_ssh() {
  /usr/sbin/sshd -D &
  PIDS[ssh]=$!
  echo "Started sshd (pid: ${PIDS[ssh]})"
}
