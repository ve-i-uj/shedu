#!/bin/bash
# Build a kbengine docker image contained assets.
#
# It binds "assets" with the built kbengine image.

# Import global constants of the project
curr_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $( realpath "$curr_dir/init.sh" )

USAGE="
Usage. Build a docker image of compiled KBEngine with assets (game logic). Example:
bash $0 \\
  --kbe-version=7d379b9f-v2.5.12 \\
  --assets-path=/tmp/assets \\
  --assets-version=v0.0.1
"

echo -e "*** Build a docker image of compiled KBEngine with assets ***"

echo "[DEBUG] Parse CLI arguments ..."
kbe_version=""
assets_path=""
assets_version=""
help=false
for arg in "$@"
do
    key=$( echo "$arg" | cut -f1 -d= )
    value=$( echo "$arg" | cut -f2 -d= )
    case "$key" in
        --kbe-version)  kbe_version=${value} ;;
        --assets-path)  assets_path=${value} ;;
        --assets-version)   assets_version=${value} ;;
        --help)         help=true ;;
        -h)             help=true ;;
        *)
    esac
done

if [ "$help" = true ]; then
    echo -e "$USAGE"
    exit 0
fi

echo "[DEBUG] Command: $0 --kbe-version=$kbe_version --assets-path=$assets_path --assets-version=$assets_version" &>2

if [ -z "$kbe_version" ] || [ -z "$assets_path" ] || [ -z "$assets_version" ]; then
    echo "[ERROR] Not all arguments passed" >&2
    echo -e "$USAGE"
    exit 1
fi

if [ "$assets_path" == "demo" ]; then
    echo "[INFO] The game will be created based on demo assets"
    assets_path=/tmp/kbe-demo-assets
    if [ -d "$assets_path" ]; then
        rm -rf /tmp/kbe-demo-assets
    fi
    git clone "$ASSETS_DEMO_URL" $assets_path
fi

if [ ! -d "$assets_path" ]; then
    echo "[ERROR] There is NO directory \"$assets_path\"" >&2
    echo "$USAGE"
    exit 1
fi

sha=$( echo "$kbe_version" | cut -d '-' -f 1 )
echo "The KBEngine commit \"$sha\" is needed. Checking the docker image of compiled KBE (this version) exists ..."
existed=$( docker images --format "{{.Repository}}:{{.Tag}}" \
    | grep "$PRE_ASSETS_IMAGE_NAME:$kbe_version" )
if [ -z "$existed"  ]; then
    echo -e "[ERROR] There is NO compiled KBEngine with the version \"$kbe_version\". Build compiled kbe at first." >&2
    choice_set=$( docker images --format "{{.Tag}} ({{.Repository}}:{{.Tag}})" | grep "$PRE_ASSETS_IMAGE_NAME" )
    echo -e "\nAvailable kbe versions:\n$choice_set"
    echo "$USAGE"
    exit 1
fi
echo "The compiled KBEngine image exists"

cd "$assets_path"
docker build \
    --file "$ASSETS_DOCKERFILE_PATH" \
    --build-arg FROM_IMAGE_NAME="$PRE_ASSETS_IMAGE_NAME:$kbe_version" \
    --tag "$ASSETS_IMAGE_NAME-$kbe_version:$assets_version" \
    .

echo "Done ($0)"
