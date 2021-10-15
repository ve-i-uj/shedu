#!/usr/bin/bash
#
# Set a new version to the version.txt file and mark the current commit
# by the version tag.
#

USAGE="\nUsage. The scripts sets a new project version. Use the new version \
in the first argument. The script works only on the \"develop\" branch. \
Example:\nbash $0 v1.2.3\n"

# import global variables of scripts
curr_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $( realpath "$curr_dir"/init.sh )

VERSION_PATH="$PROJECT_DIR/version.txt"

version="$1"
if [ -z "$version" ]; then
    echo "[ERROR] There is no version in the first argument"
    echo -e "$USAGE"
    exit 1
fi

if [ $( git branch --show-current ) != "develop" ]; then
    echo "[ERROR] The script works only on the \"develop\" branch."
    echo -e "$USAGE"
    exit 1
fi

echo "The version \"$version\" will be set ..."
echo "$version" | tee >( xargs git tag ) > "$VERSION_PATH"

git commit -a -m "Set the version \"$version\" (auto commit)"
git push origin develop
git push --tags

echo "Done"
