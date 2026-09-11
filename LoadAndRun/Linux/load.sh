#!/bin/bash
set -e

export PATH="/usr/local/bin:/opt/homebrew/bin:$PATH"

PROJECT_DIR="$(pwd)"
cd "/Users/gleb/Documents/GitHub/DockerAutomation/LoadAndRun/Linux" || exit 1



 echo "📥 Загружаем образы ..."
 docker pull redis:7
 docker pull nginx:alpine
 docker load -i eye_of_reservoir.tar

echo "✅ Образы загружены."

if [ ! -f ".env" ]; then
    echo "⚠️  .env не найден, создайте его."
    exit 1
fi

if [ ! -f "infra/nginx/nginx.conf" ]; then
    echo "⚠️  nginx.conf не найден."
    exit 1
fi

echo "🚀 Запускаем контейнеры..."
docker compose up -d

echo "✅ Готово. Статус:"
docker compose ps

