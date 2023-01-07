#!/bin/bash

set -e

curr_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $( realpath "$curr_dir/../init.sh" )
source $( realpath $SCRIPTS/log.sh )

log info "Pull and tag ELK images"

docker pull $ELK_ES_IMAGE_NAME 1>/dev/null
docker tag $ELK_ES_IMAGE_NAME "$ELK_ES_IMAGE_TAG"
log info "The image \"$ELK_ES_IMAGE_TAG\" have been created"

docker pull $ELK_KIBANA_IMAGA_NAME 1>/dev/null
docker tag $ELK_KIBANA_IMAGA_NAME "$ELK_KIBANA_IMAGE_TAG"
log info "The image \"$ELK_KIBANA_IMAGE_TAG\" have been created"

docker pull $ELK_LOGSTASH_IMAGA_NAME 1>/dev/null
docker tag $ELK_LOGSTASH_IMAGA_NAME "$ELK_LOGSTASH_IMAGE_TAG"
log info "The image \"$ELK_LOGSTASH_IMAGE_TAG\" have been created"

docker pull $ELK_DEJAVU_IMAGA_NAME 1>/dev/null
docker tag $ELK_DEJAVU_IMAGA_NAME "$ELK_DEJAVU_IMAGE_TAG"
log info "The image \"$ELK_DEJAVU_IMAGE_TAG\" have been created"

log info "Done ($0)"
