set -e

curr_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $( realpath "$curr_dir"/../init.sh )

make stop
make clean_all

make build_kbe
make build_game

make game_is_built

log info "Ok ($0)"
