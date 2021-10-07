#!/bin/bash
#
# Copy the assets directory and build the docker image of KBEngine with assets
#

# import global variables of scripts
curr_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $( realpath "$curr_dir/init.sh" )
# TODO: криво. Лучше убрать скрипт тогда в docker папку
source $( realpath "$curr_dir/docker/init.sh" )
curr_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

USAGE="
Usage. Start the docker image of compiled KBEngine with assets. Example:
bash $0 \\
  --kbe-version=7d379b9f-v2.5.12 \\
  --assets-path=/tmp/assets \\
  --assets-version=v0.0.1
"

echo -e "\nParse CLI arguments ..."
version=""
assets_path=""
assets_version=""
help=false
for arg in "$@"
do
    key=$( echo "$arg" | cut -f1 -d= )
    value=$( echo "$arg" | cut -f2 -d= )
    case "$key" in
        --kbe-version)  version=${value} ;;
        --assets-path)  assets_path=${value} ;;
        --assets-version)   assets_version=${value} ;;
        --help)         help=true ;;
        -h)             help=true ;;
        *)
    esac
done

echo "CLI arguments: "
echo "    --kbe-version=$version"
echo "    --assets-path=$assets_path"
echo "    --assets-version=$assets_version"

if [ -z "$version" ] || [ -z "$assets_path" ] || [ -z "$assets_version" ] || [ "$help" = true ]; then
    echo -e "$USAGE"
    exit 1
fi

if [ ! -d "$assets_path" ]; then
    echo "[ERROR] There is NO directory \"$assets_path\""
    echo "$USAGE"
    exit 1
fi

sha=$( echo "$version" | cut -d '-' -f 1 )
echo "The KBEngine commit \"$sha\" is needed. Checking the docker image of compiled KBE (this version) exists ..."
existed=$( docker images --format "{{.Repository}}:{{.Tag}}" \
    | grep "$COMPILED_IMAGE_NAME:$version" )
if [ -z "$existed"  ]; then
    echo -e "[ERROR] There is NO compiled KBEngine with the version \"$version\". Use \"build_kbe.sh\" at first."
    choice_set=$( docker images --format "{{.Tag}} ({{.Repository}}:{{.Tag}})" | grep "$COMPILED_IMAGE_NAME" )
    echo -e "Available kbe versions:\n$choice_set"
    echo "$USAGE"
    exit 1
fi
echo "The compiled KBEngine image exists"

# Tag new pre-assets
bash "$curr_dir/docker/build_pre_assets.sh" "$version"

cd "$PROJECT_DIR"
echo "Start the assets container ..."
# Shell environment variables have priority under environment file
export ASSETS_PATH="$assets_path"
export KBE_IMAGE="$PRE_ASSETS_IMAGE_NAME:$version"
export PROJECT_DIR="$PROJECT_DIR"
export TAG="$ASSETS_IMAGE_NAME-$version:$assets_version"
# TODO: а он точно нужен? Может там просто константой прописать нули
export HOST_ADDR="0.0.0.0"
echo -e "*** Build an image contained compiled KBEngine (from \"$PRE_ASSETS_IMAGE_NAME:$version\") ***"
docker-compose --env-file "$PROJECT_DIR/configs/dev.env" up \
    --force-recreate \
    --build
