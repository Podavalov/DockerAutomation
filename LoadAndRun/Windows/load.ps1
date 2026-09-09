
$PROJECT_DIR = "Path to \DockerAutomation\LoadAndRun\Windows"
Set-Location $PROJECT_DIR -ErrorAction Stop


Write-Host "📥 Loading images..." -ForegroundColor Yellow


docker pull redis:7
docker pull nginx:alpine


docker load -i eye_of_reservoir.tar

Write-Host "✅ Images uploaded." -ForegroundColor Green


if (-not (Test-Path -Path ".env")) {
    Write-Host "⚠️  .env not found; please create it." -ForegroundColor Yellow
    exit 1
}

if (-not (Test-Path -Path "infra\nginx\nginx.conf")) {
    Write-Host "⚠️ nginx.conf not found." -ForegroundColor Yellow
    exit 1
}

Write-Host "🚀 Launching containers..." -ForegroundColor Cyan
docker compose up -d

Write-Host "✅ Done. Status:" -ForegroundColor Green
docker compose ps
