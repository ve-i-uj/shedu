#!/bin/bash
#
# Delete all containers and volumes
#


# import global variables of scripts
curr_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $( realpath "$curr_dir/init.sh" )

docker-compose --env-file "$PROJECT_DIR/configs/dev.env" down -v
