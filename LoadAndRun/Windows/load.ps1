
$PROJECT_DIR = "Путь к \DockerAutomation\LoadAndRun\Windows"
Set-Location $PROJECT_DIR -ErrorAction Stop


Write-Host "📥 Загружаем образы ..." -ForegroundColor Yellow


docker pull redis:7
docker pull nginx:alpine


docker load -i eye_of_reservoir.tar

Write-Host "✅ Образы загружены." -ForegroundColor Green


if (-not (Test-Path -Path ".env")) {
    Write-Host "⚠️  .env не найден, создайте его." -ForegroundColor Yellow
    exit 1
}

if (-not (Test-Path -Path "infra\nginx\nginx.conf")) {
    Write-Host "⚠️  nginx.conf не найден." -ForegroundColor Yellow
    exit 1
}

Write-Host "🚀 Запускаем контейнеры..." -ForegroundColor Cyan
docker compose up -d

Write-Host "✅ Готово. Статус:" -ForegroundColor Green
docker compose ps
