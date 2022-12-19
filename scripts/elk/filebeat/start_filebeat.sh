#!/bin/bash

# Import global constants of the project
curr_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $( realpath "$curr_dir/../../init.sh" )

echo "Start the \"$ELK_FILEBEAT_IMAGE_TAG\" image"
cd $curr_dir
    # -p 127.0.0.1:9200:9200 \
docker run --rm \
    -it \
    --network host \
    --entrypoint /bin/bash \
    --name "$ELK_FILEBEAT_CONTATINER_NAME" \
    $ELK_FILEBEAT_IMAGE_TAG
