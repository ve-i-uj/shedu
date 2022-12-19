#!/bin/bash

set -e

# Import global constants of the project
curr_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source "$( realpath "$curr_dir/../init.sh" )"

bash "$curr_dir/stop_elk.sh"

echo "[INFO] Stop containers"
# docker ps --filter name="$ELK_C_NAME_PREFIX*" --filter status=running -aq \
#     | xargs docker stop
res=$( docker ps --filter name="$ELK_C_NAME_PREFIX*" -q )
if [ ! -z $res ]; then
    echo $res | xargs docker container rm
fi

if [ -n "$( docker images --filter reference="$ELK_ES_IMAGE_TAG" -q )" ]; then
    docker rmi $ELK_ES_IMAGE_TAG
fi
if [ -n "$( docker images --filter reference="$ELK_KIBANA_IMAGE_TAG" -q )" ]; then
    docker rmi $ELK_KIBANA_IMAGE_TAG
fi
if [ -n "$( docker images --filter reference="$ELK_LOGSTASH_IMAGE_TAG" -q )" ]; then
    docker rmi $ELK_LOGSTASH_IMAGE_TAG
fi

echo -e "\nDone ($0)"
