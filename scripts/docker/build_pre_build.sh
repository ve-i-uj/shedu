#!/bin/bash
#
# Build a docker image contained build dependencies.
#

set -e

# Import docker/init.sh
curr_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $( realpath "$curr_dir"/init.sh )

echo -e "\n*** Build an image contained prerequisites ($PRE_BUILD_IMAGE_NAME) ***"
docker build \
    --file "$PRE_BUILD_DOCKERFILE_PATH" \
    --tag "$PRE_BUILD_IMAGE_NAME" \
    .
echo -e "*** Done (the docker image contained prerequisites) ***\n"
