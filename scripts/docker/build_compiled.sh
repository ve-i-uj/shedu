#!/bin/bash
#
# Build a docker image contained built KBEngine.
#

set -e

# Import docker/init.sh
curr_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $( realpath "$curr_dir"/init.sh )

USAGE="\nUse name of the \"$SRC_IMAGE_NAME:<YOUR SUFFIX>\" image in the first argument. Example:\nbash $0 $SRC_IMAGE_NAME:7d379b\n"

version="$1"
from="$SRC_IMAGE_NAME:$version"

if [ -z "$from" ]; then
    echo -e "$USAGE"
    exit 1
fi

echo -e "*** Build an image contained compiled KBEngine (from \"$from\", version = \"$version\") ***"
docker build \
    --file "$COMPILED_DOCKERFILE_PATH" \
    --build-arg FROM_IMAGE_NAME="$from" \
    --tag "$COMPILED_IMAGE_NAME:$version" \
    .
echo -e "*** Done (the docker image of KBEngine compiled code) ***\n"
