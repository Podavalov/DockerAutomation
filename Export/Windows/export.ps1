
$PROJECT_DIR = "project"
Set-Location $PROJECT_DIR -ErrorAction Stop


$OUTPUT_FILE = "path to DockerAutomation\LoadAndRun\Windows\eye_of_reservoir.tar"

Write-Host "Get all images from docker compose images..."


$images = docker compose images | Select-Object -Skip 1 | Where-Object { $_ -notmatch '<none>' } | ForEach-Object {

    $repo = $_[0]
    $tag = $_[1]
    "$repo:$tag"
} | Select-Object -Unique

if (-not $images) {
    Write-Host "❌ No images with tags. Build them first: docker compose build" -ForegroundColor Red
    exit 1
}

Write-Host "📦 Saving images into a single archive:"
$images | Write-Host


docker save -o $OUTPUT_FILE $images

Write-Host ""
Write-Host "✅ Done: $OUTPUT_FILE" -ForegroundColor Green

(Get-Item $OUTPUT_FILE).Length / 1MB | Select-Object "{0:N2}" -f '{0} MB' -f $_.Length / 1MB
