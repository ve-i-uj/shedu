#!/bin/bash

set -e

docker pull $ELK_ES_IMAGE_NAME
docker tag $ELK_ES_IMAGE_NAME "$ELK_ES_IMAGE_TAG"
echo "The image \"$ELK_ES_IMAGE_TAG\" have been created"
