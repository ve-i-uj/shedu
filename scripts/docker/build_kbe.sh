#!/bin/bash
#
# Build a docker image of KBEngine
#

set -e

# import global variables of scripts
curr_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $( realpath "$curr_dir"/init.sh )

KBE_REPO="https://api.github.com/repos/kbengine/kbengine/commits/master"
USAGE="Build KBEngine. Example:\nbash $0 [--git-commit=5283b9b8] [--user-tag=v2.5.11]\n"

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

echo "CLI arguments: "
echo "    user_tag=$user_tag"
echo "    git_commit=$git_commit"

echo "Request the last commit sha of the kbengine master branch ..."
json=$( curl -sb -H "Accept: application/json" -H "Content-Type: application/json" "$KBE_REPO" )
last_sha=$( echo "$json" | jq ".sha" | tr -d '""' )
if [ "$last_sha" = "null" ] || [ -z "$last_sha" ]; then
    echo -e "[ERROR] Last commit sha cannot be requested. Json = \n$json"
    exit 1
fi
echo "The last commit sha is \"$last_sha\"."
last_sha=${last_sha::8}

if [ -z "$git_commit" ]; then
    echo "No argument \"--git-commit\". The last sha value \"$last_sha\" will be set."
    git_commit="$last_sha"
fi

# Add prefix to the user tag if it is
if [ -n "$user_tag" ]; then
    user_tag="-$user_tag"
fi

echo "Download KBEngine and build a docker image ..."
bash "$curr_dir/build_kbe/build_pre_build.sh"
bash "$curr_dir/build_kbe/build_latest.sh"

version="$git_commit$user_tag"
src_tag="$SRC_IMAGE_NAME:$git_commit$user_tag"
bash "$curr_dir/build_kbe/build_src.sh" "$git_commit" "$src_tag"
bash "$curr_dir/build_kbe/build_compiled.sh" "$src_tag"
bash "$curr_dir/build_kbe/build_pre_assets.sh" "$version"

echo "Done."
