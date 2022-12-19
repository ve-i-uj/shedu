#!/bin/bash

set -e

# Import global constants of the project
curr_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source "$( realpath "$curr_dir/../init.sh" )"

cd "$curr_dir"
echo "[INFO] Delete old containers ..."
docker-compose rm -fsv
echo "[INFO] Start the Elastic+LogStash+Kibana containers ..."
docker-compose up -d

echo "Done ($0)"
