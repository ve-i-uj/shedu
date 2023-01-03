#!/bin/bash

set -e

# Import global constants of the project
curr_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

res=0
print_error=false
if [ "$1" = "--print-error" ]; then
    print_error=true
else
    print_error=false
fi

service=kbe-log-elk-elastic
if !(docker-compose ps --status=running -q $service 1>/dev/null 2>/dev/null); then
    echo "[WARNING] The service \"$service\" is not running"
    res=1
fi

service=kbe-log-elk-dejavu
if !(docker-compose ps --status=running -q $service 1>/dev/null 2>/dev/null); then
    echo "[WARNING] The service \"$service\" is not running"
    res=1
fi

service=kbe-log-elk-kibana
if !(docker-compose ps --status=running -q $service 1>/dev/null 2>/dev/null); then
    echo "[WARNING] The service \"$service\" is not running"
    res=1
fi

service=kbe-log-elk-logstash
if !(docker-compose ps --status=running -q $service 1>/dev/null 2>/dev/null); then
    echo "[WARNING] The service \"$service\" is not running"
    res=1
fi

volume_name=shedu_kbe-log-kbeengine
out=$( docker volume ls -q -f "name=$volume_name" )
if [ -z $out ]; then
    echo "[WARNING] There is no volume \"$volume_name\""
    res=1
fi

volume_name=kbe-log-elk-elastic-volume
out=$( docker volume ls -q -f "name=$volume_name" )
if [ -z $out ]; then
    echo "[WARNING] There is no volume \"$volume_name\""
    res=1
fi

net_name=shedu_kbe-net
out=$( docker network ls -q -f "name=$net_name" )
if [ -z $out ]; then
    echo "[WARNING] There is no net \"$net_name\""
    res=1
fi

if $print_error; then
    >&2 echo "[ERROR] The ELK services is not running"
fi

exit $res
