#!/bin/bash
#
# Delete all containers and volumes
#


# import global variables of scripts
curr_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $( realpath "$curr_dir/init.sh" )

docker-compose --env-file "$PROJECT_DIR/configs/dev.env" down -v
images=$( docker images | grep "shedu/kbe-" | awk '{print $1 ":" $2}' )
if [ -n "$images" ]; then
    echo "$images" | xargs docker rmi -f
fi
dangling=$( docker images --all --filter "dangling=true" --quiet )
if [ -n "$dangling" ]; then
    echo "$dangling" | xargs docker rmi -f
fi
