#!/bin/bash
# Request last commit ssh of the kbe master branch.

set -e

KBE_REPO="https://api.github.com/repos/kbengine/kbengine"

json=$( curl -sb -H "Accept: application/json" "$KBE_REPO/commits/master" )
last_sha=$( echo "$json" | jq ".sha" | tr -d '""' )
if [ "$last_sha" = "null" ] || [ -z "$last_sha" ]; then
    echo ""
    exit 0
fi
last_sha=${last_sha::8}

echo "$last_sha"
