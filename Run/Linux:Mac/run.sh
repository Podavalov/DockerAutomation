#!/bin/bash

set -e

# Определение директории скрипта и загрузка конфигурации
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CONFIG_FILE="$SCRIPT_DIR/config.sh"

if [ ! -f "$CONFIG_FILE" ]; then
    echo "❌ Ошибка: config.sh не найден!"
    exit 1
fi

source "$CONFIG_FILE"

# Начало запуска
echo "INFO" "🚀 Запускаю проект..."
echo "INFO" "📁 Путь к проекту: $PROJECT_PATH"
echo "INFO" "🔧 Режим запуска: $RUN_MODE"
echo "========================================"

# Определение compose файла
COMPOSE_FILE=$(find_compose_file "$PROJECT_PATH")

if [ -z "$COMPOSE_FILE" ]; then
    echo "ERROR" "Compose файл не найден в $PROJECT_PATH"
    exit 1
fi

echo "INFO" "📄 Используется файл: $COMPOSE_FILE"

# Переход в директорию проекта
cd "$PROJECT_PATH"

# Формирование команды запуска
RUN_CMD="docker compose -f $COMPOSE_FILE up"

# Добавление параметров
if [ "$RUN_MODE" = "detached" ]; then
    RUN_CMD="$RUN_CMD -d"
    echo "INFO" "🖥️  Запуск в фоновом режиме..."
else
    echo "INFO" "🖥️  Запуск в foreground режиме..."
fi

if [ "$AUTO_BUILD" = true ]; then
    RUN_CMD="$RUN_CMD --build"
    echo "INFO" "🔨 С автоматической сборкой..."
fi

if [ "$FORCE_RECREATE" = true ]; then
    RUN_CMD="$RUN_CMD --force-recreate"
    echo "INFO" "🔄 С принудительным пересозданием..."
fi

if [ "$REMOVE_ORPHANS" = true ]; then
    RUN_CMD="$RUN_CMD --remove-orphans"
fi

# Добавление масштабирования
if [ -n "$SCALE_SERVICES" ]; then
    for scale in $SCALE_SERVICES; do
        RUN_CMD="$RUN_CMD --scale $scale"
    done
    echo "INFO" "📊 Масштабирование: $SCALE_SERVICES"
fi

# Добавление конкретного сервиса
if [ -n "$START_SERVICE" ]; then
    RUN_CMD="$RUN_CMD $START_SERVICE"
    echo "INFO" "🎯 Запускаю сервис: $START_SERVICE"
else
    echo "INFO" "🎯 Запускаю все сервисы"
fi

# Выполнение запуска
echo "DEBUG" "Выполняю: $RUN_CMD"
if eval $RUN_CMD; then
    echo "INFO" "✅ Проект запущен!"
else
    echo "ERROR" "Ошибка при запуске проекта"
    exit 1
fi

# Проверка статуса
echo ""
echo "INFO" "📊 Статус контейнеров:"
docker compose -f "$COMPOSE_FILE" ps

# Показать логи если foreground
if [ "$RUN_MODE" = "foreground" ]; then
    echo ""
    echo "INFO" "📋 Логи:"
    docker compose -f "$COMPOSE_FILE" logs -f
fi

# Отправка уведомления
send_notification "Docker Run Success" "Проект $PROJECT_PATH запущен"

echo ""
echo "INFO" "✅ Проект успешно работает!"