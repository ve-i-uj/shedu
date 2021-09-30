#!/bin/bash
#
# Build a docker image of KBEngine
#

# import global variables of scripts
curr_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $( realpath "$curr_dir"/../init.sh )
source $( realpath "$curr_dir"/init.sh )

KBE_REPO="https://api.github.com/repos/kbengine/kbengine/commits/master"

echo "Parse CLI arguments ..."
user_tag=""
git_commit=""
for arg in "$@"
do
    key=$( echo "$arg" | cut -f1 -d= )
    value=$( echo "$arg" | cut -f2 -d= )

    case "$key" in
        --user-tag)              user_tag=${value} ;;
        --git-commit)            git_commit=${value} ;;
        *)
    esac
done
echo "CLI arguments: "
echo "    user_tag=$user_tag"
echo "    git_commit=$git_commit"

# Add prefix to the user tag if it is
if [ -n "$user_tag" ]; then
    user_tag="-$user_tag"
fi

echo -e "*** Build an image contained prerequisites ***"
cd "$DOCKERFILES_DIR/kbengine/$PREREQS_DIR"
docker build -t "$PREREQS_IMAGE_NAME" .
echo -e "*** Done (the docker image contained prerequisites) ***\n"

echo -e "*** Build an image contained source code of KBEngine (from '$from') ***"
echo "Request the last commit sha of the kbengine master branch ..."
json=$( curl -sb -H "Accept: application/json" -H "Content-Type: application/json" "$KBE_REPO" )
last_sha=$( echo "$json" | jq ".sha" | tr -d '""' )
if [ "$last_sha" = "null" ]; then
    echo -e "[ERROR] Last commit sha cannot be requested. Json = \n$json"
    exit 0
fi
echo "The last commit sha is \"$last_sha\"."
last_sha=${last_sha::6}
echo "Download KBEngine and build a docker image ..."
from="$PREREQS_IMAGE_NAME"
cd "$DOCKERFILES_DIR/kbengine/$SRC_DIR"
tag="$SRC_IMAGE_NAME:$last_sha$user_tag"
docker build --build-arg FROM_IMAGE_NAME="$from" -t "$tag" .
echo -e "*** Done (KBEngine source code image) ***\n"

echo -e "*** Build an image contained compiled KBEngine (from '$from') ***"
from=$tag
cd "$DOCKERFILES_DIR/kbengine/$COMPILED_DIR"
docker build --build-arg FROM_IMAGE_NAME="$from" -t "$COMPILED_IMAGE_NAME:$last_sha$user_tag" .
echo -e "*** Done (the docker image of KBEngine compiled code) ***\n"
