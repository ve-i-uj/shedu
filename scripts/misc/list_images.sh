#!/bin/bash
# List built images

curr_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $( realpath "$curr_dir"/../init.sh )

docker images --filter reference="$PROJECT_NAME/*" --format "{{.Repository}}:{{.Tag}}"
