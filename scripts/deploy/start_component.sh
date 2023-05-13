if [ ! -z ${GAME_IDLE_START} ]; then
    # Контейнеры запускаются под запуск компонентов под дебагером. Запуск
    # и подключение к компоненту будет осуществляться позже через VSCode.
    tail -f /dev/null
else
    # Обычный запуск компонента
    ${KBE_BIN_PATH}/${KBE_COMPONENT_NAME} --cid=${KBE_COMPONENT_ID}
fi
