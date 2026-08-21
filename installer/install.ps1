# Installeur du patch FR pour STEINS;GATE RE:BOOT (Steam, app id 4012810).

param(
    [string]$GameDir
)

$ErrorActionPreference = 'Stop'

$ExpectedInfoHash = '23C8402ED65DD5924AFC88D2FE3BB2BCD4CC62EE0AC9C9A11078CFE1C6E3DD71'
$ExpectedBodyHash = '5017935453AFC41C3B1ED314FEEB3C11157EEBC8316D468792375E254476994E'
$ExpectedMovieHashes = [ordered]@{
    'prologue01_en.webm' = '25FD6319AEFF66DC99A5395265D8FBBF46E3FD997F81EBE404204F4D2EEABBAB'
    'prologue02_en.webm' = '1C97525B9F9833B924181AE5C94C92EA37C272A682ECBA2D6310EF049CEFB285'
    'prologue03_en.webm' = 'D87E0941643535883130D44A658FF4CE484C1D1CA3A83BB3F0085A40735F34D9'
}

function Write-Step($n, $total, $msg) {
    Write-Host ""
    Write-Host "[$n/$total] $msg" -ForegroundColor Cyan
}
function Write-Ok($msg) { Write-Host "      $msg" -ForegroundColor Green }
function Write-Warn($msg) { Write-Host "      $msg" -ForegroundColor Yellow }
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
Write-Host "                       Installation" -ForegroundColor Magenta
Write-Host "  ============================================================" -ForegroundColor Magenta
Write-Host ""
Write-Host "  Ce script va reperer le jeu, sauvegarder les archives de" -ForegroundColor Gray
Write-Host "  scenario et les trois videos, puis installer la traduction." -ForegroundColor Gray

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = Split-Path -Parent $scriptDir
$patchDir = Join-Path $repoRoot 'patch'
$frInfo = Join-Path $patchDir 'scenario_info.psb.m'
$frBody = Join-Path $patchDir 'scenario_body.bin'
$frMovieDir = Join-Path $patchDir 'movie'
$frMovies = [ordered]@{}
foreach ($name in $ExpectedMovieHashes.Keys) {
    $frMovies[$name] = Join-Path $frMovieDir $name
}

foreach ($file in @($frInfo, $frBody) + @($frMovies.Values)) {
    if (-not (Test-Path -LiteralPath $file)) {
        Write-Fail "Fichier du patch introuvable : $file"
        Write-Host "  Telechargez et decompressez l'archive complete de la release." -ForegroundColor Red
        Pause-And-Exit 1
    }
}

if ((Get-FileHash -Algorithm SHA256 -LiteralPath $frInfo).Hash -ne $ExpectedInfoHash -or
    (Get-FileHash -Algorithm SHA256 -LiteralPath $frBody).Hash -ne $ExpectedBodyHash) {
    Write-Fail "Les fichiers du patch sont incomplets ou corrompus."
    Write-Host "  Telechargez de nouveau l'archive depuis GitHub Releases." -ForegroundColor Red
    Pause-And-Exit 1
}
foreach ($name in $ExpectedMovieHashes.Keys) {
    if ((Get-FileHash -Algorithm SHA256 -LiteralPath $frMovies[$name]).Hash -ne $ExpectedMovieHashes[$name]) {
        Write-Fail "Video du patch incomplete ou corrompue : $name"
        Pause-And-Exit 1
    }
}

Write-Step 1 4 "Recherche du jeu..."
$gameDir = $GameDir
if (-not $gameDir) { $gameDir = Find-Game }
if (-not $gameDir) {
    Write-Warn "Detection automatique : echec."
    Write-Host "  Indiquez le dossier du jeu manuellement." -ForegroundColor Yellow
    Write-Host "  Exemple : G:\SteamLibrary\steamapps\common\SGRE" -ForegroundColor DarkGray
    $gameDir = (Read-Host "  Chemin").Trim('"').Trim()
}
if (-not (Test-Path -LiteralPath $gameDir)) {
    Write-Fail "Le chemin indique n'existe pas : $gameDir"
    Pause-And-Exit 1
}
Write-Ok "Jeu trouve : $gameDir"

Write-Step 2 4 "Verification de la structure du jeu..."
$dataDir = Join-Path $gameDir 'wind3d11data'
$targetInfo = Join-Path $dataDir 'scenario_info.psb.m'
$targetBody = Join-Path $dataDir 'scenario_body.bin'
$movieDir = Join-Path $dataDir 'movie'
$targetMovies = [ordered]@{}
foreach ($name in $ExpectedMovieHashes.Keys) {
    $targetMovies[$name] = Join-Path $movieDir $name
}
foreach ($file in @($targetInfo, $targetBody) + @($targetMovies.Values)) {
    if (-not (Test-Path -LiteralPath $file)) {
        Write-Fail "Archive originale introuvable : $file"
        Write-Host "  Verifiez qu'il s'agit bien de STEINS;GATE RE:BOOT sur Steam." -ForegroundColor Red
        Pause-And-Exit 1
    }
}
Write-Ok "Structure du jeu valide."

