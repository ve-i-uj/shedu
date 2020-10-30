#!/bin/bash
#
# Build a docker image of KBEngine with assets
#

# import global variables of scripts
curr_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source `realpath $curr_dir/../init.sh`
source `realpath $curr_dir/init.sh`

from=$COMPILED_IMAGE_NAME
echo
echo "*** Build an image contained compiled KBEngine (from '$from') ***"
echo
cd $DOCKERFILES_DIR/kbengine/$ASSETS_DIR
docker build --build-arg FROM_IMAGE_NAME=$from -t $ASSETS_IMAGE_NAME:latest .

# TODO: version of assets in a tag

