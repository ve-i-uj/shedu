#!/bin/bash
# Build a docker image of the compiled KBEngine.

USAGE="
Usage. Build a docker image of the compiled KBEngine. Example:
bash $0 \\
  --kbe-git-commit=7d379b9f \\
  --kbe-user-tag=v2.5.12
"

# Import global constants of the project
curr_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $( realpath "$curr_dir/../init.sh" )

echo "[INFO] Build a docker image of compiled KBEngine ..."

echo "[DEBUG] Parse CLI arguments ..."
kbe_user_tag=""
kbe_git_commit=""
for arg in "$@"
do
    key=$( echo "$arg" | cut -f1 -d= )
    value=$( echo "$arg" | cut -f2 -d= )

    case "$key" in
        --kbe-user-tag)                 kbe_user_tag=${value} ;;
        --kbe-git-commit)           kbe_git_commit=${value} ;;
        --help)
            echo -e "$USAGE"
            exit 1
            ;;
        -h)
            echo -e "$USAGE"
            exit 1
            ;;
        *)
    esac
done
echo "[DEBUG] Command: $0 --kbe-git-commit=$kbe_git_commit --kbe-user-tag=$kbe_user_tag"

if [ "$help" = true ]; then
    echo -e "$USAGE"
    exit 0
fi

if [ -z "$kbe_git_commit" ]; then
    echo "[ERROR] Not all arguments passed" >&2
    echo -e "$USAGE"
    exit 1
fi


kbe_image_tag=$(
    bash $PROJECT_DIR/scripts/misc/get_kbe_image_tag.sh \
        --git-commit=$kbe_git_commit \
        --user-tag=$kbe_user_tag
)
kbe_compiled_image="$IMAGE_NAME_KBE_COMPILED:$kbe_image_tag"
if [[ "$(docker images -q $kbe_compiled_image 2> /dev/null)" != "" ]]; then
    echo "[INFO] The \"$kbe_compiled_image\" image already exists at the host. Exit"
    exit 0
fi
echo "[INFO] There is NO image \"$kbe_compiled_image\" at the host"

echo "[INFO] Trying to find the \"$kbe_compiled_image\" image on the docker hub ..."
if docker manifest inspect $kbe_compiled_image > /dev/null; then
    echo "[INFO] The image is found. Download the \"$kbe_compiled_image\" image ..."
    docker pull "$kbe_compiled_image"
    echo "[INFO] The \"$kbe_compiled_image\" image was downloaded from the docker hub. Exit"
    exit 0
fi
echo "[INFO] There is NO image \"$kbe_compiled_image\" on the docker hub. Build new one ..."

cd "$PROJECT_DIR"
docker build \
    --file "$DOCKERFILE_KBE_COMPILED" \
    --build-arg COMMIT_SHA="$kbe_git_commit" \
    --tag "$kbe_compiled_image" \
    .

echo "Done ($0)"
