#!/bin/bash
#
# Build a docker image contained build dependencies.
#

set -e

USAGE="Use the commit sha and the inner build version. Example:\nbash $0 7d379b 7d379b-v2.1.3\n"

# Import docker/init.sh
curr_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $( realpath "$curr_dir"/init.sh )

sha="$1"
version="$2"
from="$LATEST_IMAGE_NAME"

if [ -z "$sha" ] || [ -z "$version" ]; then
    echo -e "$USAGE"
    exit 1
fi

echo "*** Build an image contained source code of KBEngine (from \"$LATEST_IMAGE_NAME\") ***"
docker build \
    --file "$SRC_DOCKERFILE_PATH" \
    --build-arg FROM_IMAGE_NAME="$from" \
    --build-arg COMMIT_SHA="$sha" \
    --tag "$SRC_IMAGE_NAME:$version" \
    .
echo -e "*** Done (KBEngine source code image) ***\n"
