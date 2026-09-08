#!/bin/bash
set -e

export PATH="/usr/local/bin:/opt/homebrew/bin:$PATH"

cd "/Users/glebpodavalov/Documents/GitHub/DockerAutomation/LoadAndRun/Linux" || exit 1


echo "🚀 Запускаем контейнеры..."
docker compose up -d

echo "✅ Готово. Статус:"
docker compose ps

