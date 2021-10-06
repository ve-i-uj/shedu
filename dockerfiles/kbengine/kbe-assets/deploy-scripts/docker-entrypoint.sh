#!/bin/bash
#
# Runs the kbe server in a docker image
#

TIMEOUT=5

echo
echo "*** Start the KBEngine ***"
echo
curr_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
bash "$curr_dir"/start_server.sh &

echo
echo "*** Waiting for $TIMEOUT seconds the engine starts ***"
echo
sleep $TIMEOUT

echo
echo "*** Tail the engine log files ***"
echo
bash "$curr_dir"/tail_logs.sh
