BASE_DIR="$(cd $(dirname $BASH_SOURCE) && pwd)"

alias rd="$BASE_DIR/tools/rd-0.1.0-SNAPSHOT/bin/rd"
alias rundeck-plugin-bootstrap="$BASE_DIR/tools/rundeck-plugin-bootstrap-0.1.0-SNAPSHOT/bin/rundeck-plugin-bootstrap"

export RD_URL=http://127.0.0.1:4440
export RD_USER=admin
export RD_PASSWORD=admin
export RD_ENABLE_PLUGINS=true
