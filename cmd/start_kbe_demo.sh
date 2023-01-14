curr_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $( realpath "$curr_dir/../scripts/init.sh" )

cd "$PROJECT_DIR"

make stop
cp configs/kbe-v2.5.12-demo.env .env
make build
make start
make logs_console
