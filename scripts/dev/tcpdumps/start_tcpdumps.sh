#!/bin/bash

# Создаем директорию для дампов (если не существует)
docker exec kbe-game-supervisor mkdir -p /tmp/kbedump

# Массив с именами контейнеров
containers=(
    "kbe-game-loginapp"
    "kbe-game-cellapp-1"
    "kbe-game-baseapp-1"
    "kbe-game-cellappmgr"
    "kbe-game-baseappmgr"
    "kbe-game-dbmgr"
    "kbe-game-interfaces"
    "kbe-game-logger"
    "kbe-game-supervisor"
)

# Запускаем tcpdump в каждом контейнере
for container in "${containers[@]}"; do
    echo "Starting tcpdump in $container..."
    docker exec \
        -d "$container" \
        /bin/bash -c '
            component_name="${KBE_COMPONENT_NAME}"
            component_id="${KBE_COMPONENT_ID}"
            ip=$(hostname -I | awk '\''{print $1}'\'')
            tcpdump -s 0 -i any -U -w "/tmp/kbedump/${component_name}-${component_id}-${ip}.pcap"
        '
done

echo "All tcpdump processes started in background."
