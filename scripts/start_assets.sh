#!/bin/bash
#
# Copy the assets directory and build the docker image of KBEngine with assets
#

# import global variables of scripts
curr_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $( realpath "$curr_dir/init.sh" )
# TODO: криво. Лучше убрать скрипт тогда в docker папку
source $( realpath "$curr_dir/docker/init.sh" )

USAGE="Start the docker image of compiled KBEngine with assets. Example:

bash $0 \\
  --version=7d379b9f-v2.5.12 \\
  --assets-path=/tmp/assets \\
  --assets-tag=v0.0.1
"

echo "Parse CLI arguments ..."
version=""
assets_path=""
assets_tag=""
help=false
for arg in "$@"
do
    key=$( echo "$arg" | cut -f1 -d= )
    value=$( echo "$arg" | cut -f2 -d= )
    case "$key" in
        --version) version=${value} ;;
        --assets-path)  assets_path=${value} ;;
        --assets-tag)   assets_tag=${value} ;;
        --help)         help=true ;;
        -h)             help=true ;;
        *)
    esac
done

if [ -z "$version" ] || [ -z "$assets_path" ] || [ -z "$assets_tag" ] || [ "$help" = true ]; then
    echo "$USAGE"
    exit 1
fi

echo "CLI arguments: "
echo "    --version=$version"
echo "    --assets-path=$assets_path"
echo "    --assets-tag=$assets_tag"

cd "$PROJECT_DIR"
echo "Start the assets container ..."
# Shell environment variables have priority under environment file
export ASSETS_PATH="$assets_path"
export KBE_IMAGE="$PRE_ASSETS_IMAGE_NAME:$version"
export PROJECT_DIR="$PROJECT_DIR"
export VERSION="$version"
# TODO: а он точно нужен? Может там просто константой прописать нули
export HOST_ADDR="0.0.0.0"
echo -e "*** Build an image contained compiled KBEngine (from \"$PRE_ASSETS_IMAGE_NAME:$version\") ***"
docker-compose --env-file "$PROJECT_DIR/configs/dev.env" up \
    --force-recreate \
    --build
