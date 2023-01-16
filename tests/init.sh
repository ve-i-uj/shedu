curr_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $( realpath "$curr_dir/../scripts/init.sh" )

DEBUG=1
source $SCRIPTS/log.sh

TESTS="$PROJECT_DIR/tests"

cp "$PROJECT_DIR/configs/example.env" "$PROJECT_DIR/.env"
