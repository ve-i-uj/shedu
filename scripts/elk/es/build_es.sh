#!/bin/bash

# Import global constants of the project
curr_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source "$( realpath "$curr_dir/../../init.sh" )"

cd "$PROJECT_DIR"
docker pull $ELK_ES_IMAGA_NAME
docker tag $ELK_ES_IMAGA_NAME "$ELK_ES_IMAGE_TAG"
echo "The image \"$ELK_ES_IMAGE_TAG\" have been created"
