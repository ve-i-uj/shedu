#!/bin/bash

USAGE="
Usage. Push the compiled kbe image to the docker hub. Example:
bash $0 \\
  --kbe-git-commit=7d379b9f \\
  --kbe-user-tag=v2.5.12
"

# Import global constants of the project
curr_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $( realpath "$curr_dir/../init.sh" )

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
        --kbe-git-commit=$kbe_git_commit \
        --kbe-user-tag=$kbe_user_tag
)
kbe_compiled_image="$KBE_COMPILED_IMAGE_NAME:$kbe_image_tag"
if [[ "$(docker images -q $kbe_compiled_image 2> /dev/null)" == "" ]]; then
    echo "[INFO] There is NO image \"$kbe_compiled_image\" at the host. Build the \"$kbe_compiled_image\" image at first"
    exit 1
fi

tag="$KBE_COMPILED_IMAGE_NAME:$kbe_image_tag"
only_sha_tag="$KBE_COMPILED_IMAGE_NAME:$kbe_git_commit"
docker tag "$tag" "$only_sha_tag"
echo -e "[INFO] Push the image contained compiled KBEngine (tag = \"$tag\") ..."
cd "$PROJECT_DIR"
docker push "$only_sha_tag"
docker push "$tag"

echo "Done ($0)"
