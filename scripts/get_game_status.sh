#!/bin/bash
# Return a game status (stopped or running).

curr_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

RUNNING=running
STOPPED=stopped

if [[ $( "$curr_dir/misc/is_running.sh" ) ]]; then
    echo "$STOPPED"
else
    echo "$RUNNING"
fi
