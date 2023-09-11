#!/bin/bash
#
# Скрипт для запуска компонента KBEngine в Docker контейнере
#

curr_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $( realpath "$curr_dir/../log.sh" )

function sigterm_handler()
{
    log info "SIGTERM is catched"
    log info "Send the \"reqCloseServer\" message to the \"$KBE_COMPONENT_NAME\" component"
    # Здесь отправляется сообщение о завершении работы компонента ::reqCloseServer
    # Дожидаемся ответа и по коду возврата понимаем получилось или нет. Дальше ждём
    # в петле, что завершится процесс компонента. Если не завершается его Docker
    # прибьёт через SIGKILL через "KBE_STOP_GRACE_PERIOD" времени.
    text=$( LOG_LEVEL=ERROR $ENKI_PYTHON /opt/enki/tools/cmd/common/reqCloseServer.py )
    status=$?
    if [ $status -ne 0 ]; then
        log error "Error text: $text"
        # И ждём, что Docker прибьёт по SIGKILL через KBE_STOP_GRACE_PERIOD
    fi
}

# Ловим от Docker сигнал на остановку, чтобы сообщить компоненту через
# сообщение reqCloseServer, что ему нужно начать останавливаться. Перехват
# сигнала от Docker и отправка сообщения заменяют остановку через Machine в
# архитектуре KBEngine (т.к. Machine убрана из кластера).
trap sigterm_handler SIGTERM

if [ ! -z ${GAME_IDLE_START} ]; then
    # Контейнеры запускаются под запуск компонентов под дебагером. Запуск
    # и подключение к компоненту будет осуществляться позже через VSCode.
    log info "The \"$GAME_IDLE_START\" variable is set. Start a dummy process"
    tail -f /dev/null &
    wait
    log info "The dummy process is stopped. Exit"
    exit 0
fi

log_dir="/opt/kbengine/assets/logs/${GAME_NAME}"
if [ ! -d "$log_dir" ]; then
    log info "Create the log directory \"$log_dir\""
    mkdir -p "$log_dir"
fi
chown $KBE_CONTAINER_USER:$KBE_CONTAINER_USER "$log_dir"

log info "Start the \"$KBE_COMPONENT_NAME\" component by \"$KBE_CONTAINER_USER\" user"
runuser \
    --user kbengine \
    --preserve-environment \
    -- ${KBE_BIN_PATH}/${KBE_COMPONENT_NAME} --cid=${KBE_COMPONENT_ID} \
    &

wait $!

log info "Waiting for the component stopped (it will be killed after \"$KBE_STOP_GRACE_PERIOD\")"
while sleep 1; do
  ps aux | grep "cid=${KBE_COMPONENT_ID}" | grep -q -v grep
  process_1_status=$?
  if [ $process_1_status -ne 0 ]; then
    log info "The component \"$KBE_COMPONENT_NAME\" has been stopped. Exit"
    exit 1
  fi
  log debug "Waiting for a second ..."
done
