#!/bin/bash
# Tail the game logs.

# Import global constants of the project
curr_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $( realpath "$curr_dir"/../init.sh )

USAGE="
Usage. The script shows KBEngine logs (the started game).\
 Use the image name in the first argument. Example:
bash $0 \\
  --kbe-git-commit=7d379b9f \\
  --kbe-user-tag=v2.5.12 \\
  --assets-version=v0.0.1
"

echo "[DEBUG] Parse CLI arguments ..."
kbe_git_commit=""
kbe_user_tag=""
assets_version=""
help=false
for arg in "$@"
do
    key=$( echo "$arg" | cut -f1 -d= )
    value=$( echo "$arg" | cut -f2 -d= )
    case "$key" in
        --kbe-git-commit)  kbe_git_commit=${value} ;;
        --kbe-user-tag)  kbe_user_tag=${value} ;;
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

echo "[DEBUG] Command: $0 --kbe-git-commit=$kbe_git_commit --kbe-user-tag=$kbe_user_tag --assets-version=$assets_version"

if [ -z "$kbe_git_commit" ] || [ -z "$assets_version" ]; then
    echo "[ERROR] Not all arguments passed" >&2
    echo -e "$USAGE"
    exit 1
fi

# TODO: проверять кто запущен. Скорей всего по какой-то определённой системе имён.
# Т.к. ещё есть docker-compose со своим способом запускать систему.
# Можно и основы Docker почитать сперва. И законспектировать.
bash "$curr_dir/is_running.sh"
if [ "$?" -ne 0 ]; then
    exit 1
fi

kbe_image_tag=$(
    bash $SCRIPTS/misc/get_kbe_image_tag.sh \
        --kbe-git-commit=$kbe_git_commit \
        --kbe-user-tag=$kbe_user_tag
)
cd "$PROJECT_DIR"
export KBE_ASSETS_IMAGE="$IMAGE_NAME_ASSETS-$kbe_image_tag:$assets_version"
docker-compose logs --timestamps --follow
