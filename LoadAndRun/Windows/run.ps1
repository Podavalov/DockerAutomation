$PROJECT_DIR = "Путь к \DockerAutomation\LoadAndRun\Windows"
Set-Location $PROJECT_DIR -ErrorAction Stop


Write-Host "🚀 Запускаем контейнеры..." -ForegroundColor Cyan
docker compose up -d

Write-Host "✅ Готово. Статус:" -ForegroundColor Green
docker compose ps
