#!/bin/bash

set -e

USAGE="
Usage. Return the tag for the kbe image. Example:
bash $0 --kbe-git-commit=7d379b9f --kbe-user-tag=v2.5.12"

echo "[DEBUG] Parse CLI arguments ..." >&2
kbe_user_tag=""
kbe_git_commit=""
for arg in "$@"
do
    key=$( echo "$arg" | cut -f1 -d= )
    value=$( echo "$arg" | cut -f2 -d= )

    case "$key" in
        --kbe-user-tag)              kbe_user_tag=${value} ;;
        --kbe-git-commit)            kbe_git_commit=${value} ;;
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

echo "[DEBUG] Command: $(basename ${0}) --kbe-git-commit=$kbe_git_commit --kbe-user-tag=$kbe_user_tag" >&2

if [ -z "$kbe_git_commit" ]; then
    echo "[ERROR] The argument \"--kbe-git-commit\" is am empty string" >&2
    echo -e "$USAGE"
    exit 1
fi

tag=""
if [ -z $kbe_user_tag ]; then
    tag="$kbe_git_commit"
else
    tag="$kbe_user_tag-$kbe_git_commit"
fi

echo "$tag"
