#!/bin/bash

curr_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $( realpath "$curr_dir/../init.sh" )
source $( realpath $SCRIPTS/log.sh )

ret=0
print_error=false
print_info_only=false
if [ "$1" = "--print-error" ]; then
    print_error=true
elif [ "$1" = "--print-info-only" ]; then
    print_info_only=true
fi

services="kbe-log-elk-elastic kbe-log-elk-dejavu kbe-log-elk-kibana kbe-log-elk-logstash"
for service in $services
do
    docker-compose ps --status=running -q $service 1>/dev/null 2>/dev/null
    if [ $? -ne 0 ]; then
        log debug "The service \"$service\" is not running"
        res=1
    fi
done

volume_name=shedu_kbe-log-kbeengine
out=$( docker volume ls -q -f "name=$volume_name" )
if [ -z $out ]; then
    log debug "There is no volume \"$volume_name\""
    res=1
fi

volume_name=kbe-log-elk-elastic-volume
out=$( docker volume ls -q -f "name=$volume_name" )
if [ -z $out ]; then
    log debug "There is no volume \"$volume_name\""
    res=1
fi

net_name=shedu_kbe-net
out=$( docker network ls -q -f "name=$net_name" )
if [ -z $out ]; then
    log debug "There is no net \"$net_name\""
    res=1
fi

if $print_error; then
    if [ "$ret" -eq "1" ]; then
        log error "The ELK services are not running. Run \"make start_elk\" at first"
    else
        log error "The ELK services are running. Run \"make stop_elk\" at first"
    fi
fi

if $print_info_only; then
    if [ "$ret" -eq "1" ]; then
        log info "The ELK services are not running"
    else
        log info "The ELK services are running"
    fi
    exit 0
fi

exit $res
