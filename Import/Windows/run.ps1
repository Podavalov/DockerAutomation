$ErrorActionPreference = 'Stop'

$PROJECT_DIR = $PSScriptRoot
Set-Location $PROJECT_DIR

Write-Host "📂 Project dir: $PROJECT_DIR" -ForegroundColor DarkGray
Write-Host "🚀 Launching containers..." -ForegroundColor Cyan
docker compose up -d

Write-Host "✅ Done. Status:" -ForegroundColor Green
docker compose ps