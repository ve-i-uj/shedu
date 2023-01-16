set -e

curr_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $( realpath "$curr_dir"/../init.sh )

make stop
make clean_all

make game_is_not_built

make build_kbe
make game_is_not_built

log info "Ok ($0)"
