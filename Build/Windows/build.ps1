# Requires: Docker CLI, npm installed and accessible in PATH

Write-Host "Start Build" -ForegroundColor Cyan

# Добавить Docker в PATH если нужно (PowerShell обычно обрабатывает это автоматически)
#$env:Path += ";C:\usr\local\bin" # Пример добавления пути

# Проверить Docker
if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    Write-Host "ERROR: Docker is not installed or not in PATH!" -ForegroundColor Red
    Write-Host "Please install Docker Desktop from https://www.docker.com/products/docker-desktop/"
    exit 1
}

$version = docker --version 2>&1
Write-Host "Docker version: $version"

# !!! ВНИМАНИЕ: Измените этот путь на ваш реальный Windows путь !!!
$DIR = "C:\Users\glebpodavalov\Documents\GitHub\Eye_of_reservoir"

if (-not (Test-Path -Path $DIR -PathType Container)) {
    Write-Host "ERROR: Directory $DIR does not exist!" -ForegroundColor Red
    exit 1
}

Write-Host "Changing to directory: $DIR"
Set-Location $DIR

# Заходим в frontend и устанавливаем зависимости
Set-Location "$DIR\frontend"
npm install

# Возвращаемся в корневую директорию проекта
Set-Location $DIR

Write-Host "Current directory: $(Get-Location)"

# Проверка наличия файлов compose
if (-not (Test-Path -Path "docker-compose.yml") -and -not (Test-Path -Path "compose.yaml")) {
    Write-Host "ERROR: No docker-compose.yml or compose.yaml found!" -ForegroundColor Red
    exit 1
}

Write-Host "Starting Docker Compose..."

# Проверить наличие docker compose
try {
    docker compose version | Out-Null
    docker compose up --build
} catch {
    Write-Host "ERROR: Docker Compose is not available! Make sure the extension is installed." -ForegroundColor Red
    exit 1
}
