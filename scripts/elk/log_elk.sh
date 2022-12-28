#!/bin/bash

set -e

# Import global constants of the project
curr_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source "$( realpath "$curr_dir/../init.sh" )"

docker-compose logs -f
