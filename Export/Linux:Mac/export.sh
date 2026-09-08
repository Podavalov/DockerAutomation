#!/bin/bash

# Скрипт экспорта Docker образов и конфигурации
set -e

EXPORT_DIR="docker_export"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
EXPORT_FILE="project_export_${TIMESTAMP}.tar"

echo "📦 Начинаю экспорт проекта..."

# Создание директории для экспорта
mkdir -p ${EXPORT_DIR}

# Получение списка образов
echo "🔍 Получаю список образов..."
IMAGES=$(docker-compose images -q)

if [ -z "$IMAGES" ]; then
    echo "⚠️  Внимание: Образы не найдены. Сначала выполните сборку!"
    exit 1
fi

# Сохранение образов
echo "💾 Сохраняю образы..."
docker save $IMAGES -o ${EXPORT_DIR}/images.tar

# Копирование конфигурации
echo "📄 Копирую конфигурацию..."
cp docker-compose.yml ${EXPORT_DIR}/ 2>/dev/null || true
cp docker-compose.yaml ${EXPORT_DIR}/ 2>/dev/null || true
cp .env ${EXPORT_DIR}/ 2>/dev/null || true
cp -r .env* ${EXPORT_DIR}/ 2>/dev/null || true

# Копирование Dockerfiles и контекстов сборки
echo "📁 Копирую Dockerfiles..."
find . -name "Dockerfile*" -not -path "./${EXPORT_DIR}/*" -exec cp --parents {} ${EXPORT_DIR}/ \;

# Создание полного архива
echo "🗜️  Создаю архив ${EXPORT_FILE}..."
tar -czf ${EXPORT_FILE} ${EXPORT_DIR}/

# Очистка временной директории
rm -rf ${EXPORT_DIR}

echo "✅ Экспорт завершен: ${EXPORT_FILE}"
echo "📊 Размер файла: $(du -h ${EXPORT_FILE} | cut -f1)"