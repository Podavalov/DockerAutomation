# Requires: Docker CLI

#$env:Path += ";C:\usr\local\bin;C:\opt\homebrew\bin" # Обновление путей для PowerShell

# !!! ВНИМАНИЕ: Измените этот путь на ваш реальный Windows путь !!!
$PROJECT_DIR = "C:\Users\glebpodavalov\Documents\GitHub\DockerAutomation\LoadAndRun\Linux"
Set-Location $PROJECT_DIR -ErrorAction Stop


Write-Host "🚀 Запускаем контейнеры..." -ForegroundColor Cyan
docker compose up -d

Write-Host "✅ Готово. Статус:" -ForegroundColor Green
docker compose ps
