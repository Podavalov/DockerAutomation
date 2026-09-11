$ErrorActionPreference = 'Stop'

Write-Host "Start Build" -ForegroundColor Cyan

# --- 1. Запрос пути к проекту ---
$defaultDir = $PSScriptRoot   # по умолчанию — папка, где лежит сам скрипт

while ($true) {
    Write-Host ""
    Write-Host "Enter the path to the project directory." -ForegroundColor Yellow
    Write-Host "Press Enter to use the default: $defaultDir" -ForegroundColor DarkGray
    $input = Read-Host "Path"

    if ([string]::IsNullOrWhiteSpace($input)) {
        $DIR = $defaultDir
    } else {
        # убираем возможные обрамляющие кавычки
        $DIR = $input.Trim('"').Trim("'")
    }

    # нормализуем путь
    try {
        $DIR = (Resolve-Path -Path $DIR -ErrorAction Stop).Path
    } catch {
        Write-Host "ERROR: Path '$DIR' does not exist or is not accessible." -ForegroundColor Red
        continue
    }

    if (-not (Test-Path -Path $DIR -PathType Container)) {
        Write-Host "ERROR: '$DIR' is not a directory." -ForegroundColor Red
        continue
    }

    break
}

Write-Host "Using project directory: $DIR" -ForegroundColor Green

# --- 2. Проверка Docker ---
if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    Write-Host "ERROR: Docker is not installed or not in PATH!" -ForegroundColor Red
    Write-Host "Please install Docker Desktop from https://www.docker.com/products/docker-desktop/"
    exit 1
}

$version = docker --version 2>&1
Write-Host "Docker version: $version"

# --- 3. Переход в проект ---
Write-Host "Changing to directory: $DIR"
Set-Location $DIR

# --- 4. npm install во frontend ---
$frontend = Join-Path $DIR 'frontend'
if (-not (Test-Path -Path $frontend -PathType Container)) {
    Write-Host "ERROR: '$frontend' not found!" -ForegroundColor Red
    exit 1
}

Write-Host "Running 'npm install' in $frontend ..." -ForegroundColor Cyan
Push-Location $frontend
try {
    npm install
    if ($LASTEXITCODE -ne 0) {
        Write-Host "ERROR: npm install failed (exit code $LASTEXITCODE)." -ForegroundColor Red
        exit 1
    }
} finally {
    Pop-Location
}

Set-Location $DIR
Write-Host "Current directory: $(Get-Location)"

# --- 5. Проверка compose-файла ---
if (-not (Test-Path -Path "docker-compose.yml") -and -not (Test-Path -Path "compose.yaml")) {
    Write-Host "ERROR: No docker-compose.yml or compose.yaml found!" -ForegroundColor Red
    exit 1
}

Write-Host "Starting Docker Compose..."

# --- 6. Проверка доступности docker compose ---
try {
    docker compose version | Out-Null
} catch {
    Write-Host "ERROR: Docker Compose is not available! Make sure the extension is installed." -ForegroundColor Red
    exit 1
}
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: 'docker compose version' failed. Is the Compose plugin installed?" -ForegroundColor Red
    exit 1
}

docker compose up --build
exit $LASTEXITCODE