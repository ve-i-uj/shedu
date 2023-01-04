#!/bin/bash

res=0
print_error=false
if [ "$1" = "--print-error" ]; then
    print_error=true
else
    print_error=false
fi

services="kbe-log-elk-elastic kbe-log-elk-dejavu kbe-log-elk-kibana kbe-log-elk-logstash"
for service in $services
do
    docker-compose ps --status=running -q $service 1>/dev/null 2>/dev/null
    if [ $? -ne 0 ]; then
        echo "[DEBUG] The service \"$service\" is not running"
        res=1
    fi
done

volume_name=shedu_kbe-log-kbeengine
out=$( docker volume ls -q -f "name=$volume_name" )
if [ -z $out ]; then
    echo "[DEBUG] There is no volume \"$volume_name\""
    res=1
fi

volume_name=kbe-log-elk-elastic-volume
out=$( docker volume ls -q -f "name=$volume_name" )
if [ -z $out ]; then
    echo "[DEBUG] There is no volume \"$volume_name\""
    res=1
fi

net_name=shedu_kbe-net
out=$( docker network ls -q -f "name=$net_name" )
if [ -z $out ]; then
    echo "[DEBUG] There is no net \"$net_name\""
    res=1
fi

if $print_error && [ "$res" -eq "1" ]; then
    >&2 echo "[ERROR] The ELK services is not running"
fi

if [ "$res" -eq "1" ]; then
    echo "[INFO] The ELK services are not running"
else
    echo "[INFO] The ELK services are running"
fi

exit $res
