#!/bin/bash

curr_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $( realpath "$curr_dir/../init.sh" )
source $( realpath $SCRIPTS/log.sh )

is_running=true
print_error=false
info=false
arg1="${1:-}"
if [ "$arg1" = "--print-error" ]; then
    print_error=true
elif [ "$arg1" = "--info" ]; then
    info=true
fi

services="kbe-log-elk-elastic kbe-log-elk-dejavu kbe-log-elk-kibana kbe-log-elk-logstash"
for service in $services
do
    docker-compose ps --status=running -q $service 1>/dev/null 2>/dev/null
    if [ $? -ne 0 ]; then
        log debug "The service \"$service\" is not running"
        is_running=false
    fi
done

out=$( docker volume ls -q -f "name=$KBE_LOG_VOLUME_NAME" )
if [ -z "$out" ]; then
    log debug "There is no volume \"$KBE_LOG_VOLUME_NAME\""
    is_running=false
fi

out=$( docker volume ls -q -f "name=$KBE_LOG_ELASTIC_VOLUME_NAME" )
if [ -z "$out" ]; then
    log debug "There is no volume \"$KBE_LOG_ELASTIC_VOLUME_NAME\""
    is_running=false
fi

net_name=shedu_kbe-net
out=$( docker network ls -q -f "name=$net_name" )
if [ -z "$out" ]; then
    log debug "There is no net \"$net_name\""
    is_running=false
fi

if $info; then
    if $is_running; then
        log info "The ELK services are running"
    else
        log info "The ELK services are not running"
    fi
    exit 0
fi

if $is_running; then
    exit 0
else
    exit 1
fi
