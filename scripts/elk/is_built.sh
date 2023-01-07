#!/bin/bash
# Собран или нет проект ELK. Это скрипт используется и для вывода
# предупреждений и в условных выражениях bash

set -e

curr_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $( realpath "$curr_dir/../init.sh" )
source $( realpath $SCRIPTS/log.sh )

is_built=true
print_error=false
info=false
arg1="${1:-}"
if [ "$arg1" = "--print-error" ]; then
    print_error=true
elif [ "$arg1" = "--info" ]; then
    info=true
fi

images="$ELK_ES_IMAGE_TAG $ELK_KIBANA_IMAGE_TAG $ELK_LOGSTASH_IMAGE_TAG $ELK_DEJAVU_IMAGE_TAG "
for image in $images
do
    if [ -z "$( docker images --filter reference="$image" -q )" ]; then
        log debug "There is no image \"$image\""
        is_built=false
    fi
done

if $info; then
    if $is_built; then
        log info "The ELK services are built"
    else
        log info "The ELK services are not built"
    fi
    exit 0
fi

if $is_built; then
    exit 0
else
    exit 1
fi
