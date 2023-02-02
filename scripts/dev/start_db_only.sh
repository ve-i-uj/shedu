#!/bin/bash

curr_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $( realpath "$curr_dir/../init.sh" )
source $( realpath $SCRIPTS/log.sh )


docker run \
    --rm \
    -p 3306:3306 \
    -e
    kbe-mariadb
