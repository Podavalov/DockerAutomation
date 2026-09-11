#!/bin/bash
set -e

export PATH="/usr/local/bin:/opt/homebrew/bin:$PATH"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Start Export"

# --- 1. Запрос пути к проекту ---
while true; do
    echo ""
    echo "Enter the path to the project directory (where docker-compose.yml is)."
    read -r -p "Project path: " USER_INPUT

    if [ -z "$USER_INPUT" ]; then
        echo "ERROR: project path cannot be empty."
        continue
    fi

    # Убираем обрамляющие кавычки и пробелы
    CLEAN_INPUT="$(echo "$USER_INPUT" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' -e 's/^"//' -e 's/"$//' -e "s/^'//" -e "s/'$//")"

    if [ ! -d "$CLEAN_INPUT" ]; then
        echo "ERROR: '$CLEAN_INPUT' is not a directory."
        continue
    fi

    PROJECT_DIR="$(cd "$CLEAN_INPUT" && pwd)"
    break
done

cd "$PROJECT_DIR"
echo "Using project directory: $PROJECT_DIR"

# --- 2. Имя архива = имя папки, которую ввёл пользователь ---
PROJECT_NAME="$(basename "$CLEAN_INPUT")"
DEFAULT_OUT="$SCRIPT_DIR/$PROJECT_NAME.tar"

echo ""
echo "Enter the output .tar file path."
echo "Press Enter to use the default: $DEFAULT_OUT"
read -r -p "Output file: " OUT_INPUT

if [ -z "$OUT_INPUT" ]; then
    OUTPUT_FILE="$DEFAULT_OUT"
else
    OUTPUT_FILE="$(echo "$OUT_INPUT" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' -e 's/^"//' -e 's/"$//' -e "s/^'//" -e "s/'$//")"

    # Если относительный — считаем от папки скрипта
    case "$OUTPUT_FILE" in
        /*) ;;                          # абсолютный — как есть
        *) OUTPUT_FILE="$SCRIPT_DIR/$OUTPUT_FILE" ;;
    esac
fi

OUT_DIR="$(dirname "$OUTPUT_FILE")"
if [ ! -d "$OUT_DIR" ]; then
    echo "ERROR: Output directory '$OUT_DIR' does not exist."
    exit 1
fi

echo "Output file: $OUTPUT_FILE"

# --- 3. Собираем список образов ---
echo ""
echo "Get all images from docker compose images..."

IMAGES="$(docker compose images | awk 'NR>1 {print $2":"$3}' | grep -v '<none>' | sort -u)"

if [ -z "$IMAGES" ]; then
    echo "❌ No images with tags. Build them first: docker compose build"
    exit 1
fi

echo "📦 Saving images into a single archive:"
echo "$IMAGES" | sed 's/^/   /'

# --- 4. Сохраняем ---
if [ -f "$OUTPUT_FILE" ]; then
    echo "Removing existing file: $OUTPUT_FILE"
    rm -f "$OUTPUT_FILE"
fi

# shellcheck disable=SC2086
docker save -o "$OUTPUT_FILE" $IMAGES

# --- 5. Итог ---
echo ""
echo "✅ Done: $OUTPUT_FILE"
echo "   Size: $(du -h "$OUTPUT_FILE" | cut -f1)"