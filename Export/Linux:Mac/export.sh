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

# Начало экспорта
echo "INFO" "📦 Начинаю экспорт проекта..."
echo "INFO" "📁 Путь к проекту: $PROJECT_PATH"
echo "INFO" "📁 Директория экспорта: $EXPORT_PATH"

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
PROJECT_NAME=$(basename "$PROJECT_PATH")
EXPORT_FILE="${PROJECT_NAME}_${TIMESTAMP}.tar.gz"

echo "========================================"

# Создание директории для экспорта
mkdir -p "$EXPORT_PATH"

# Определение compose файла
COMPOSE_FILE=$(find_compose_file "$PROJECT_PATH")

if [ -z "$COMPOSE_FILE" ]; then
    echo "ERROR" "Compose файл не найден в $PROJECT_PATH"
    exit 1
fi

# Переход в директорию проекта
cd "$PROJECT_PATH"

# Создание временной директории
TEMP_DIR=$(mktemp -d)
echo "DEBUG" "Временная директория: $TEMP_DIR"

# Экспорт образов
if [ "$EXPORT_IMAGES" = true ]; then
    echo "INFO" "🔍 Получаю список образов..."
    IMAGES=$(docker compose -f "$COMPOSE_FILE" images -q 2>/dev/null || true)
    
    if [ -n "$IMAGES" ]; then
        echo "INFO" "💾 Сохраняю образы..."
        if docker save $IMAGES -o "$TEMP_DIR/images.tar"; then
            echo "INFO" "✓ Образы сохранены"
        else
            echo "ERROR" "Ошибка при сохранении образов"
            rm -rf "$TEMP_DIR"
            exit 1
        fi
    else
        echo "WARNING" "Образы не найдены"
    fi
fi

# Экспорт конфигурации
if [ "$EXPORT_CONFIG" = true ]; then
    echo "INFO" "📄 Копирую конфигурацию..."
    
    # Копирование compose файла
    cp "$COMPOSE_FILE" "$TEMP_DIR/"
    echo "DEBUG" "Скопирован $COMPOSE_FILE"
    
    # Копирование .env файлов
    for env_file in .env .env.*; do
        if [ -f "$env_file" ]; then
            cp "$env_file" "$TEMP_DIR/"
            echo "DEBUG" "Скопирован $env_file"
        fi
    done
    
    # Копирование Dockerfiles
    find . -name "Dockerfile*" -not -path "./.git/*" -not -path "./node_modules/*" \
        -exec cp --parents {} "$TEMP_DIR/" \;
    
    # Копирование override файлов
    for override in docker-compose.override.yml docker-compose.override.yaml compose.override.yml compose.override.yaml; do
        if [ -f "$override" ]; then
            cp "$override" "$TEMP_DIR/"
            echo "DEBUG" "Скопирован $override"
        fi
    done
fi

# Создание архива
echo "INFO" "🗜️  Создаю архив..."
cd "$TEMP_DIR"

if [ "$EXPORT_COMPRESS" = true ]; then
    tar -czf "$EXPORT_PATH/$EXPORT_FILE" .
else
    tar -cf "$EXPORT_PATH/${EXPORT_FILE%.gz}" .
    EXPORT_FILE="${EXPORT_FILE%.gz}"
fi

# Очистка временной директории
cd - > /dev/null
rm -rf "$TEMP_DIR"

# Вывод информации
FULL_PATH="$EXPORT_PATH/$EXPORT_FILE"
echo "INFO" "✅ Экспорт завершен: $FULL_PATH"
echo "INFO" "📊 Размер файла: $(du -h "$FULL_PATH" | cut -f1)"
echo "INFO" "📝 MD5: $(md5sum "$FULL_PATH" | cut -d' ' -f1)"

# Создание ссылки на последний экспорт
ln -sf "$FULL_PATH" "$EXPORT_PATH/latest.tar.gz"
echo "INFO" "🔗 Создана ссылка: $EXPORT_PATH/latest.tar.gz"

# Очистка старых экспортов
cleanup_old_exports

# Отправка уведомления
send_notification "Docker Export Success" "Проект экспортирован: $FULL_PATH"

echo "INFO" "✅ Экспорт завершен успешно!"