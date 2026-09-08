# Requires: Docker CLI

#$env:Path += ";C:\usr\local\bin;C:\opt\homebrew\bin" # Обновление путей для PowerShell

# !!! ВНИМАНИЕ: Измените этот путь на ваш реальный Windows путь !!!
$PROJECT_DIR = "C:\Users\glebpodavalov\Documents\GitHub\Eye_of_reservoir"
Set-Location $PROJECT_DIR -ErrorAction Stop


# !!! ВНИМАНИЕ: Убедитесь, что эта папка существует и доступна !!!
$OUTPUT_FILE = "C:\Users\glebpodavalov\Documents\GitHub\DockerAutomation\LoadAndRun\Linux\eye_of_reservoir.tar"

Write-Host "Получаем все образы из docker compose images..."

# Логика получения изображений сложнее, так как PowerShell не имеет прямого аналога 'awk' для парсинга таблиц Docker CLI.
# Мы используем Select-String и группировку для имитации логики Bash.
$images = docker compose images | Select-Object -Skip 1 | Where-Object { $_ -notmatch '<none>' } | ForEach-Object {
    # Предполагается, что REPOSITORY это $2, а TAG это $3
    $repo = $_[0]
    $tag = $_[1]
    "$repo:$tag"
} | Select-Object -Unique

if (-not $images) {
    Write-Host "❌ Нет образов с тегами. Сначала соберите: docker compose build" -ForegroundColor Red
    exit 1
}

Write-Host "📦 Сохраняем образы в один архив:"
$images | Write-Host

# Запуск команды сохранения (передаем список изображений)
docker save -o $OUTPUT_FILE $images

Write-Host ""
Write-Host "✅ Готово: $OUTPUT_FILE" -ForegroundColor Green
# Получение размера файла в PowerShell
(Get-Item $OUTPUT_FILE).Length / 1MB | Select-Object "{0:N2}" -f '{0} MB' -f $_.Length / 1MB
