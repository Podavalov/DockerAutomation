#!/bin/bash#!/bin/bash

# Скрипт запуска Docker Compose проекта
set -e

echo "🚀 Запускаю проект..."

# Проверка наличия docker-compose.yml
if [ ! -f "docker-compose.yml" ] && [ ! -f "docker-compose.yaml" ]; then
    echo "❌ Ошибка: docker-compose.yml не найден!"
    exit 1
fi

# Параметры запуска
DETACHED="-d"
BUILD=""

# Обработка аргументов
while [[ $# -gt 0 ]]; do
    case $1 in
        --foreground)
            DETACHED=""
            shift
            ;;
        --build)
            BUILD="--build"
            shift
            ;;
        --service)
            SERVICE="$2"
            shift 2
            ;;
        *)
            echo "Неизвестный параметр: $1"
            echo "Доступные параметры:"
            echo "  --foreground  - запуск в foreground режиме"
            echo "  --build      - пересобрать перед запуском"
            echo "  --service    - запустить конкретный сервис"
            exit 1
            ;;
    esac
done

# Запуск
if [ -n "$SERVICE" ]; then
    echo "🎯 Запускаю сервис: ${SERVICE}"
    docker-compose up ${DETACHED} ${BUILD} ${SERVICE}
else
    echo "🎯 Запускаю все сервисы"
    docker-compose up ${DETACHED} ${BUILD}
fi

# Проверка статуса
echo "📊 Статус контейнеров:"
docker-compose ps

# Показать логи если в foreground
if [ -z "$DETACHED" ]; then
    echo "📋 Логи:"
    docker-compose logs -f
fi

echo "✅ Проект запущен!"