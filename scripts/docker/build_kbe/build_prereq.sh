#!/bin/bash
#
# Build a docker image contained build dependencies.
#

set -e

# Import docker/init.sh
curr_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $( realpath "$curr_dir"/../init.sh )

echo -e "\n*** Build an image contained prerequisites ***"
docker build \
    --file "$PREREQS_DOCKERFILE_PATH" \
    --tag "$PREREQS_IMAGE_NAME" \
    .
echo -e "*** Done (the docker image contained prerequisites) ***\n"
