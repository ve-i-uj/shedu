#!/bin/bash
# Tail the game logs.

# Import global constants of the project
curr_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $( realpath "$curr_dir"/../init.sh )

bash "$curr_dir/is_running.sh"
if [ "$?" -ne 0 ]; then
    exit 1
fi

cd "$PROJECT_DIR"
docker-compose logs --timestamps --follow
