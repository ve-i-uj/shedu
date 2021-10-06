#!/bin/bash
#
# Build a docker image contained built KBEngine.
#

# Import docker/init.sh
curr_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $( realpath "$curr_dir"/../init.sh )

USAGE="\nUse name of the \"$SRC_IMAGE_NAME:<YOUR SUFFIX>\" image in the first argument. Example:\nbash $0 $SRC_IMAGE_NAME:7d379b\n"

from="$1"

if [ -z "$from" ]; then
    echo -e "$USAGE"
    exit 1
fi

suffix=$( echo "$from" | cut -c $(( ${#SRC_IMAGE_NAME} + 2 ))- )
echo -e "*** Build an image contained compiled KBEngine (from '$from', suffix = $suffix) ***"
docker build \
    --file "$COMPILED_DOCKERFILE_PATH" \
    --build-arg FROM_IMAGE_NAME="$from" \
    --tag "$COMPILED_IMAGE_NAME:$suffix" \
    .
echo -e "*** Done (the docker image of KBEngine compiled code) ***\n"
