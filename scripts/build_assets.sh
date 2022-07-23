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
  --kbe-git-commit=7d379b9f \\
  --kbe-user-tag=v2.5.12 \\
  --assets-path=/tmp/assets \\
  --assets-version=v0.0.1
"

echo -e "*** Build a docker image of compiled KBEngine with assets ***"

echo "[DEBUG] Parse CLI arguments ..."
kbe_git_commit=""
kbe_user_tag=""
assets_path=""
assets_version=""
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
        --help)         help=true ;;
        -h)             help=true ;;
        *)
    esac
done

if [ "$help" = true ]; then
    echo -e "$USAGE"
    exit 0
fi

echo "[DEBUG] Command: $0 --kbe-git-commit=$kbe_git_commit --kbe-user-tag=$kbe_user_tag --assets-path=$assets_path --assets-version=$assets_version"

if [ -z "$kbe_git_commit" ] || [ -z "$assets_path" ] || [ -z "$assets_version" ]; then
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
    git clone "$ASSETS_DEMO_URL" $assets_path
    assets_version="kbe-demo-$assets_version"
fi

if [ ! -d "$assets_path" ]; then
    echo "[ERROR] There is NO directory \"$assets_path\"" >&2
    echo "$USAGE"
    exit 1
fi

echo "Checking the docker images containing compiled KBE ..."
kbe_tag=$(bash $PROJECT_DIR/scripts/misc/get_kbe_image_tag.sh --git-commit=$kbe_git_commit --user-tag=$kbe_user_tag)
sha=$( echo "$kbe_tag" | cut -d '-' -f 1 )
existed=$( docker images --format "{{.Repository}}:{{.Tag}}" | grep "$sha" )
if [ -z "$existed"  ]; then
    echo -e "[ERROR] There is NO compiled KBEngine with the version \"$kbe_tag\". Build compiled kbe at first." >&2
    choice_set=$( docker images --format "{{.Tag}} ({{.Repository}}:{{.Tag}})" | grep "$PRE_ASSETS_IMAGE_NAME" )
    echo -e "\nAvailable kbe versions:\n$choice_set"
    echo "$USAGE"
    exit 1
fi
echo "The compiled KBEngine image exists"

cd "$assets_path"
docker build \
    --file "$ASSETS_DOCKERFILE_PATH" \
    --build-arg FROM_IMAGE_NAME="$PRE_ASSETS_IMAGE_NAME:$kbe_tag" \
    --tag "$ASSETS_IMAGE_NAME-$kbe_tag:$assets_version" \
    .

echo "Done ($0)"
