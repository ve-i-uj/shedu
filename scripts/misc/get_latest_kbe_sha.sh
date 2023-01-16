#!/bin/bash
# Request last commit ssh of the kbe master branch.

set -e

DEFAULT_SHA=7d379b9f

curr_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $( realpath "$curr_dir/../init.sh" )

mkdir -p $PROJECT_CACHE_DIR 2>/dev/null
last_sha_file=$PROJECT_CACHE_DIR/kbe_last_sha-$( date +"%Y-%m-%d" )

# Чтобы не делать много запросов на github при отладке и не получить
# ограничение скачиваний, используем кэш
if [ -f $last_sha_file ]; then
    cat $last_sha_file
    exit 0
fi

json=$( curl -sb -H "Accept: application/json" "$KBE_GITHUB_API_URL/commits/master" )
last_sha=$( echo "$json" | jq ".sha" | tr -d '""' )
if [ "$last_sha" = "null" ] || [ -z "$last_sha" ]; then
    echo "$DEFAULT_SHA"
    exit 0
fi
last_sha=${last_sha::8}

echo $last_sha > $last_sha_file

echo "$last_sha"
