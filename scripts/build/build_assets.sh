#!/bin/bash

# Import global constants of the project
curr_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $( realpath "$curr_dir/../init.sh" )

USAGE="
Usage. Build a docker image of compiled KBEngine with assets (game logic). Example:
bash $0 \\
  --kbe-git-commit=7d379b9f \\
  --kbe-user-tag=v2.5.12 \\
  --assets-path=/tmp/assets \\
  --assets-version=v0.0.1 \\
  --env-file=$PROJECT_DIR/.env
"

echo "[DEBUG] Parse CLI arguments ..."
kbe_git_commit=""
kbe_user_tag=""
assets_path=""
assets_version=""
env_file=""
help=false
for arg in "$@"
do
    key=$( echo "$arg" | cut -f1 -d= )
    value=$( echo "$arg" | cut -f2 -d= )
    case "$key" in
        --kbe-git-commit)  kbe_git_commit=${value} ;;
        --kbe-user-tag)  kbe_user_tag=${value} ;;
        --assets-path)  assets_path=${value} ;;
        --assets-version)   assets_version=${value} ;;
        --env-file)   env_file=${value} ;;
        --help)         help=true ;;
        -h)             help=true ;;
        *)
    esac
done

if [ "$help" = true ]; then
    echo -e "$USAGE"
    exit 0
fi

echo "\
[DEBUG] Command: $0 --kbe-git-commit=$kbe_git_commit \
--kbe-user-tag=$kbe_user_tag --assets-path=$assets_path \
--assets-version=$assets_version --env-file=$env_file"

if [ -z "$kbe_git_commit" ] || [ -z "$assets_path" ] \
        || [ -z "$assets_version" ] || [ -z "$env_file" ]; then
    echo "[ERROR] Not all arguments passed" >&2
    echo -e "$USAGE"
    exit 1
fi

if [ "$assets_path" == "demo" ]; then
    echo "[WARNING] The game will be created based on demo assets"
    assets_version=$( bash "$SCRIPTS/misc/get_assets_version_tag.sh" $assets_path $assets_version )
    assets_path=/tmp/kbe-demo-assets
    if [ -d "$assets_path" ]; then
        rm -rf "$assets_path"
    fi
    echo "[INFO] Download the demo assets ..."
    git clone "$KBE_ASSETS_DEMO_URL" $assets_path
fi

if [ ! -d "$assets_path" ]; then
    echo "[ERROR] There is NO directory \"$assets_path\"" >&2
    echo "$USAGE"
    exit 1
fi

echo "[INFO] Checking the docker images containing pre-assets ..."
kbe_pre_assets_tag="$IMAGE_NAME_PRE_ASSETS:$($SCRIPTS/version/get_version.sh)"

existed=$( docker images --format "{{.Repository}}:{{.Tag}}" | grep "$kbe_pre_assets_tag" )
if [ -z "$existed"  ]; then
    echo -e "[ERROR] There is NO pre-assets image \"$kbe_pre_assets_tag\". Build pre-assets af first. Exit"
    exit 1
fi
echo "[INFO] The \"$kbe_pre_assets_tag\" image exists"

echo "[INFO] Check the compiled kbengine image ..."
kbe_image_tag=$(
    bash $SCRIPTS/misc/get_kbe_image_tag.sh \
        --kbe-git-commit=$kbe_git_commit \
        --kbe-user-tag=$kbe_user_tag
) 2>/dev/null
kbe_compiled_tag="$IMAGE_NAME_KBE_COMPILED:$kbe_image_tag"
existed=$( docker images --format "{{.Repository}}:{{.Tag}}" | grep "$kbe_compiled_tag" )
if [ -z "$existed"  ]; then
    echo "[ERROR] There is NO compiled KBEngine \"$kbe_compiled_tag\". Build compiled kbe at first." >&2
    exit 1
fi
echo "[INFO] The \"$kbe_compiled_tag\" image exists"

cd "$assets_path"
docker build \
    --file "$DOCKERFILE_KBE_ASSETS" \
    --build-arg IMAGE_NAME_KBE_COMPILED="$kbe_compiled_tag" \
    --build-arg IMAGE_NAME_PRE_ASSETS="$kbe_pre_assets_tag" \
    --build-arg ENV_FILE="$env_file" \
    --tag "$IMAGE_NAME_ASSETS-$kbe_image_tag:$assets_version" \
    .

echo "Done ($0)"
