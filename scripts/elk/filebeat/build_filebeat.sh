#!/bin/bash

# Import global constants of the project
curr_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $( realpath "$curr_dir/../../init.sh" )

echo "Build the \"$ELK_FILEBEAT_IMAGE_TAG\" image (Dockerfile = \"$ELK_FILEBEAT_DOCKERFILE\")"
cd $curr_dir
docker build -f "$ELK_FILEBEAT_DOCKERFILE" -t $ELK_FILEBEAT_IMAGE_TAG .
echo "The \"$ELK_FILEBEAT_IMAGE_TAG\" image has been built"
