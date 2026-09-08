#!/bin/bash

# Скрипт сборки Docker Compose проекта
set -e

echo "🔨 Начинаю сборку проекта..."

# Проверка наличия docker-compose.yml
if [ ! -f "docker-compose.yml" ] && [ ! -f "docker-compose.yaml" ]; then
    echo "❌ Ошибка: docker-compose.yml не найден!"
    exit 1
fi

# Сборка с кешем или без
if [ "$1" == "--no-cache" ]; then
    echo "📦 Сборка без кеша..."
    docker-compose build --no-cache
else
    echo "📦 Сборка с кешем..."
    docker-compose build
fi

echo "✅ Сборка завершена успешно!"