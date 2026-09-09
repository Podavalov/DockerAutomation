$PROJECT_DIR = "Path to \DockerAutomation\LoadAndRun\Windows"
Set-Location $PROJECT_DIR -ErrorAction Stop


Write-Host "🚀 Launching containers..." -ForegroundColor Cyan
docker compose up -d

Write-Host "✅ Done. Status:" -ForegroundColor Green
docker compose ps
