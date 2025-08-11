#!/bin/bash

# Список контейнеров
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

echo "Остановка tcpdump во всех контейнерах..."

# Останавливаем tcpdump в каждом контейнере
for container in "${containers[@]}"; do
    echo "Проверяем контейнер $container..."
    # Находим PID процесса tcpdump и отправляем SIGTERM
    pid=$(docker exec "$container" sh -c "pgrep tcpdump" 2>/dev/null)
    
    if [ -n "$pid" ]; then
        echo "Найден tcpdump (PID $pid) в $container, останавливаем..."
        docker exec "$container" sh -c "kill -TERM $pid"
        sleep 0.5  # Даем процессу время завершиться
    else
        echo "В контейнере $container tcpdump не запущен."
    fi
done

echo "Готово! Все tcpdump остановлены."
