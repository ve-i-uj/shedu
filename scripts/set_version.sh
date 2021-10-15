#!/usr/bin/bash
#
# Set a new version to the version.txt file and mark the current commit
# by the version tag.
#

USAGE="\nUsage. The scripts sets a new project version. Use the new version \
in the first argument. Example:\nbash $0 v1.2.3\n"

# import global variables of scripts
curr_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $( realpath "$curr_dir"/init.sh )

VERSION_PATH="$PROJECT_DIR/version.txt"

version="$1"
if [ -z "$version" ]; then
    echo -e "$USAGE"
    exit 1
fi

echo "The version \"$version\" will be set ..."
echo "$version" | tee >( xargs git tag ) > "$VERSION_PATH"

echo "Done"
