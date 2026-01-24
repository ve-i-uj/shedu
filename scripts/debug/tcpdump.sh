#!/bin/bash

set -e

USAGE="
Usage. Start tcpdump for all interfaces. Example (by sudo or root):

KBE_COMPONENT_NAME=supervisor KBE_COMPONENT_ID=1001 GAME_NAME=kbe-game bash $0 \
{start|stop|restart|status}
"

help=false
for arg in "$@"
do
    key=$( echo "$arg" | cut -f1 -d= )
    value=$( echo "$arg" | cut -f2 -d= )

    case "$key" in
        --help) help=true ;;
        -h) help=true ;;
        *)
    esac
done
if [ "$help" = true ]; then
    echo -e "$USAGE"
    exit 0
fi

if [ -z "${1:-}" ]; then
    echo -e "$USAGE"
    exit 1
fi

# Импорт переменных проекта и библиотеки для логов
curr_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $( realpath "$curr_dir/../init.sh" )
source $( realpath $SCRIPTS/log.sh )

if [ -z "${KBE_COMPONENT_NAME:=}" ]; then
    log error "Ошибка: переменная окружения KBE_COMPONENT_NAME не установлена"
    echo -e "$USAGE"
    exit 1
fi
if [ -z "${KBE_COMPONENT_ID:=}" ]; then
    log error "Ошибка: переменная окружения KBE_COMPONENT_ID не установлена"
    echo -e "$USAGE"
    exit 1
fi
if [ -z "${GAME_NAME:=}" ]; then
    log error "Ошибка: переменная окружения GAME_NAME не установлена"
    echo -e "$USAGE"
    exit 1
fi
component_name="$KBE_COMPONENT_NAME"
component_id="$KBE_COMPONENT_ID"
game_name="$GAME_NAME"

dump_dir="/tmp/kbedump/$game_name/$(date +%Y%m%d-%H%M%S)"
mkdir -p "$dump_dir"

ip_addr=$(hostname -I | awk '{print $1}')
pcap_file="$dump_dir/${component_name}-${component_id}-${ip_addr}.pcap"

# Имя файла
pid_file="/tmp/tcpdump.pid"

stop_tcpdump() {
    if [ ! -f "$pid_file" ]; then
        log info "The pid file \"$pid_file\" does not exist. Exit"
        return
    fi

    pid=$(cat "$pid_file")
    log info "Try to kill the process \"$pid\" and remove the pid file \"$pid_file\" ..."

    set +e
    kill_output=$(kill -0 "$pid" 2>&1)
    set -e

    if [ ! -z "$kill_output" ]; then        
        log error "Failed to stop the process \"$pid\". Error: \"$kill_output\". Exit"
        return
    fi

    set +e
    kill_output=$(kill "$pid" 2>&1)
    set -e
    exit_code=$?

    if [ $exit_code -ne 0 ]; then        
        log error "Failed to stop process \"$pid\". Error: \"$kill_output\". Exit"
        return
    fi

    log info "The process \"$pid\" stopped"

    log info "The file \"$pid_file\" removed"
    rm -f "$pid_file"

    log info "The tcpdump process (PID: \"$pid\") is stopped"
    log info "Done"
}

start_tcpdump() {
    if [ -f "$pid_file" ]; then
        pid=$(cat "$pid_file")
        log info "tcpdump is already running (PID: $pid), the pid file \"$pid_file\". Exit"
        return
    fi

    log info "Starting tcpdump ..."

    error_file=$(mktemp)
    tcpdump -s 0 -i any -U -w "$pcap_file" 2>"$error_file" &
    pid=$!

    # Даем время на запуск
    sleep 0.5

    if ! kill -0 "$pid" 2>/dev/null; then
        # Процесс упал, читаем ошибки из файла
        error_message=$(cat "$error_file")
        rm -f "$error_file"
        log error "tcpdump is not started. Error: \"$error_message\". Exit"
        return
    fi

    # Если успешно, удаляем временный файл
    rm -f "$error_file"

    echo $! > "$pid_file"

    log info "tcpdump started with PID: $(cat $pid_file)"
    log info "Pcap file: $pcap_file"
    log info "Done"
}

status_tcpdump() {
    if [ ! -f "$pid_file" ]; then
        log info "The pid file \"$pid_file\" does not exist"
        return
    fi

    pid=$(cat "$pid_file")
    log info "The PID is \"$pid\". The pid file is \"$pid_file\""

    set +e
    kill_output=$(kill -0 "$pid" 2>&1)
    set -e

    if [ ! -z "$kill_output" ]; then        
        log error "Failed to check the process \"$pid\". Error: \"$kill_output\". Exit"
        return
    fi

    log info "The tcpdump process \"$pid\" is running"
}

# Обработка аргументов
case "${1:-}" in
    start)
        start_tcpdump
        ;;
    stop)
        stop_tcpdump
        ;;
    restart)
        stop_tcpdump
        start_tcpdump
        ;;
    status)
        status_tcpdump
        ;;
    *)
        log info "Usage: $0 {start|stop|restart|status}"
        exit 1
        ;;
esac
