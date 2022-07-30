#!/bin/bash

USAGE="
Usage. Build a docker image of the compiled KBEngine.
The \"force\" flag to build a new image from the kbe source code without cache \
(an image on the hub or the host).
Example:
bash $0 \\
  --kbe-git-commit=7d379b9f \\
  --kbe-user-tag=v2.5.12 \\
  [--force]
"

# Import global constants of the project
curr_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $( realpath "$curr_dir/../init.sh" )

echo "[INFO] Build a docker image of compiled KBEngine ..."

echo "[DEBUG] Parse CLI arguments ..."
kbe_user_tag=""
kbe_git_commit=""
help=false
force=false
for arg in "$@"
do
    key=$( echo "$arg" | cut -f1 -d= )
    value=$( echo "$arg" | cut -f2 -d= )

    case "$key" in
        --kbe-user-tag)             kbe_user_tag=${value} ;;
        --kbe-git-commit)           kbe_git_commit=${value} ;;
        --kbe-git-commit)           kbe_git_commit=${value} ;;
        --force)                    force=true ;;
        --help)                     help=true ;;
        -h)                         help=true ;;
        *)
    esac
done
echo "[DEBUG] Command: $(basename ${0}) --kbe-git-commit=$kbe_git_commit --kbe-user-tag=$kbe_user_tag --force=$force"

if [ "$help" = true ]; then
    echo -e "$USAGE"
    exit 0
fi

if [ -z "$kbe_git_commit" ]; then
    echo "[ERROR] Not all arguments passed" >&2
    echo -e "$USAGE"
    exit 1
fi

commit_info=$(
    curl -s \
        -H "Accept: application/vnd.github.v3+json" \
        "https://api.github.com/repos/kbengine/kbengine/commits/$kbe_git_commit" \
    | jq .sha
)
if [[ "$commit_info" == null ]]; then
    echo "[ERROR] There is NO sha commit \"$kbe_git_commit\" in the KBE repository <$KBE_REPO>)"
    exit 1
fi

kbe_image_tag=$(
    bash $PROJECT_DIR/scripts/misc/get_kbe_image_tag.sh \
        --kbe-git-commit=$kbe_git_commit \
        --kbe-user-tag=$kbe_user_tag
)
kbe_compiled_image="$IMAGE_NAME_KBE_COMPILED:$kbe_image_tag"

if ! $force; then
    if [ ! -z $(docker images -q "$kbe_compiled_image") ]; then
        echo "[INFO] The \"$kbe_compiled_image\" image already exists at the host. Exit"
        exit 0
    fi
    echo "[INFO] There is NO image \"$kbe_compiled_image\" at the host"
fi

if ! $force; then
    echo "[INFO] Trying to find the \"$kbe_compiled_image\" image on the docker hub ..."
    if docker manifest inspect $kbe_compiled_image > /dev/null; then
        echo "[INFO] The image is found. Download the \"$kbe_compiled_image\" image ..."
        docker pull "$kbe_compiled_image"
        echo "[INFO] The \"$kbe_compiled_image\" image was downloaded from the docker hub. Exit"
        exit 0
    fi
    echo "[INFO] There is NO image \"$kbe_compiled_image\" on the docker hub"
fi

echo "[INFO] Build the \"$kbe_compiled_image\" image ..."
cd "$PROJECT_DIR"
docker build \
    --file "$DOCKERFILE_KBE_COMPILED" \
    --build-arg COMMIT_SHA="$kbe_git_commit" \
    --tag "$kbe_compiled_image" \
    .

echo "Done ($0)"
