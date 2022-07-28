#!/bin/bash
# Build a docker image of KBEngine using multi-stages.

set -e

# Import global constants of the project
curr_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $( realpath "$curr_dir"/init.sh )

USAGE="\nUsage. Build KBEngine. Example:\nbash $0 [--kbe-git-commit=7d379b9f] [--kbe-user-tag=v2.5.12]

It will be built on last master commit if no \"--kbe-git-commit\" argument."

echo "[DEBUG] Parse CLI arguments ..."
user_tag=""
git_commit=""
for arg in "$@"
do
    key=$( echo "$arg" | cut -f1 -d= )
    value=$( echo "$arg" | cut -f2 -d= )

    case "$key" in
        --kbe-user-tag)              user_tag=${value} ;;
        --kbe-git-commit)            git_commit=${value} ;;
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
echo "[DEBUG] Command: $0 --kbe-git-commit=$git_commit --kbe-user-tag=$user_tag"

echo "[INFO] Request the last commit sha of the kbengine master branch ..."
last_sha=$( bash "$curr_dir/misc/get_latest_kbe_sha.sh" )
if [ -z "$last_sha" ]; then
    echo -e "[ERROR] Last commit sha cannot be requested. Json = \n$json"
    exit 1
fi

if [ -z "$git_commit" ]; then
    echo "[WARNING] No argument \"--kbe-git-commit\". The last sha value \"$last_sha\" will be set."
    git_commit="$last_sha"
fi

commit_info=$( curl -s -H "Accept: application/vnd.github.v3+json" "$KBE_REPO/commits/$git_commit" | jq .sha )
if [[ "$commit_info" == null ]]; then
    echo -e "[ERROR] There is NO sha commit \"$git_commit\" in the KBE repository"
    echo -e "$USAGE"
    exit 1
fi

# Add prefix to the user tag if it is
if [ -n "$user_tag" ]; then
    user_tag="-$user_tag"
fi

tag="$PRE_ASSETS_IMAGE_NAME:$git_commit$user_tag"
echo -e "*** Build an image contained compiled KBEngine (tag = \"$tag\") ***"
cd "$PROJECT_DIR"
docker build \
    --file "$KBE_DOCKERFILE_PATH" \
    --build-arg COMMIT_SHA="$git_commit" \
    --tag "$tag" \
    .

echo "Done ($0)."
