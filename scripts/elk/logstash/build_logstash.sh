#!/bin/bash

set -e

docker pull $ELK_LOGSTASH_IMAGA_NAME
docker tag $ELK_LOGSTASH_IMAGA_NAME "$ELK_LOGSTASH_IMAGE_TAG"
echo "The image \"$ELK_LOGSTASH_IMAGE_TAG\" have been created"
