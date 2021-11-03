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

assets_image=$( bash "$curr_dir/list_images.sh" | grep "$ASSETS_IMAGE_NAME" | head -n 1 )
if [ -z "$assets_image" ]; then
    echo "[ERROR] No assets image. Build the game image at first"
    exit 1
fi

container_id=$( docker ps --filter name=kbe-assets --filter status=running -q )
if [ -z "$container_id" ]; then
    echo "[ERROR] No running game container. Start the game at first"
    exit 1
fi

docker exec --interactive --tty "$container_id" /bin/bash
