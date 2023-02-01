mkdir -p /opt/kbengine/assets/logs/$KBE_GAME_NAME >/dev/null
mkdir -p /opt/kbengine/assets/logs/$KBE_GAME_NAME/packets >/dev/null

bash /opt/kbengine/assets/start_server.sh

# Скрипт не читает новопоявившиеся файлы. Поэтому чуть-чуть подождём,
# когда KBE раскрутится и создаст файлы логов
sleep 5
/opt/kbengine/assets/.shedu/scripts/deploy/tail_logs.sh
