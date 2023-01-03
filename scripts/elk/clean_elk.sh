#!/bin/bash

set -e

# Import global constants of the project
curr_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

res=$( docker ps --filter name="$ELK_C_NAME_PREFIX*" -q )
if [ ! -z $res ]; then
    echo "[INFO] Delete containers"
    echo $res | xargs docker container rm 1>/dev/null
fi

if [ -n "$( docker images --filter reference="$ELK_ES_IMAGE_TAG" -q )" ]; then
    echo "[INFO] Delete the ES tag"
    docker rmi $ELK_ES_IMAGE_TAG 1>/dev/null
fi
if [ -n "$( docker images --filter reference="$ELK_KIBANA_IMAGE_TAG" -q )" ]; then
    echo "[INFO] Delete the Kibana tag"
    docker rmi $ELK_KIBANA_IMAGE_TAG 1>/dev/null
fi
if [ -n "$( docker images --filter reference="$ELK_LOGSTASH_IMAGE_TAG" -q )" ]; then
    echo "[INFO] Delete the LogStash tag"
    docker rmi $ELK_LOGSTASH_IMAGE_TAG 1>/dev/null
fi
if [ -n "$( docker images --filter reference="$ELK_DEJAVU_IMAGE_TAG" -q )" ]; then
    echo "[INFO] Delete the Dejavu tag"
    docker rmi $ELK_DEJAVU_IMAGE_TAG 1>/dev/null
fi

res=$( docker volume ls -f "name=$ELK_ES_VOLUME_NAME" -q )
if [ ! -z $res ]; then
    echo "[INFO] Delete the volume \"$res\""
    docker volume rm "$res" 1>/dev/null
fi

echo -e "\nDone ($0)\n"
