
$PROJECT_DIR = "Путь к проекту"
Set-Location $PROJECT_DIR -ErrorAction Stop


$OUTPUT_FILE = "Путь к DockerAutomation\LoadAndRun\Windows\eye_of_reservoir.tar"

Write-Host "Получаем все образы из docker compose images..."


$images = docker compose images | Select-Object -Skip 1 | Where-Object { $_ -notmatch '<none>' } | ForEach-Object {

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


docker save -o $OUTPUT_FILE $images

Write-Host ""
Write-Host "✅ Готово: $OUTPUT_FILE" -ForegroundColor Green

(Get-Item $OUTPUT_FILE).Length / 1MB | Select-Object "{0:N2}" -f '{0} MB' -f $_.Length / 1MB
