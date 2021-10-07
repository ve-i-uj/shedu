#!/bin/bash
#
# Build latest kbengine version.
#

set -e

# Import docker/init.sh
curr_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $( realpath "$curr_dir"/init.sh )

echo "*** Build an image contained latest KBEngine code (from \"$PRE_BUILD_IMAGE_NAME\") ***"
docker build \
    --file "$LATEST_DOCKERFILE_PATH" \
    --build-arg FROM_IMAGE_NAME="$PRE_BUILD_IMAGE_NAME" \
    --tag "$LATEST_IMAGE_NAME" \
    .
echo -e "*** Done (KBEngine source code image) ***\n"
