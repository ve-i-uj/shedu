#!/bin/bash
# Request last commit ssh of the kbe master branch.

set -e

curr_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $( realpath "$curr_dir/../init.sh" )

json=$( curl -sb -H "Accept: application/json" "$KBE_GITHUB_API_URL/commits/master" )
last_sha=$( echo "$json" | jq ".sha" | tr -d '""' )
if [ "$last_sha" = "null" ] || [ -z "$last_sha" ]; then
    echo ""
    exit 0
fi
last_sha=${last_sha::8}

echo "$last_sha"
