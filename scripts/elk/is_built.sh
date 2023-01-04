#!/bin/bash

set -e

# Import global constants of the project
curr_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $( realpath "$curr_dir/../init.sh" )

res=0
print_error=false
if [ "$1" = "--print-error" ]; then
    print_error=true
else
    print_error=false
fi

if [ -z "$( docker images --filter reference="$ELK_ES_IMAGE_TAG" -q )" ]; then
    echo "[INFO] There is no image \"$ELK_ES_IMAGE_TAG\""
    res=1
fi
if [ -z "$( docker images --filter reference="$ELK_KIBANA_IMAGE_TAG" -q )" ]; then
    echo "[INFO] There is no image \"$ELK_KIBANA_IMAGE_TAG\""
    res=1
fi
if [ -z "$( docker images --filter reference="$ELK_LOGSTASH_IMAGE_TAG" -q )" ]; then
    echo "[INFO] There is no image \"$ELK_LOGSTASH_IMAGE_TAG\""
    res=1
fi
if [ -z "$( docker images --filter reference="$ELK_DEJAVU_IMAGE_TAG" -q )" ]; then
    echo "[INFO] There is no image \"$ELK_DEJAVU_IMAGE_TAG\""
    res=1
fi

if $print_error && [ "$res" -eq "1" ]; then
    >&2 echo "[ERROR] The ELK services is not built. Run \"make elk_build\" at first"
fi

if [ "$res" -eq "1" ]; then
    echo "[INFO] The ELK services are not built"
else
    echo "[INFO] The ELK services are built"
fi

exit $res
