#!/bin/bash
#
# Copy an assets directory and build a docker image of KBEngine with assets
#

# import global variables of scripts
curr_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source `realpath $curr_dir/init.sh`

USAGE="Use an absolute path to an assets in the first argument. Example:\nbash $0 /home/leto/code/pCloud/2PeopleCompany/anu\n"

# check argumet exists
if [ -z "$1" ] 
    then
        echo -e $USAGE
        exit
fi

if [ ! -d "$1" ]; then
    echo -e $USAGE
    exit
fi

dst=$PROJECT_DIR/assets
if [ -d "$dst" ]; then
    echo "Destination directory exists. It will be deleted"
    rm -rf $dst
fi

echo "Copy assets: "$1" --> $dst"
cp -R $1 $dst

cd $PROJECT_DIR
echo "Build a docker container ..." 
docker-compose --env-file "$PROJECT_DIR/configs/dev.env" up \
    --remove-orphans \
    --force-recreate \
    --build
