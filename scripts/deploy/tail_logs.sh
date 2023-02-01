#!/bin/sh
#
# Tails all log files in the directory "logs"
#

logs_dir="/opt/kbengine/assets/logs/$KBE_GAME_NAME"
mkdir -p $logs_dir >/dev/null

cd "$logs_dir"
tail -f $( ls . | grep -v packets )
