set -e

curr_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $( realpath "$curr_dir"/../init.sh )

log info "* Check KBE build process ($0)"

log debug "Check the root Makefile"
make hello
log debug "Clear all projects"
make clean_all

log debug "Check KBE build process"
cp configs/example.env .env
make build_kbe

log debug "Clear built kbe"
make clean_kbe

log info "Ok ($0)"
