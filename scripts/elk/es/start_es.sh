#!/bin/bash
# Start Elastic Search

# Import global constants of the project
curr_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $( realpath "$curr_dir/../../init.sh" )

docker run --rm \
    -p 127.0.0.1:9200:9200 \
    -e "discovery.type=single-node" \
    -e "xpack.security.enabled=false" \
    --name "$ELK_ES_CONTATINER_NAME" \
    $ELK_ES_IMAGE_TAG
    # --network host \
    # -e "network.host: 0.0.0.0" \
    # -v $curr_dir/elasticsearch.yml:/usr/share/elasticsearch/config/elasticsearch.yml:ro \
