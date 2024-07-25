# By semental & espouken

function Get-OldestConnectTime {
    $users = Get-WmiObject -Class Win32_NetworkLoginProfile | Where-Object { $_.LastLogon -ne $null }
    $oldestDate = $null

    foreach ($user in $users) {
        # Convert LastLogon to DateTime
        $connectTime = [System.Management.ManagementDateTimeConverter]::ToDateTime($user.LastLogon)

        if ($connectTime) {
            # Debugging: Print user and connect time
            Write-Host "Checking user: $($user.Name) with logon time: $connectTime"

            if (-not $oldestDate -or $connectTime -lt $oldestDate) {
                # Debugging: Indicate when the oldest date is updated
                Write-Host "Updating oldest date to: $connectTime"
                $oldestDate = $connectTime
            }
        }
    }

    # Output and return the oldest date
    if ($oldestDate) {
        Write-Host "Oldest logon time found: $oldestDate"
    } else {
        Write-Host "No logon times found."
    }
    
    return $oldestDate
}

# Call the function
Get-OldestConnectTime


Write-Host "
 ██╗    ██╗██╗███╗   ██╗██████╗ ██████╗ ███████╗███████╗███████╗████████╗ ██████╗██╗  ██╗
 ██║    ██║██║████╗  ██║██╔══██╗██╔══██╗██╔════╝██╔════╝██╔════╝╚══██╔══╝██╔════╝██║  ██║
 ██║ █╗ ██║██║██╔██╗ ██║██████╔╝██████╔╝█████╗  █████╗  █████╗     ██║   ██║     ███████║
 ██║███╗██║██║██║╚██╗██║██╔═══╝ ██╔══██╗██╔══╝  ██╔══╝  ██╔══╝     ██║   ██║     ██╔══██║
 ╚███╔███╔╝██║██║ ╚████║██║     ██║  ██║███████╗██║     ███████╗   ██║   ╚██████╗██║  ██║
  ╚══╝╚══╝ ╚═╝╚═╝  ╚═══╝╚═╝     ╚═╝  ╚═╝╚══════╝╚═╝     ╚══════╝   ╚═╝    ╚═════╝╚═╝  ╚═╝
                                                                                        
" -ForegroundColor Magenta


Write-Host "                              DISCORD.GG/ASTRALMC  -  MADE BY SEMENTAL & ESPOUKEN" -ForegroundColor DarkGray

Start-Sleep -Seconds 2
# conseguir el oldest entry
$date = Get-OldestConnectTime

if (-not $date) {
    Write-Error "No valid connect time found for any user."
    exit
}

$prefetchPath = "C:\Windows\Prefetch"
$tempPath = [System.IO.Path]::Combine($env:TEMP, "ScriptPrefetch")

if (!(Test-Path -Path $tempPath -PathType Container)) {
    New-Item -ItemType Directory -Path $tempPath | Out-Null
} else {
    # Limpiar el directorio de salida si ya existe
    Remove-Item -Path "$tempPath\*" -Force
}

# todos los PF con la fecha de instancia o depsues
$pfFiles = Get-ChildItem -Path $prefetchPath -Filter "*.pf" | Where-Object {$_.LastWriteTime -ge $date}
foreach ($pfFile in $pfFiles) {
    $outputFile = Join-Path -Path $tempPath -ChildPath $pfFile.Name
    Copy-Item -Path $pfFile.FullName -Destination $outputFile -Force
}

$url = "https://www.nirsoft.net/utils/winprefetchview-x64.zip"
$zipFile = Join-Path -Path $tempPath -ChildPath "winprefetchview-x64.zip"
$exePath = Join-Path -Path $tempPath -ChildPath "WinPrefetchView.exe"

Invoke-WebRequest -Uri $url -OutFile $zipFile

Add-Type -AssemblyName System.IO.Compression.FileSystem
[System.IO.Compression.ZipFile]::ExtractToDirectory($zipFile, $tempPath)

Remove-Item -Path $zipFile

$arguments = "/folder `"$tempPath`""
Start-Process -FilePath $exePath -ArgumentList $arguments -Verb RunAs -Wait

# Cleanup borrar luego de terminado de ejecutar
Remove-Item -Path $tempPath -Recurse -Force
