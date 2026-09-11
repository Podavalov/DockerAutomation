#!/bin/bash
set -e

echo "Start Build"

# Добавить Docker в PATH если нужно
export PATH="/usr/local/bin:/opt/homebrew/bin:$PATH"

# --- 1. Проверка Docker ---
if ! command -v docker &> /dev/null; then
    echo "ERROR: Docker is not installed or not in PATH!"
    echo "Please install Docker Desktop from https://www.docker.com/products/docker-desktop/"
    exit 1
fi

echo "Docker version: $(docker --version)"

# --- 2. Запрос пути к проекту ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

while true; do
    echo ""
    echo "Enter the path to the project directory."
    echo "Press Enter to use the default: $SCRIPT_DIR"
    read -r -p "Project path: " USER_INPUT

    if [ -z "$USER_INPUT" ]; then
        DIR="$SCRIPT_DIR"
    else
        # Убираем обрамляющие кавычки и пробелы
        DIR="$(echo "$USER_INPUT" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' -e 's/^"//' -e 's/"$//' -e "s/^'//" -e "s/'$//")"
    fi

    if [ ! -d "$DIR" ]; then
        echo "ERROR: '$DIR' is not a directory."
        continue
    fi

    # Абсолютный путь
    DIR="$(cd "$DIR" && pwd)"
    break
done

echo "Using project directory: $DIR"

# --- 3. npm install во frontend ---
if [ ! -d "$DIR/frontend" ]; then
    echo "ERROR: '$DIR/frontend' not found!"
    exit 1
fi

echo "Running 'npm install' in $DIR/frontend ..."
cd "$DIR/frontend"
npm install

# --- 4. Проверка compose-файла ---
cd "$DIR"
echo "Current directory: $(pwd)"

if [ ! -f "docker-compose.yml" ] && [ ! -f "compose.yaml" ]; then
    echo "ERROR: No docker-compose.yml or compose.yaml found!"
    exit 1
fi

# --- 5. Запуск ---
echo "Starting Docker Compose..."

if docker compose version &> /dev/null; then
    docker compose up --build
else
    echo "ERROR: Docker Compose is not available!"
    exit 1
fi