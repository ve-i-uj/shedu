#!/bin/bash
#
# Добавить монтирование в /tmp/kbedump для pcap-файлов (нужен перезапуск игры) 
#

curr_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $( realpath "$curr_dir/../../init.sh" )
source $( realpath $SCRIPTS/log.sh )

cp "$curr_dir/data/docker-compose.override.yml" "$PROJECT_DIR/"

log info "The 'docker-compose.override.yml' file added to the project root"
log info "Game resart needed to add pcap volumes to the game containers"
