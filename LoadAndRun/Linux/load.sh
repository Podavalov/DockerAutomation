#!/bin/bash
set -e

export PATH="/usr/local/bin:/opt/homebrew/bin:$PATH"

# Папка, где лежит сам скрипт
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "📂 Project dir: $SCRIPT_DIR"

# --- Ищем .tar в папке скрипта ---
shopt -s nullglob
TAR_FILES=( "$SCRIPT_DIR"/*.tar )
shopt -u nullglob

if [ ${#TAR_FILES[@]} -eq 0 ]; then
    echo "❌ No .tar files found in $SCRIPT_DIR"
    exit 1
fi

if [ ${#TAR_FILES[@]} -gt 1 ]; then
    echo "⚠️  Multiple .tar files found, using the first one:"
    for f in "${TAR_FILES[@]}"; do
        echo "   - $(basename "$f")"
    done
fi

TAR_FILE="${TAR_FILES[0]}"
echo "📦 Using archive: $(basename "$TAR_FILE")"

echo "📥 Loading images..."
docker pull redis:7
docker pull nginx:alpine

docker load -i "$TAR_FILE"

echo "✅ Images uploaded."

if [ ! -f ".env" ]; then
    echo "⚠️  .env not found; please create it."
    exit 1
fi

if [ ! -f "infra/nginx/nginx.conf" ]; then
    echo "⚠️  nginx.conf not found."
    exit 1
fi

echo "🚀 Launching containers..."
docker compose up -d

echo "✅ Done. Status:"
docker compose ps