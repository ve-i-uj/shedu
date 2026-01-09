#!/bin/bash
#
# Добавить монтирование в /tmp/kbedump для pcap-файлов (нужен перезапуск игры) 
#

curr_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $( realpath "$curr_dir/../../init.sh" )
source $( realpath $SCRIPTS/log.sh )

rm -f "$PROJECT_DIR/docker-compose.override.yml"

log info "The 'docker-compose.override.yml' file has been removed (if it existed)"
log info "Game restart needed to unmount the pcap directories"
