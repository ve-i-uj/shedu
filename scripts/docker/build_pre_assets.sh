#!/bin/bash
# Creates a docker image containing the compiled KBEngine image + deploy scripts.
#
# The real assets will be changed at build time (for example, the network
# settings for working with the docker environment will be changed).
# There are scripts in the project to make these changes.
# But assets can be outside the context of Shedu. Therefore, to copy assets
# to the image, a context change is used (via docker-compose). But after
# switching the context, there is no way to copy the scripts from Shedu.
# Therefore, scripts are copied into the image in advance, and assets will be
# connected to this image later.

set -e

# Import docker/init.sh
curr_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $( realpath "$curr_dir"/init.sh )

USAGE="Creates a docker image containing the compiled KBEngine image + deploy scripts.

Use version of the \"$COMPILED_IMAGE_NAME:<YOUR SUFFIX>\" image in the first argument. Example:
bash $0 7d379b9f-v2.5.12
"

kbe_compiled="$COMPILED_IMAGE_NAME:$1"

if [ -z "$kbe_compiled" ]; then
    echo -e "$USAGE"
    exit 1
fi

suffix=$( echo "$kbe_compiled" | cut -c $(( ${#COMPILED_IMAGE_NAME} + 2 ))- )
echo "*** Build an image contained kbengine pre-assets (from \"$kbe_compiled\", suffix = \"$suffix\") ***"
docker build \
    --file "$PRE_ASSETS_DOCKERFILE_PATH" \
    --build-arg FROM_IMAGE_NAME="$kbe_compiled" \
    --build-arg SCRIPTS_DIR="dockerfiles/kbengine/kbe-assets/deploy-scripts" \
    --tag "$PRE_ASSETS_IMAGE_NAME:$suffix" \
    "$PROJECT_DIR"

#    --build-arg SCRIPTS_DIR="./dockerfiles/kbengine/kbe-assets/deploy-scripts"