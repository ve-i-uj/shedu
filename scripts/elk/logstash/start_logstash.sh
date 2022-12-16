#!/bin/bash
# Start LogStash

# Import global constants of the project
curr_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $( realpath "$curr_dir/../../init.sh" )

docker run --rm \
    --name $ELK_LOGSTASH_CONTATINER_NAME \
    --network host \
    -e XPACK_MONITORING_ELASTICSEARCH_HOSTS="[ \"http://127.0.0.1:9200\" ]" \
    -e XPACK_MONITORING_ELASTICSEARCH_SSL_VERIFICATION_MODE=none \
    -v "$curr_dir/logstash.conf:/usr/share/logstash/pipeline/logstash.conf" \
    "$ELK_LOGSTASH_IMAGE_TAG"
