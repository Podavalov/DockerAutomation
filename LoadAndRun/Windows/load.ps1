# Requires: Docker CLI

#$env:Path += ";C:\usr\local\bin;C:\opt\homebrew\bin" # Обновление путей для PowerShell

# !!! ВНИМАНИЕ: Измените этот путь на ваш реальный Windows путь !!!
$PROJECT_DIR = "C:\Users\glebpodavalov\Documents\GitHub\DockerAutomation\LoadAndRun\Linux"
Set-Location $PROJECT_DIR -ErrorAction Stop


Write-Host "📥 Загружаем образы ..." -ForegroundColor Yellow

# Pulling images
docker pull redis:7
docker pull nginx:alpine

# Loading the tarball
docker load -i eye_of_reservoir.tar

Write-Host "✅ Образы загружены." -ForegroundColor Green

# Проверка файлов (PowerShell Test-Path)
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
