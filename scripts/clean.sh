#!/bin/bash
# Delete all containers, volumes and intermediate containers.

# Import global constants of the project
curr_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $( realpath "$curr_dir/init.sh" )

docker-compose down -v
images=$( docker images | grep "shedu/kbe-" | awk '{print $1 ":" $2}' )
if [ -n "$images" ]; then
    echo "$images" | xargs docker rmi -f
fi
dangling=$( docker images --all --filter "dangling=true" --quiet )
if [ -n "$dangling" ]; then
    echo "$dangling" | xargs docker rmi -f
fi
