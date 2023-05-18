log_dir=/opt/kbengine/assets/logs/${GAME_UNIQUE_NAME}
mkdir -p $log_dir

if [ ! -z ${DEBUG_SUPERVISOR} ]; then
    # Контейнеры запускаются под запуск компонентов под дебагером. Запуск
    # и подключение к компоненту будет осуществляться позже через VSCode.
    ${ENKI_PYTHON} -m debugpy --listen 0.0.0.0:18198 /opt/enki/enki/app/supervisor/main.py > $log_dir/supervisor.log
    # ${ENKI_PYTHON} -m debugpy --listen 0.0.0.0:18198 --wait-for-client /opt/enki/enki/app/supervisor/main.py > $log_dir/supervisor.log
else
    # Обычный запуск компонента
    ${ENKI_PYTHON} /opt/enki/enki/app/supervisor/main.py > $log_dir/supervisor.log
fi
