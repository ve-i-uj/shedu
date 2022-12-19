#!/bin/bash
# Start Kibana

# Import global constants of the project
curr_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $( realpath "$curr_dir/../../init.sh" )

docker run --rm \
    --network host \
    -it \
    -p 5601:5601 \
    -e XPACK_MONITORING_ELASTICSEARCH_HOSTS="[ \"http://127.0.0.1:9200\" ]" \
    -e "network.host: 0.0.0.0" \
    -e ELASTICSEARCH_HOSTS=http://127.0.0.1:9200 \
    -e LOGGING_DEST=/var/log/kibana/kibana.log \
    --name "$ELK_KIBANA_CONTATINER_NAME" \
    $ELK_KIBANA_IMAGE_TAG

echo "Kibana started on <http://localhost:5601/>"