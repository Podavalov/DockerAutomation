#!/bin/bash

# ============================================
# ЦЕНТРАЛИЗОВАННАЯ КОНФИГУРАЦИЯ
# ============================================

# Путь к проекту
export PROJECT_PATH="/Users/glebpodavalov/Documents/GitHub/Eye_of_reservoir"

# Путь для экспорта
export EXPORT_PATH="/Users/glebpodavalov/Desktop/dock"

# Режим запуска: detached | foreground
export RUN_MODE="detached"

# Дополнительные настройки
export COMPOSE_FILE_NAME="docker-compose.yml"  # если не стандартное имя
export DOCKER_REGISTRY=""                       # registry.example.com:5000
export IMAGE_TAG="latest"                       # тег образов

# ============================================
# НЕ ИЗМЕНЯЙТЕ НИЖЕ ЭТОЙ ЛИНИИ
# ============================================