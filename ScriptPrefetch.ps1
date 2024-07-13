param (
    [string]$DateString
)

if (-not $DateString -or -not [DateTime]::TryParseExact($DateString, 'MM-dd-yyyy', $null, 'None', [ref]$null)) {
    Write-Error "Invalid date format. Please enter the date in MM-dd-yyyy format."
    exit
}

$date = [DateTime]::ParseExact($DateString, 'MM-dd-yyyy', $null)

$prefetchPath = "C:\Windows\Prefetch"
$outputPath = "C:\SSPrefetch"

if (!(Test-Path -Path $outputPath -PathType Container)) {
    New-Item -ItemType Directory -Path $outputPath | Out-Null
} else {
    # Limpiar el directorio de salida si ya existe
    Remove-Item -Path "$outputPath\*" -Force
}

$pfFiles = Get-ChildItem -Path $prefetchPath -Filter "*.pf" | Where-Object { $_.LastWriteTime.Date -eq $date }
foreach ($pfFile in $pfFiles) {
    $outputFile = Join-Path -Path $outputPath -ChildPath $pfFile.Name
    Copy-Item -Path $pfFile.FullName -Destination $outputFile -Force
}

$url = "https://www.nirsoft.net/utils/winprefetchview-x64.zip"
$zipFile = Join-Path -Path $outputPath -ChildPath "winprefetchview-x64.zip"
$exePath = Join-Path -Path $outputPath -ChildPath "WinPrefetchView.exe"

Invoke-WebRequest -Uri $url -OutFile $zipFile

Add-Type -AssemblyName System.IO.Compression.FileSystem
[System.IO.Compression.ZipFile]::ExtractToDirectory($zipFile, $outputPath)

Remove-Item -Path $zipFile

$arguments = "/folder `"$outputPath`""
Start-Process -FilePath $exePath -ArgumentList $arguments -Verb RunAs
