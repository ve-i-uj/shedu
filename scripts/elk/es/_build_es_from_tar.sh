#!/bin/bash

# Import global constants of the project
curr_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $( realpath "$curr_dir/../../init.sh" )

cd "$PROJECT_DIR"
export DOCKERFILE="$PROJECT_DIR/dockerfiles/elk/Dockerfile.elasticsearch"
export IMAGE_TAG_PREFIX="$PROJECT_NAME"
export SERVICE_NAME="elasticsearch"
export ELK_DOCKER_IMAME_URL=https://repo.huaweicloud.com/elasticsearch/7.15.1/elasticsearch-7.15.1-linux-x86_64.tar.gz
pipenv run python $SCRIPTS/elk/build_tar.py
