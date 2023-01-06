#!/bin/bash

set -e

# Import global constants of the project
curr_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $( realpath "$curr_dir/../init.sh" )

USAGE="
Usage. Build a docker image of compiled KBEngine with assets (game logic). Example:
bash $0 \\
  --assets-sha=81f7249b \\
  --assets-path=/tmp/assets \\
  --assets-version=v0.0.1 \\
  --env-file=$PROJECT_DIR/.env \\
  --kbengine-xml-args=root.dbmgr.account_system.account_registration.loginAutoCreate=true;root.whatever=123 \\
  --kbe-compiled-image-tag-sha=0b27c18a
"

assets_sha=""
assets_path=""
assets_version=""
env_file=""
kbengine_xml_args=""
kbe_compiled_image_tag_sha=""
help=false
for arg in "$@"
do
    key=$( echo "$arg" | cut -f1 -d= )
    value=$( echo "$arg" | cut -f2- -d= )
    case "$key" in
        --assets-sha)  assets_sha=${value} ;;
        --assets-path)  assets_path=${value} ;;
        --assets-version)   assets_version=${value} ;;
        --env-file)   env_file=${value} ;;
        --kbengine-xml-args)   kbengine_xml_args=${value} ;;
        --kbe-compiled-image-tag-sha)   kbe_compiled_image_tag_sha=${value} ;;
        --help)         help=true ;;
        -h)             help=true ;;
        *)
    esac
done

if [ "$help" = true ]; then
    echo -e "$USAGE"
    exit 0
fi

if [ -z "$assets_path" ] || [ -z "$assets_version" ] || [ -z "$env_file" ] \
        || [ -z "$kbe_compiled_image_tag_sha" ]; then
    echo "[ERROR] Not all arguments passed" >&2
    echo -e "$USAGE"
    exit 1
fi

if [ "$assets_path" == "demo" ]; then
    echo "[WARNING] The game will be created based on demo assets"
    assets_path=/tmp/kbe-demo-assets
    if [ -d "$assets_path" ]; then
        rm -rf "$assets_path"
    fi
    echo "[INFO] Download the demo assets"
    git clone "$KBE_ASSETS_DEMO_URL" $assets_path
fi

if [ ! -d "$assets_path" ]; then
    echo "[ERROR] There is NO directory \"$assets_path\"" >&2
    echo "$USAGE"
    exit 1
fi

echo "[INFO] Checking the docker images containing pre-assets ..."
kbe_pre_assets_image_name="$PRE_ASSETS_IMAGE_NAME:$($SCRIPTS/version/get_version.sh)"
if [ -z "$( docker images --filter reference="$kbe_pre_assets_image_name" -q )" ]; then
    echo -e "[ERROR] There is NO pre-assets image \"$kbe_pre_assets_image_name\". Build pre-assets af first"
    exit 1
fi
echo "[INFO] The \"$kbe_pre_assets_image_name\" image exists"

kbe_compiled_image="$KBE_COMPILED_IMAGE_NAME:$kbe_compiled_image_tag_sha"
echo "[INFO] Check the compiled kbengine image \"$kbe_compiled_image\""
if [ -z "$( docker images --filter reference="$kbe_compiled_image" -q )" ]; then
    echo "[ERROR] There is NO compiled KBEngine \"$kbe_compiled_image\". Build compiled kbe at first"
    exit 1
fi
echo "[INFO] The \"$kbe_compiled_image\" image exists"

cd "$assets_path"
docker build \
    --file "$DOCKERFILE_KBE_ASSETS" \
    --build-arg KBE_COMPILED_IMAGE_NAME="$kbe_compiled_image" \
    --build-arg PRE_ASSETS_IMAGE_NAME="$kbe_pre_assets_image_name" \
    --build-arg KBE_ASSETS_SHA="$assets_sha" \
    --build-arg ENV_FILE="$env_file" \
    --build-arg KBENGINE_XML_ARGS="$kbengine_xml_args" \
    --tag "$ASSETS_IMAGE_NAME:$assets_version" \
    .

echo "Done ($0)"
