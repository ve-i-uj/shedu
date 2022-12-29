#!/bin/bash

set -e

docker pull $ELK_DEJAVU_IMAGA_NAME
docker tag $ELK_DEJAVU_IMAGA_NAME "$ELK_DEJAVU_IMAGE_TAG"
echo "The image \"$ELK_DEJAVU_IMAGE_TAG\" have been created"
