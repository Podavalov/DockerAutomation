$ErrorActionPreference = 'Stop'

Write-Host "Start Export" -ForegroundColor Cyan

# --- 1. Запрос пути к проекту (где лежит docker-compose.yml) ---
while ($true) {
    Write-Host ""
    Write-Host "Enter the path to the project directory (where docker-compose.yml is)." -ForegroundColor Yellow
    $userInput = Read-Host "Project path"

    if ([string]::IsNullOrWhiteSpace($userInput)) {
        Write-Host "ERROR: project path cannot be empty." -ForegroundColor Red
        continue
    }

    # убираем кавычки и конечные слэши, чтобы корректно вытащить имя папки
    $cleanInput = $userInput.Trim().Trim('"').Trim("'").TrimEnd('\', '/')

    try {
        $PROJECT_DIR = (Resolve-Path -Path $cleanInput -ErrorAction Stop).Path
    } catch {
        Write-Host "ERROR: Path '$cleanInput' does not exist or is not accessible." -ForegroundColor Red
        continue
    }

    if (-not (Test-Path -Path $PROJECT_DIR -PathType Container)) {
        Write-Host "ERROR: '$PROJECT_DIR' is not a directory." -ForegroundColor Red
        continue
    }

    break
}

Set-Location $PROJECT_DIR
Write-Host "Using project directory: $PROJECT_DIR" -ForegroundColor Green

# --- 2. Имя архива = имя папки, которую ввёл пользователь ---
$projectName = [System.IO.Path]::GetFileName($cleanInput)
if ([string]::IsNullOrWhiteSpace($projectName)) {
    # на случай, если ввели что-то вроде "C:\" — падаем на leaf от Resolve-Path
    $projectName = Split-Path -Path $PROJECT_DIR -Leaf
}

$defaultOut = Join-Path $PSScriptRoot "$projectName.tar"

Write-Host ""
Write-Host "Enter the output .tar file path." -ForegroundColor Yellow
Write-Host "Press Enter to use the default: $defaultOut" -ForegroundColor DarkGray
$outInput = Read-Host "Output file"

if ([string]::IsNullOrWhiteSpace($outInput)) {
    $OUTPUT_FILE = $defaultOut
} else {
    $OUTPUT_FILE = $outInput.Trim('"').Trim("'")
    if (-not [System.IO.Path]::IsPathRooted($OUTPUT_FILE)) {
        $OUTPUT_FILE = Join-Path $PSScriptRoot $OUTPUT_FILE
    }
}

$outDir = Split-Path -Parent $OUTPUT_FILE
if (-not (Test-Path -Path $outDir -PathType Container)) {
    Write-Host "ERROR: Output directory '$outDir' does not exist." -ForegroundColor Red
    exit 1
}

Write-Host "Output file: $OUTPUT_FILE" -ForegroundColor Green

# --- 3. Собираем список образов ---
Write-Host ""
Write-Host "Get all images from docker compose images..."

$images = docker compose images |
    Select-Object -Skip 1 |
    Where-Object { $_ -notmatch '<none>' } |
    ForEach-Object {
        $parts = ($_ -replace '\s{2,}', '|') -split '\|'
        if ($parts.Count -ge 3) {
            $repo = $parts[1].Trim()
            $tag  = $parts[2].Trim()
            if ($repo -and $tag -and $repo -ne '<none>') {
                "$repo`:$tag"
            }
        }
    } | Select-Object -Unique

if (-not $images) {
    Write-Host "❌ No images with tags. Build them first: docker compose build" -ForegroundColor Red
    exit 1
}

Write-Host "📦 Saving images into a single archive:"
$images | ForEach-Object { Write-Host "   $_" }

# --- 4. Сохраняем ---
if (Test-Path -Path $OUTPUT_FILE) {
    Write-Host "Removing existing file: $OUTPUT_FILE" -ForegroundColor DarkGray
    Remove-Item -Path $OUTPUT_FILE -Force
}

docker save -o $OUTPUT_FILE @images
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: 'docker save' failed with exit code $LASTEXITCODE." -ForegroundColor Red
    exit $LASTEXITCODE
}

# --- 5. Итог ---
$sizeMB = (Get-Item $OUTPUT_FILE).Length / 1MB
Write-Host ""
Write-Host "✅ Done: $OUTPUT_FILE" -ForegroundColor Green
Write-Host ("Archive size: {0:N2} MB" -f $sizeMB) -ForegroundColor Green