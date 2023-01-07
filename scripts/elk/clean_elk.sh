#!/bin/bash

set -e

curr_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $( realpath "$curr_dir/../init.sh" )
source $( realpath $SCRIPTS/log.sh )

res=$( docker ps --filter name="$ELK_C_NAME_PREFIX*" -q )
if [ ! -z $res ]; then
    log info "Delete containers"
    echo $res | xargs docker container rm 1>/dev/null
fi

if [ -n "$( docker images --filter reference="$ELK_ES_IMAGE_TAG" -q )" ]; then
    log info "Delete the ES tag"
    docker rmi $ELK_ES_IMAGE_TAG 1>/dev/null
fi
if [ -n "$( docker images --filter reference="$ELK_KIBANA_IMAGE_TAG" -q )" ]; then
    log info "Delete the Kibana tag"
    docker rmi $ELK_KIBANA_IMAGE_TAG 1>/dev/null
fi
if [ -n "$( docker images --filter reference="$ELK_LOGSTASH_IMAGE_TAG" -q )" ]; then
    log info "Delete the LogStash tag"
    docker rmi $ELK_LOGSTASH_IMAGE_TAG 1>/dev/null
fi
if [ -n "$( docker images --filter reference="$ELK_DEJAVU_IMAGE_TAG" -q )" ]; then
    log info "Delete the Dejavu tag"
    docker rmi $ELK_DEJAVU_IMAGE_TAG 1>/dev/null
fi

res=$( docker volume ls -f "name=$ELK_ES_VOLUME_NAME" -q )
if [ ! -z $res ]; then
    log info "Delete the volume \"$res\""
    docker volume rm "$res" 1>/dev/null
fi

log info "Done ($0)"
