#!/bin/bash
# The script connects to the running game container.

# Import global constants of the project
curr_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $( realpath "$curr_dir"/../init.sh )

# There is the only one game container. The game state are stored in the database
# and no need to have a persistent game container. We use the game image
# to create a game container on start. Stopped game container can exist
# like the result of unexpected stopping but an assets container is one-off
# and it will be deleted on the next start.
bash "$curr_dir/is_running.sh"
if [ "$?" -ne 0 ]; then
    exit 1
fi

docker exec --interactive --tty "$CONTAINER_NAME" /bin/bash
