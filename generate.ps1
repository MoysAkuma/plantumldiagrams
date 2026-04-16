# PlantUML Image Generator
# Finds all .puml files recursively and generates PNG images under the Generated/ folder,
# preserving the original folder structure.

param(
    [string]$PlantUmlJar = (Join-Path $PSScriptRoot "plantuml.jar"),
    [string]$OutputRoot  = (Join-Path $PSScriptRoot "Generated"),
    [ValidateSet("png","svg","eps","pdf")]
    [string]$Format = "png"
)

# Verify Java is available
if (-not (Get-Command java -ErrorAction SilentlyContinue)) {
    Write-Error "Java is not installed or not in PATH. Please install Java to use PlantUML."
    exit 1
}

# Verify plantuml.jar exists
if (-not (Test-Path $PlantUmlJar)) {
    Write-Error "plantuml.jar not found at: $PlantUmlJar`nDownload it from https://plantuml.com/download and place it in the repository root."
    exit 1
}

# Find all .puml files, excluding anything already under Generated/
$pumlFiles = Get-ChildItem -Path $PSScriptRoot -Recurse -Filter "*.puml" |
    Where-Object { $_.FullName -notlike "*$([IO.Path]::DirectorySeparatorChar)Generated$([IO.Path]::DirectorySeparatorChar)*" }

if ($pumlFiles.Count -eq 0) {
    Write-Host "No .puml files found."
    exit 0
}

$successCount = 0
$failCount    = 0

foreach ($file in $pumlFiles) {
    # Compute the relative directory from the repo root
    $relativeDir = $file.DirectoryName.Substring($PSScriptRoot.Length).TrimStart([IO.Path]::DirectorySeparatorChar)
    $outputDir   = if ($relativeDir) { Join-Path $OutputRoot $relativeDir } else { $OutputRoot }

    if (-not (Test-Path $outputDir)) {
        New-Item -ItemType Directory -Path $outputDir -Force | Out-Null
    }

    Write-Host "Generating [$Format] for: $relativeDir\$($file.Name) ..."

    $result = & java -jar $PlantUmlJar "-t$Format" -o $outputDir $file.FullName 2>&1
    if ($LASTEXITCODE -eq 0) {
        $successCount++
    } else {
        Write-Warning "Failed to generate image for $($file.FullName):`n$result"
        $failCount++
    }
}

Write-Host ""
Write-Host "Done. Success: $successCount | Failed: $failCount"
Write-Host "Images saved to: $OutputRoot"
