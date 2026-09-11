#!/bin/bash

set -e

echo "Start Build"

# Добавить Docker в PATH если нужно
export PATH="/usr/local/bin:$PATH"

# Проверить Docker
if ! command -v docker &> /dev/null; then
    echo "ERROR: Docker is not installed or not in PATH!"
    echo "Please install Docker Desktop from https://www.docker.com/products/docker-desktop/"
    exit 1
fi

echo "Docker version: $(docker --version)"

DIR="/Users/gleb/Documents/GitHub/Eye_of_reservoir_encrypted"

if [ ! -d "$DIR" ]; then
    echo "ERROR: Directory $DIR does not exist!"
    exit 1
fi

echo "Changing to directory: $DIR"
cd "$DIR" || exit 1

cd "$DIR/frontend"
npm install

cd "$DIR"

echo "Current directory: $(pwd)"

if [ ! -f "docker-compose.yml" ] && [ ! -f "compose.yaml" ]; then
    echo "ERROR: No docker-compose.yml or compose.yaml found!"
    exit 1
fi

echo "Starting Docker Compose..."

# Проверить наличие docker compose
if docker compose version &> /dev/null; then
    docker compose up --build
else
    echo "ERROR: Docker Compose is not available!"
    exit 1
fi