Write-Step 3 4 "Sauvegarde des fichiers originaux..."
$backupInfo = "$targetInfo.bak"
$backupBody = "$targetBody.bak"
$currentInfoHash = (Get-FileHash -Algorithm SHA256 -LiteralPath $targetInfo).Hash
$currentBodyHash = (Get-FileHash -Algorithm SHA256 -LiteralPath $targetBody).Hash

if (($currentInfoHash -eq $ExpectedInfoHash -or $currentBodyHash -eq $ExpectedBodyHash) -and
    (-not (Test-Path -LiteralPath $backupInfo) -or -not (Test-Path -LiteralPath $backupBody))) {
    Write-Fail "Le patch semble deja installe, mais une sauvegarde originale manque."
    Write-Host "  Verifiez d'abord l'integrite des fichiers du jeu dans Steam." -ForegroundColor Red
    Pause-And-Exit 1
}

if (Test-Path -LiteralPath $backupInfo) {
    Write-Ok "Sauvegarde existante conservee : scenario_info.psb.m.bak"
} else {
    Copy-Item -LiteralPath $targetInfo -Destination $backupInfo
    Write-Ok "Sauvegarde creee : scenario_info.psb.m.bak"
}
if (Test-Path -LiteralPath $backupBody) {
    Write-Ok "Sauvegarde existante conservee : scenario_body.bin.bak"
} else {
    Copy-Item -LiteralPath $targetBody -Destination $backupBody
    Write-Ok "Sauvegarde creee : scenario_body.bin.bak"
}
foreach ($name in $ExpectedMovieHashes.Keys) {
    $target = $targetMovies[$name]
    $backup = "$target.frpatch.bak"
    $currentHash = (Get-FileHash -Algorithm SHA256 -LiteralPath $target).Hash
    if ($currentHash -eq $ExpectedMovieHashes[$name] -and -not (Test-Path -LiteralPath $backup)) {
        Write-Fail "La video $name semble deja patchee, mais sa sauvegarde manque."
        Write-Host "  Verifiez d'abord l'integrite des fichiers du jeu dans Steam." -ForegroundColor Red
        Pause-And-Exit 1
    }
    if (Test-Path -LiteralPath $backup) {
        Write-Ok "Sauvegarde existante conservee : $name.frpatch.bak"
    } else {
        Copy-Item -LiteralPath $target -Destination $backup
        Write-Ok "Sauvegarde creee : $name.frpatch.bak"
    }
}

Write-Step 4 4 "Installation de la traduction francaise..."
Copy-Item -LiteralPath $frInfo -Destination $targetInfo -Force
Copy-Item -LiteralPath $frBody -Destination $targetBody -Force
foreach ($name in $ExpectedMovieHashes.Keys) {
    Copy-Item -LiteralPath $frMovies[$name] -Destination $targetMovies[$name] -Force
}

$installedInfoHash = (Get-FileHash -Algorithm SHA256 -LiteralPath $targetInfo).Hash
$installedBodyHash = (Get-FileHash -Algorithm SHA256 -LiteralPath $targetBody).Hash
if ($installedInfoHash -ne $ExpectedInfoHash -or $installedBodyHash -ne $ExpectedBodyHash) {
    Write-Fail "La verification des fichiers installes a echoue."
    Pause-And-Exit 1
}
foreach ($name in $ExpectedMovieHashes.Keys) {
    if ((Get-FileHash -Algorithm SHA256 -LiteralPath $targetMovies[$name]).Hash -ne $ExpectedMovieHashes[$name]) {
        Write-Fail "La verification de la video installee a echoue : $name"
        Pause-And-Exit 1
    }
}
Write-Ok "Les archives et les trois videos ont ete installees et verifiees."

Write-Host ""
Write-Host "  ============================================================" -ForegroundColor Green
Write-Host "                    Installation terminee !" -ForegroundColor Green
Write-Host "  ============================================================" -ForegroundColor Green
Write-Host ""
Write-Host "  Lancez le jeu normalement via Steam." -ForegroundColor White
Write-Host "  Pour revenir a l'anglais, lancez uninstall.bat." -ForegroundColor DarkGray
Pause-And-Exit 0
