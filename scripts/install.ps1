#Requires -Version 5.1

#
#   @NicRiv
#

[CmdletBinding()]
param(
    [string]$Version = "",
    [switch]$System
)

$ErrorActionPreference = "Stop"

$Repo    = "NicRiv/hoy"
$BinName = "hoy"

$arch = if ([Environment]::Is64BitOperatingSystem) { "amd64" } else { "x86" }

if (-not $Version) {
    Write-Host "Consultando última versión..."
    $rel     = Invoke-RestMethod "https://api.github.com/repos/$Repo/releases/latest"
    $Version = $rel.tag_name
}

$url = "https://github.com/$Repo/releases/download/$Version/$BinName-windows-$arch.exe"

if ($System) {
    $dest      = Join-Path $env:ProgramFiles $BinName
    $pathScope = "Machine"
    $isAdmin   = ([Security.Principal.WindowsPrincipal] `
                  [Security.Principal.WindowsIdentity]::GetCurrent()
                 ).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    if (-not $isAdmin) {
        Write-Error "-System requiere PowerShell como Administrador."
    }
} else {
    $dest      = Join-Path $env:LOCALAPPDATA "Programs\$BinName"
    $pathScope = "User"
}

New-Item -ItemType Directory -Force $dest | Out-Null
$exe = Join-Path $dest "$BinName.exe"

Write-Host "Descargando $BinName $Version ($arch)..."
Invoke-WebRequest -Uri $url -OutFile $exe

$currentPath = [Environment]::GetEnvironmentVariable("Path", $pathScope)
if ($currentPath -notlike "*$dest*") {
    [Environment]::SetEnvironmentVariable(
        "Path", "$currentPath;$dest", $pathScope)
    Write-Host "PATH ($pathScope) actualizado. Abrí una terminal nueva."
}

Write-Host "    Instalado en $exe"
Write-Host "    Probá con:  $BinName"