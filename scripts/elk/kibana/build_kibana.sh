#!/bin/bash
# Build a Kibana image

set -e

docker pull $ELK_KIBANA_IMAGA_NAME
docker tag $ELK_KIBANA_IMAGA_NAME "$ELK_KIBANA_IMAGE_TAG"
echo "The image \"$ELK_KIBANA_IMAGE_TAG\" have been created"
