set -e

if [ ! -z ${GAME_IDLE_START} ]; then
    tail -f /dev/null
    exit 0
fi

log_dir="/opt/kbengine/assets/logs/${GAME_UNIQUE_NAME}"
if [ ! -d "$log_dir" ]; then
    mkdir -p "$log_dir"
    chown $KBE_CONTAINER_USER:$KBE_CONTAINER_USER "$log_dir"
fi
touch "$log_dir/supervisor.log"
chown $KBE_CONTAINER_USER:$KBE_CONTAINER_USER "$log_dir/supervisor.log"

if [ ! -z ${DEBUG_SUPERVISOR} ]; then
    # Контейнеры запускаются под запуск компонентов под дебагером. Запуск
    # и подключение к компоненту будет осуществляться позже через VSCode.
    # ${ENKI_PYTHON} -m debugpy --listen 0.0.0.0:18198 --wait-for-client /opt/enki/enki/app/supervisor/main.py > "$log_dir/supervisor.log"
    cmd="${ENKI_PYTHON} -m debugpy --listen 0.0.0.0:18198 /opt/enki/enki/app/supervisor/main.py"
else
    # Обычный запуск компонента
    cmd="${ENKI_PYTHON} /opt/enki/enki/app/supervisor/main.py"
fi

runuser \
    --user kbengine \
    --preserve-environment \
    -- $cmd > "$log_dir/supervisor.log"
