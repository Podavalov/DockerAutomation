#!/bin/bash
set -e

export PATH="/usr/local/bin:/opt/homebrew/bin:$PATH"

PROJECT_DIR="/Users/gleb/Documents/GitHub/Eye_of_reservoir_encrypted"
cd "$PROJECT_DIR" || exit 1


OUTPUT_FILE="/Users/gleb/Documents/GitHub/DockerAutomation/LoadAndRun/Linux/eye_of_reservoir.tar"

# Получаем все образы из docker compose images в формате repository:tag
# Пропускаем заголовок (NR>1), берём 2-е и 3-е поля (REPOSITORY и TAG)
IMAGES=$(docker compose images | awk 'NR>1 {print $2":"$3}' | grep -v '<none>' | sort -u)

if [ -z "$IMAGES" ]; then
    echo "❌ Нет образов с тегами. Сначала соберите: docker compose build"
    exit 1
fi

echo "📦 Сохраняем образы в один архив:"
echo "$IMAGES"

docker save -o "$OUTPUT_FILE" $IMAGES

echo "✅ Готово: $OUTPUT_FILE"
echo "   Размер: $(du -h "$OUTPUT_FILE" | cut -f1)"