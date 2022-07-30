#!/bin/bash
# Start the built game.

# Import global constants of the project
curr_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $( realpath "$curr_dir/init.sh" )

USAGE="
bash $0 \\
  --kbe-git-commit=7d379b9f \\
  --kbe-user-tag=v2.5.12 \\
  --assets-path=/tmp/assets \\
  --assets-version=v0.0.1
"

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

assets_version=$( bash $SCRIPTS/misc/get_assets_version_tag.sh $assets_path $assets_version )
kbe_image_tag=$(
    bash $curr_dir/misc/get_kbe_image_tag.sh \
        --kbe-git-commit=$kbe_git_commit \
        --kbe-user-tag=$kbe_user_tag
)
image="$IMAGE_NAME_ASSETS-$kbe_image_tag:$assets_version"

echo "[DEBUG] It needs \"$image\" image. Checking this docker image exists ..."
existed=$(docker images --filter reference="$image" -q)
if [ -z "$existed"  ]; then
    echo -e "[ERROR] There is NO \"$image\" image. Use \"build_assets.sh\" at first."
    choice_set=$(docker images --filter reference="$IMAGE_NAME_ASSETS-*" --format "{{.Repository}}:{{.Tag}}")
    if [ -z "$choice_set" ]; then
        choice_set="(no images)"
    fi
    echo -e "\nAvailable assets images:\n$choice_set"
    echo "$USAGE"
    exit 1
fi
echo "[INFO] The game image exists"

cd "$PROJECT_DIR"
export KBE_ASSETS_IMAGE="$image"
export KBE_ASSETS_CONTAINER_NAME="$KBE_ASSETS_CONTAINER_NAME"
echo "[INFO] Delete old containers ..."
docker-compose rm -fsv
echo "[INFO] Start the assets container (from \"$image\") ..."
docker-compose up -d

echo "[INFO] Done ($0)"
