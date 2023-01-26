#!/bin/sh
#
# Tails all log files in the directory "logs"
#

LOGS_DIR="$KBE_ASSETS_PATH/logs/$KBE_GAME_NAME"

function tail_log_files {
	cd "$LOGS_DIR"
	ls . \
		| grep -v packets \
		| python -c "import sys; lst = sys.stdin.readlines(); print ('\ntail -f ' + ' -f '.join(r.strip() for r in lst if r.strip().endswith('.log')) + '\n')" \
		| source /dev/stdin
}

tail_log_files
