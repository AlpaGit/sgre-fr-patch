# Desinstalle le patch FR de STEINS;GATE RE:BOOT et restaure les sauvegardes.

param(
    [string]$GameDir
)

$ErrorActionPreference = 'Stop'

function Write-Step($n, $total, $msg) {
    Write-Host ""
    Write-Host "[$n/$total] $msg" -ForegroundColor Cyan
}
function Write-Ok($msg) { Write-Host "      $msg" -ForegroundColor Green }
function Write-Fail($msg) { Write-Host "      $msg" -ForegroundColor Red }

function Read-SteamPath {
    foreach ($key in 'HKLM:\SOFTWARE\WOW6432Node\Valve\Steam', 'HKLM:\SOFTWARE\Valve\Steam', 'HKCU:\SOFTWARE\Valve\Steam') {
        try {
            $value = (Get-ItemProperty -Path $key -ErrorAction Stop).InstallPath
            if ($value -and (Test-Path -LiteralPath $value)) { return $value }
        } catch { }
    }
    return $null
}

function Get-SteamLibraries($steamPath) {
    $libraries = @($steamPath)
    $vdf = Join-Path $steamPath 'steamapps\libraryfolders.vdf'
    if (-not (Test-Path -LiteralPath $vdf)) { return $libraries }
    $content = Get-Content -LiteralPath $vdf -Raw
    foreach ($match in [regex]::Matches($content, '"path"\s+"([^"]+)"')) {
        $path = $match.Groups[1].Value -replace '\\\\', '\'
        if (Test-Path -LiteralPath $path) { $libraries += $path }
    }
    return $libraries | Select-Object -Unique
}

function Find-Game {
    $steam = Read-SteamPath
    if (-not $steam) { return $null }
    foreach ($library in (Get-SteamLibraries $steam)) {
        $candidate = Join-Path $library 'steamapps\common\SGRE'
        if (Test-Path -LiteralPath (Join-Path $candidate 'wind3d11data')) { return $candidate }
    }
    return $null
}

function Pause-And-Exit($code) {
    Write-Host ""
    Read-Host "  Appuyez sur Entree pour fermer"
    exit $code
}

try { Clear-Host } catch { }
Write-Host ""
Write-Host "  ============================================================" -ForegroundColor Magenta
Write-Host "             Patch FR - STEINS;GATE RE:BOOT" -ForegroundColor Magenta
Write-Host "                     Desinstallation" -ForegroundColor Magenta
Write-Host "  ============================================================" -ForegroundColor Magenta

Write-Step 1 2 "Recherche du jeu..."
$gameDir = $GameDir
if (-not $gameDir) { $gameDir = Find-Game }
if (-not $gameDir) {
    $gameDir = (Read-Host "  Chemin du jeu (ex: G:\SteamLibrary\steamapps\common\SGRE)").Trim('"').Trim()
}
if (-not (Test-Path -LiteralPath $gameDir)) {
    Write-Fail "Chemin invalide."
    Pause-And-Exit 1
}
Write-Ok "Jeu trouve : $gameDir"

Write-Step 2 2 "Restauration des archives originales..."
$dataDir = Join-Path $gameDir 'wind3d11data'
$targetInfo = Join-Path $dataDir 'scenario_info.psb.m'
$targetBody = Join-Path $dataDir 'scenario_body.bin'
$backupInfo = "$targetInfo.bak"
$backupBody = "$targetBody.bak"

$missing = @()
if (-not (Test-Path -LiteralPath $backupInfo)) { $missing += 'scenario_info.psb.m.bak' }
if (-not (Test-Path -LiteralPath $backupBody)) { $missing += 'scenario_body.bin.bak' }
if ($missing.Count -gt 0) {
    Write-Fail ("Sauvegarde(s) manquante(s) : " + ($missing -join ', '))
    Write-Host "  Utilisez Steam > Proprietes > Fichiers installes > Verifier l'integrite." -ForegroundColor Yellow
    Pause-And-Exit 1
}

Copy-Item -LiteralPath $backupInfo -Destination $targetInfo -Force
Copy-Item -LiteralPath $backupBody -Destination $targetBody -Force
Write-Ok "Les deux archives originales ont ete restaurees."

Write-Host ""
Write-Host "  ============================================================" -ForegroundColor Green
Write-Host "                  Patch FR desinstalle." -ForegroundColor Green
Write-Host "  ============================================================" -ForegroundColor Green
Pause-And-Exit 0
