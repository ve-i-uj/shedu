#!/bin/bash
# Delete all containers, volumes and intermediate containers.

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

assets_version=$( bash "$SCRIPTS/misc/get_assets_version_tag.sh" $assets_path $assets_version )
kbe_image_tag=$(
    bash $curr_dir/misc/get_kbe_image_tag.sh \
        --kbe-git-commit=$kbe_git_commit \
        --kbe-user-tag=$kbe_user_tag
)
image="$IMAGE_NAME_ASSETS-$kbe_image_tag:$assets_version"
export KBE_ASSETS_IMAGE="$image"
export KBE_ASSETS_CONTAINER_NAME="$KBE_ASSETS_CONTAINER_NAME"

docker-compose down -v
images=$( docker images | grep "$PROJECT_NAME/kbe-" | awk '{print $1 ":" $2}' )
if [ -n "$images" ]; then
    echo "$images" | xargs docker rmi -f
fi
dangling=$( docker images --all --filter "dangling=true" --quiet )
if [ -n "$dangling" ]; then
    echo "$dangling" | xargs docker rmi -f
fi
