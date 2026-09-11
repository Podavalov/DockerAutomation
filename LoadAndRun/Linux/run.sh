#!/bin/bash
set -e

export PATH="/usr/local/bin:/opt/homebrew/bin:$PATH"

# Папка, где лежит сам скрипт
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "📂 Project dir: $SCRIPT_DIR"
echo "🚀 Launching containers..."
docker compose up -d

echo "✅ Done. Status:"
docker compose ps