set -e

if [ ! -z ${GAME_IDLE_START} ]; then
    # Контейнеры запускаются под запуск компонентов под дебагером. Запуск
    # и подключение к компоненту будет осуществляться позже через VSCode.
    tail -f /dev/null
    exit 0
fi

log_dir="/opt/kbengine/assets/logs/${GAME_NAME}"
if [ ! -d "$log_dir" ]; then
    mkdir -p "$log_dir"
    chown $KBE_CONTAINER_USER:$KBE_CONTAINER_USER "$log_dir"
fi

runuser \
    --user kbengine \
    --preserve-environment \
    -- ${KBE_BIN_PATH}/${KBE_COMPONENT_NAME} --cid=${KBE_COMPONENT_ID}
