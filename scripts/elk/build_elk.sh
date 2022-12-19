#!/bin/bash

set -e

# Import global constants of the project
curr_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source "$( realpath "$curr_dir/../init.sh" )"

bash "$curr_dir/es/build_es.sh"
bash "$curr_dir/kibana/build_kibana.sh"
bash "$curr_dir/logstash/build_logstash.sh"

echo -e "\nDone ($0)"
