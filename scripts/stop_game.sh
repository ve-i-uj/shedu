#!/bin/bash
# Stop the game.

# Import global constants of the project
curr_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $( realpath "$curr_dir/init.sh" )

docker-compose stop kbe-assets 2>/dev/null
docker-compose stop kbe-mariadb 2>/dev/null
