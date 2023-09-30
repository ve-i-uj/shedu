#!/bin/bash
#
# Скрипт для запуска компонента Supervisor в Docker контейнере
#

curr_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $( realpath "$curr_dir/../log.sh" )

function sigterm_handler()
{
    log info "SIGTERM is catched"
    # Уведомление Супервизору, что компонент останавливается
    text=$( LOG_LEVEL=ERROR $ENKI_PYTHON /opt/enki/tools/cmd/supervisor/onStopComponent.py )
    status=$?
    if [ $status -ne 0 ]; then
        log error "Error text: $text"
    fi
}

if [ ! -z ${GAME_IDLE_START} ]; then
    log info "The \"GAME_IDLE_START\" variable is set. Start a dummy process"
    tail -f /dev/null &
    wait
    log info "The dummy process is stopped. Exit"
    exit 0
fi

log_dir="/opt/kbengine/assets/logs/${GAME_NAME}"
if [ ! -d "$log_dir" ]; then
    log info "Create the log directory \"$log_dir\""
    mkdir -p "$log_dir"
    chown $KBE_CONTAINER_USER:$KBE_CONTAINER_USER "$log_dir"
fi
touch "$log_dir/supervisor.log"
chown $KBE_CONTAINER_USER:$KBE_CONTAINER_USER "$log_dir/supervisor.log"

if [ ! -z ${DEBUG_SUPERVISOR} ]; then
    # Контейнер с Супервизором запускается под запуск компонентов под дебагером. Запуск
    # и подключение к компоненту будет осуществляться позже через VSCode.
    # ${ENKI_PYTHON} -m debugpy --listen 0.0.0.0:18198 --wait-for-client /opt/enki/enki/app/supervisor/main.py > "$log_dir/supervisor.log"
    cmd="${ENKI_PYTHON} -m debugpy --listen 0.0.0.0:18198 /opt/enki/enki/app/supervisor/main.py"
else
    # Обычный запуск компонента
    cmd="${ENKI_PYTHON} /opt/enki/enki/app/supervisor/main.py"
fi

log info "Start the \"$KBE_COMPONENT_NAME\" component by \"$KBE_CONTAINER_USER\" user"
runuser \
    --user kbengine \
    --preserve-environment \
    -- $cmd > "$log_dir/supervisor.log" \
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
