#!/bin/bash
# Build a Kibana image

# Import global constants of the project
curr_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $( realpath "$curr_dir/../../init.sh" )

docker pull $ELK_KIBANA_IMAGA_NAME
docker tag $ELK_KIBANA_IMAGA_NAME "$ELK_KIBANA_IMAGE_TAG"
echo "The image \"$ELK_KIBANA_IMAGE_TAG\" have been created"
