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

# Определение файла для импорта
if [ -n "$1" ]; then
    IMPORT_FILE="$1"
elif [ -f "$EXPORT_PATH/latest.tar.gz" ]; then
    IMPORT_FILE="$EXPORT_PATH/latest.tar.gz"
else
    echo "ERROR" "Файл импорта не найден!"
    echo "INFO" "Использование: $0 [файл_экспорта.tar.gz]"
    exit 1
fi

# Начало импорта
echo "INFO" "📥 Начинаю импорт проекта..."
echo "INFO" "📄 Файл импорта: $IMPORT_FILE"
echo "INFO" "📁 Директория назначения: $PROJECT_PATH"
echo "========================================"

# Проверка существования файла
if [ ! -f "$IMPORT_FILE" ]; then
    echo "ERROR" "Файл $IMPORT_FILE не найден!"
    exit 1
fi

# Создание бэкапа перед импортом
if [ "$AUTO_BACKUP_BEFORE_IMPORT" = true ] && [ -d "$PROJECT_PATH" ]; then
    echo "INFO" "💾 Создаю бэкап перед импортом..."
    BACKUP_FILE="${PROJECT_PATH}_backup_$(date +%Y%m%d_%H%M%S).tar.gz"
    tar -czf "$BACKUP_FILE" -C "$(dirname "$PROJECT_PATH")" "$(basename "$PROJECT_PATH")" 2>/dev/null || true
    echo "INFO" "✓ Бэкап создан: $BACKUP_FILE"
fi

# Создание директории назначения
mkdir -p "$PROJECT_PATH"

# Создание временной директории
TEMP_DIR=$(mktemp -d)
echo "DEBUG" "Временная директория: $TEMP_DIR"

# Распаковка архива
echo "INFO" "🗜️  Распаковываю архив..."
tar -xzf "$IMPORT_FILE" -C "$TEMP_DIR"

# Импорт образов
if [ "$IMPORT_IMAGES" = true ]; then
    if [ -f "$TEMP_DIR/images.tar" ]; then
        echo "INFO" "💾 Импортирую образы..."
        if docker load -i "$TEMP_DIR/images.tar"; then
            echo "INFO" "✓ Образы импортированы"
        else
            echo "ERROR" "Ошибка при импорте образов"
            rm -rf "$TEMP_DIR"
            exit 1
        fi
    else
        echo "WARNING" "Файл с образами не найден в архиве"
    fi
fi

# Импорт конфигурации
if [ "$IMPORT_CONFIG" = true ]; then
    echo "INFO" "📄 Импортирую конфигурацию..."
    
    # Копирование compose файла
    for compose_file in docker-compose.yml docker-compose.yaml compose.yml compose.yaml; do
        if [ -f "$TEMP_DIR/$compose_file" ]; then
            cp "$TEMP_DIR/$compose_file" "$PROJECT_PATH/"
            echo "INFO" "✓ Скопирован $compose_file"
        fi
    done
    
    # Копирование override файлов
    for override in docker-compose.override.yml docker-compose.override.yaml compose.override.yml compose.override.yaml; do
        if [ -f "$TEMP_DIR/$override" ]; then
            cp "$TEMP_DIR/$override" "$PROJECT_PATH/"
            echo "INFO" "✓ Скопирован $override"
        fi
    done
    
    # Копирование .env файлов
    for env_file in "$TEMP_DIR"/.env*; do
        if [ -f "$env_file" ]; then
            cp "$env_file" "$PROJECT_PATH/"
            echo "INFO" "✓ Скопирован $(basename "$env_file")"
        fi
    done
    
    # Восстановление Dockerfiles
    echo "INFO" "📁 Восстанавливаю Dockerfiles..."
    cd "$TEMP_DIR"
    find . -name "Dockerfile*" -exec cp --parents {} "$PROJECT_PATH/" \;
    cd - > /dev/null
fi

# Очистка
rm -rf "$TEMP_DIR"

# Отправка уведомления
send_notification "Docker Import Success" "Проект импортирован в: $PROJECT_PATH"

echo "INFO" "✅ Импорт завершен успешно!"
echo "INFO" "📁 Проект доступен в: $PROJECT_PATH"