$ErrorActionPreference = 'Stop'

# Папка, где лежит сам скрипт
$PROJECT_DIR = $PSScriptRoot
Set-Location $PROJECT_DIR

Write-Host "📂 Project dir: $PROJECT_DIR" -ForegroundColor DarkGray

# --- Ищем .tar в папке скрипта ---
$tarFiles = Get-ChildItem -Path $PROJECT_DIR -Filter '*.tar' -File

if (-not $tarFiles -or $tarFiles.Count -eq 0) {
    Write-Host "❌ No .tar files found in $PROJECT_DIR" -ForegroundColor Red
    exit 1
}

$tarFile = $tarFiles[0].FullName
if ($tarFiles.Count -gt 1) {
    Write-Host "⚠️  Multiple .tar files found, using the first one:" -ForegroundColor Yellow
    $tarFiles | ForEach-Object { Write-Host "   - $($_.Name)" -ForegroundColor DarkGray }
} 
Write-Host "📦 Using archive: $($tarFiles[0].Name)" -ForegroundColor Cyan

Write-Host "📥 Loading images..." -ForegroundColor Yellow

docker pull redis:7
docker pull nginx:alpine

docker load -i $tarFile
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ 'docker load' failed with exit code $LASTEXITCODE" -ForegroundColor Red
    exit $LASTEXITCODE
}

Write-Host "✅ Images uploaded." -ForegroundColor Green

if (-not (Test-Path -Path ".env")) {
    Write-Host "⚠️  .env not found; please create it." -ForegroundColor Yellow
    exit 1
}

if (-not (Test-Path -Path "infra\nginx\nginx.conf")) {
    Write-Host "⚠️  nginx.conf not found." -ForegroundColor Yellow
    exit 1
}

Write-Host "🚀 Launching containers..." -ForegroundColor Cyan
docker compose up -d
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ 'docker compose up' failed with exit code $LASTEXITCODE" -ForegroundColor Red
    exit $LASTEXITCODE
}

Write-Host "✅ Done. Status:" -ForegroundColor Green
docker compose ps