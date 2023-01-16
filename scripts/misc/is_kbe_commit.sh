#!/bin/bash
# Is the sha of the kbengine repository?

# Import global constants of the project
curr_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $( realpath "$curr_dir/../init.sh" )
source $( realpath $SCRIPTS/log.sh )

kbe_git_commit=${1:-}
if [ -z $kbe_git_commit ]; then
    log warn "There is NO sha commit in the first argument"
    exit 1
fi

sha_dir_success=$PROJECT_CACHE_DIR/success-sha-$( date +"%Y-%m-%d" )
sha_dir_fail=$PROJECT_CACHE_DIR/fail-sha-$( date +"%Y-%m-%d" )
mkdir -p $sha_dir_success 2>/dev/null
mkdir -p $sha_dir_fail 2>/dev/null

if [ -f $sha_dir_success/$kbe_git_commit ]; then
    log debug "The \"$kbe_git_commit\" commit sha exists (it is already checked)"
    exit 0
fi

if [ -f $sha_dir_fail/$kbe_git_commit ]; then
    log debug "The \"$kbe_git_commit\" commit sha does not exist (it is already checked)"
    exit 1
fi

log debug "Request info for the \"$kbe_git_commit\" sha"
commit_info=$(
    curl -s \
        -H "Accept: application/vnd.github.v3+json" \
        "$KBE_GITHUB_API_URL/commits/$kbe_git_commit" \
    | jq .sha
)

if [[ "$commit_info" == null ]]; then
    log warn "There is NO sha commit \"$kbe_git_commit\" in the KBE repository (<$KBE_GITHUB_URL>)"
    touch $sha_dir_fail/$kbe_git_commit
    exit 1
fi

log debug "The \"$kbe_git_commit\" commit sha exists"
touch $sha_dir_success/$kbe_git_commit

exit 0
