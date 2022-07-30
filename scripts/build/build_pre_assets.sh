#!/bin/bash

USAGE="
Usage. Build a docker image contained deploy utilites. Example:
bash $0
"

# Import global constants of the project
curr_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $( realpath "$curr_dir/../init.sh" )

cd "$PROJECT_DIR"
tag="$IMAGE_NAME_PRE_ASSETS:$($SCRIPTS/version/get_version.sh)"
echo "[INFO] Build the \"$tag\" image ..."
docker build \
    --file "$DOCKERFILE_PRE_ASSETS" \
    --tag "$tag" \
    .

echo "[INFO] Done ($0)"
