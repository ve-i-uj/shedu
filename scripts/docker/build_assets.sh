#!/bin/bash
#
# Build a docker image of KBEngine with assets
#

set -e

# import global variables of scripts
curr_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $( realpath "$curr_dir/init.sh" )

USAGE="Build an executable docker image of compiled KBEngine with assets. Example:

bash $0 \\
  --kbe-pre-assets=$PRE_ASSETS_IMAGE_NAME:7d379b9f-v2.5.12 \\
  --assets-path=/tmp/assets \\
  --assets-tag=v0.0.1
"

echo "Parse CLI arguments ..."
kbe_compiled=""
assets_path=""
assets_tag=""
help=false
for arg in "$@"
do
    key=$( echo "$arg" | cut -f1 -d= )
    value=$( echo "$arg" | cut -f2 -d= )
    case "$key" in
        --kbe-pre-assets) kbe_compiled=${value} ;;
        --assets-path)  assets_path=${value} ;;
        --assets-tag)   assets_tag=${value} ;;
        --help)         help=true ;;
        -h)             help=true ;;
        *)
    esac
done

if [ -z "$kbe_compiled" ] || [ -z "$assets_path" ] || [ -z "$assets_tag" ] || [ "$help" = true ]; then
    echo "$USAGE"
    exit 1
fi

echo "CLI arguments: "
echo "    --kbe-pre-assets=$kbe_compiled"
echo "    --assets-path=$assets_path"
echo "    --assets-tag=$assets_tag"

# Add prefix to the user tag if it is
if [ -n "$assets_tag" ]; then
    assets_tag="-$assets_tag"
fi

suffix=$( echo "$kbe_compiled" | cut -c $(( ${#PRE_ASSETS_IMAGE_NAME} + 2 ))- )
echo "*** Build an image contained kbengine assets (from \"$kbe_compiled\", suffix = \"$suffix\") ***"
cd "$assets_path"
docker build \
    --file "$ASSETS_DOCKERFILE_PATH" \
    --build-arg FROM_IMAGE_NAME="$kbe_compiled" \
    --build-arg HOST_ADDR="0.0.0.0" \
    --tag "$ASSETS_IMAGE_NAME:$suffix$assets_tag" \
    .

echo "Done"
