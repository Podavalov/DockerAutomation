
Write-Host "Start Build" -ForegroundColor Cyan


if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    Write-Host "ERROR: Docker is not installed or not in PATH!" -ForegroundColor Red
    Write-Host "Please install Docker Desktop from https://www.docker.com/products/docker-desktop/"
    exit 1
}

$version = docker --version 2>&1
Write-Host "Docker version: $version"


$DIR = "Путь к проекту"

if (-not (Test-Path -Path $DIR -PathType Container)) {
    Write-Host "ERROR: Directory $DIR does not exist!" -ForegroundColor Red
    exit 1
}

Write-Host "Changing to directory: $DIR"
Set-Location $DIR


Set-Location "$DIR\frontend"
npm install


Set-Location $DIR

Write-Host "Current directory: $(Get-Location)"

if (-not (Test-Path -Path "docker-compose.yml") -and -not (Test-Path -Path "compose.yaml")) {
    Write-Host "ERROR: No docker-compose.yml or compose.yaml found!" -ForegroundColor Red
    exit 1
}

Write-Host "Starting Docker Compose..."


try {
    docker compose version | Out-Null
    docker compose up --build
} catch {
    Write-Host "ERROR: Docker Compose is not available! Make sure the extension is installed." -ForegroundColor Red
    exit 1
}
