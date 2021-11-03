#!/bin/bash
# Check the game is running.

# Import global constants of the project
curr_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $( realpath "$curr_dir"/../init.sh )

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

exit 0
