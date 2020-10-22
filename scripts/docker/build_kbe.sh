#!/bin/bash
#
# Build a docker image of KBEngine
#

# import global variables of scripts
curr_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source `realpath $curr_dir/../init.sh`
source `realpath $curr_dir/init.sh`

echo 
echo "DOCKERFILES_DIR=$DOCKERFILES_DIR"
echo

echo
echo "*** Build an image contained prerequisites ***"
echo

cd $DOCKERFILES_DIR/kbengine/$PREQS_DIR
docker build -t $PREREQS_IMAGE_NAME .

from=$PREREQS_IMAGE_NAME
echo
echo "*** Build an image contained source code of KBEngine (from '$from') ***"
echo

cd $DOCKERFILES_DIR/kbengine/$SRC_DIR
docker build --build-arg FROM_IMAGE_NAME=$from -t $SRC_IMAGE_NAME .

from=$SRC_IMAGE_NAME
echo
echo "*** Build an image contained compiled KBEngine (from '$from') ***"
echo
cd $DOCKERFILES_DIR/kbengine/$COMPILED_DIR
docker build --build-arg FROM_IMAGE_NAME=$from -t $COMPILED_IMAGE_NAME .

