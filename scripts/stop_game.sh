#!/bin/bash
# Stop the game.

# Import global constants of the project
curr_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $( realpath "$curr_dir/init.sh" )

# We don't need containers because the db has its own docker volume
# and apps don't store state.
echo "Delete containers ..."
docker-compose rm -fsv
