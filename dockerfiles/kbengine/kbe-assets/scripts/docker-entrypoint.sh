#!/bin/bash
#
# Runs the kbe server in a docker image
#

TIMEOUT=5

echo
echo "*** Update kbengine.xml file the engine connect to DB ***"
echo
curr_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
python3 $curr_dir/modify_kbe_config.py

echo
echo "*** Start the kbe engine ***"
echo
curr_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
bash $curr_dir/start_server.sh &


echo
echo "*** Waiting for $TIMEOUT seconds the engine starts ***"
echo
sleep $TIMEOUT

echo
echo "*** Tail the engine log files ***"
echo
bash $curr_dir/tail_logs.sh

