#!/bin/bash
# Is the sha of the kbengine repository?

# Import global constants of the project
curr_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $( realpath "$curr_dir/../init.sh" )
source $( realpath $SCRIPTS/log.sh )

kbe_git_commit=${1:-}

commit_info=$(
    curl -s \
        -H "Accept: application/vnd.github.v3+json" \
        "$KBE_GITHUB_API_URL/commits/$kbe_git_commit" \
    | jq .sha
)
if [[ "$commit_info" == null ]]; then
    log warn "There is NO sha commit \"$kbe_git_commit\" in the KBE repository (<$KBE_GITHUB_URL>)"
    exit 1
fi

exit 0
