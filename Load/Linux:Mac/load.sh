#!/bin/bash

# Скрипт импорта Docker образов и конфигурации
set -e

if [ -z "$1" ]; then
    echo "❌ Укажите файл экспорта!"
    echo "Использование: ./import.sh <файл_экспорта.tar.gz>"
    exit 1
fi

EXPORT_FILE=$1

echo "📥 Начинаю импорт проекта из ${EXPORT_FILE}..."

# Проверка существования файла
if [ ! -f "$EXPORT_FILE" ]; then
    echo "❌ Файл ${EXPORT_FILE} не найден!"
    exit 1
fi

# Распаковка архива
echo "🗜️  Распаковываю архив..."
tar -xzf ${EXPORT_FILE}

# Импорт образов
if [ -f "docker_export/images.tar" ]; then
    echo "💾 Импортирую образы..."
    docker load -i docker_export/images.tar
else
    echo "⚠️  Файл с образами не найден!"
fi

# Копирование конфигурации
echo "📄 Восстанавливаю конфигурацию..."
cp docker_export/docker-compose.yml . 2>/dev/null || true
cp docker_export/docker-compose.yaml . 2>/dev/null || true
cp docker_export/.env . 2>/dev/null || true

# Восстановление Dockerfiles
if [ -d "docker_export" ]; then
    find docker_export -name "Dockerfile*" -exec cp --parents {} . \;
fi

# Очистка
rm -rf docker_export

echo "✅ Импорт завершен успешно!"