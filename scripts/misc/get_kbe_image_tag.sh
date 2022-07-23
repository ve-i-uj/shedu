#!/bin/bash
# Create the tag by arguments.

set -e

USAGE="
Usage. Return the tag for the kbe image. Example:
bash $0 --git-commit=7d379b9f --user-tag=v2.5.12"

echo "[DEBUG] Parse CLI arguments ..." &>2
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

echo "[DEBUG] Command: $0 --git-commit=$git_commit --user-tag=$user_tag" &>2

if [ -z "$git_commit" ]; then
    echo "[ERROR] The argument \"--git-commit\" is am empty string"
    echo -e "$USAGE"
    exit 1
fi

tag=""
if [ -z $user_tag ]; then
    tag="$git_commit"
else
    tag="$git_commit-$user_tag"
fi

echo "$tag"
