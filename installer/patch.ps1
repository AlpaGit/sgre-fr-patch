param(
    [string]$GameDir,
    [switch]$Uninstall,
    [switch]$Prompt
)

$ErrorActionPreference = 'Stop'
$repair = "Dans Steam : Proprietes > Fichiers installes > Verifier l'integrite des fichiers."

function Find-Game($appId) {
    $libraries = foreach ($key in 'HKCU:\SOFTWARE\Valve\Steam', 'HKLM:\SOFTWARE\WOW6432Node\Valve\Steam', 'HKLM:\SOFTWARE\Valve\Steam') {
        $entry = Get-ItemProperty -LiteralPath $key -ErrorAction SilentlyContinue
        foreach ($steam in $entry.SteamPath, $entry.InstallPath) {
            if (-not $steam -or -not (Test-Path -LiteralPath $steam)) { continue }
            $steam
            $vdf = Join-Path $steam 'steamapps/libraryfolders.vdf'
            if (Test-Path -LiteralPath $vdf) {
                foreach ($match in [regex]::Matches((Get-Content -LiteralPath $vdf -Raw), '"path"\s+"([^"]+)"')) {
                    $match.Groups[1].Value.Replace('\\', '\')
                }
            }
        }
    }
    $games = @(foreach ($library in ($libraries | Select-Object -Unique)) {
        $manifest = Join-Path $library "steamapps/appmanifest_$appId.acf"
        $game = Join-Path $library 'steamapps/common/SGRE'
        if ((Test-Path -LiteralPath $manifest -PathType Leaf) -and
            (Test-Path -LiteralPath (Join-Path $game 'sgre_steam.exe') -PathType Leaf)) {
            (Get-Item -LiteralPath $game).FullName
        }
    })
    $games = @($games | Sort-Object -Unique)
    if ($games.Count -eq 1) { return $games[0] }
    if ($games.Count -gt 1) { Write-Host ($games -join [Environment]::NewLine) }
}

function Assert-Ready {
    if (Get-Process -Name sgre_steam -ErrorAction SilentlyContinue) {
        throw 'Fermez STEINS;GATE RE:BOOT avant de continuer.'
    }
    $acf = Get-Content -LiteralPath $manifest -Raw
    foreach ($field in 'appid', 'installdir', 'buildid', 'StateFlags') {
        $pattern = '(?m)^\s*"' + $field + '"\s+"([^"]+)"'
        $values = [regex]::Matches($acf, $pattern)
        if ($values.Count -ne 1 -or $values[0].Groups[1].Value -ne $expected[$field]) {
            throw "Installation Steam incompatible ou en cours de mise a jour (build Windows attendu : $($build.buildId)). $repair"
        }
    }
}

function Get-Hash($path) {
    if (Test-Path -LiteralPath $path -PathType Leaf) {
        $algorithm = [Security.Cryptography.SHA256]::Create()
        try {
            $stream = [IO.File]::OpenRead($path)
            try { return [BitConverter]::ToString($algorithm.ComputeHash($stream)).Replace('-', '') }
            finally { $stream.Dispose() }
        } finally { $algorithm.Dispose() }
    }
}

function Copy-Verified($source, $destination, $sha) {
    [IO.File]::Copy($source, $destination)
    if ((Get-Hash $destination) -ne $sha) { throw "Echec de verification : $destination" }
}

function Invoke-Patch {
    if (-not $GameDir) { $GameDir = Find-Game $build.appId }
    if (-not $GameDir -and $Prompt) {
        Write-Host 'Dans Steam : clic droit sur le jeu > Gerer > Parcourir les fichiers locaux.'
        $GameDir = (Read-Host 'Chemin du dossier SGRE').Trim().Trim('"')
    }
    if (-not $GameDir) { throw 'Dossier SGRE introuvable. Indiquez-le avec -GameDir.' }
    $game = Get-Item -LiteralPath $GameDir
    if ($game.Name -ne 'SGRE' -or $game.Parent.Name -ne 'common' -or
        $game.Parent.Parent.Name -ne 'steamapps' -or
        -not (Test-Path -LiteralPath (Join-Path $game.FullName 'sgre_steam.exe') -PathType Leaf)) {
        throw 'Indiquez le dossier steamapps\common\SGRE de votre installation Steam Windows.'
    }
    $manifest = Join-Path $game.Parent.Parent.FullName "appmanifest_$($build.appId).acf"
    $expected = @{ appid = $build.appId; installdir = $game.Name; buildid = $build.buildId; StateFlags = '4' }
    Assert-Ready

    $data = Join-Path $game.FullName 'wind3d11data'
    if (-not (Test-Path -LiteralPath $data -PathType Container)) { throw "Dossier de donnees introuvable. $repair" }
    $backup = Join-Path $game.FullName ".sgre-fr-backup-$($build.buildId)"
    $bundle = Join-Path (Split-Path -Parent $PSScriptRoot) 'patch'
    $id = [guid]::NewGuid().ToString('N')
    $mutex = [Threading.Mutex]::new($false, "SGRE-FR-$($build.appId)")
    $locked = $false
    $entries = @()
    try {
        try { $locked = $mutex.WaitOne(0) } catch [Threading.AbandonedMutexException] { $locked = $true }
        if (-not $locked) { throw 'Une autre instance du patch est deja ouverte.' }
        Write-Host "Verification de $($game.FullName)..."
        if (-not $Uninstall) {
            foreach ($file in $build.interface) {
                if ((Get-Hash (Join-Path $data $file.path)) -ne $file.steam) {
                    throw "Archive d'interface non officielle ou incompatible : $($file.path). $repair"
                }
            }
        }
        foreach ($file in $build.files) {
            $target = Join-Path $data $file.path
            $original = Join-Path $backup $file.path
            $fr = Join-Path $bundle $file.path
            $current = Get-Hash $target
            if ($current -ne $file.steam -and $current -ne $file.fr) {
                throw "Fichier de jeu absent, modifie ou incompatible : $($file.path). $repair"
            }
            if (-not $Uninstall -and (Get-Hash $fr) -ne $file.fr) {
                throw "Patch incomplet ou corrompu : $($file.path). Extrayez le ZIP complet depuis GitHub Releases."
            }
            $saved = Get-Hash $original
            if (($Uninstall -and $current -eq $file.fr -and $saved -ne $file.steam) -or
                (-not $Uninstall -and $saved -ne $file.steam -and
                ((Test-Path -LiteralPath $original) -or $current -ne $file.steam))) {
                throw "Sauvegarde absente ou invalide : $original. $repair"
            }
            $entry = @{
                Target = $target; Original = $original; Steam = $file.steam; Before = $current
                NeedBackup = (-not $Uninstall -and -not $saved)
                TempBackup = "$original.$id.tmp"; Stage = "$target.$id.tmp"; Undo = "$target.$id.undo"
            }
            if ($Uninstall) { $entry.Source = $original; $entry.After = $file.steam }
            else { $entry.Source = $fr; $entry.After = $file.fr }
            $entries += $entry
        }

        foreach ($entry in $entries) {
            if ($entry.NeedBackup) {
                [void][IO.Directory]::CreateDirectory((Split-Path -Parent $entry.Original))
                Copy-Verified $entry.Target $entry.TempBackup $entry.Steam
                [IO.File]::Move($entry.TempBackup, $entry.Original)
            }
            if ($entry.Before -ne $entry.After) { Copy-Verified $entry.Source $entry.Stage $entry.After }
        }

        Assert-Ready
        foreach ($entry in $entries) {
            if ((Get-Hash $entry.Target) -ne $entry.Before) {
                throw "Le fichier a change pendant la preparation : $($entry.Target). $repair"
            }
        }
        foreach ($entry in $entries) {
            if ($entry.Before -eq $entry.After) { continue }
            [IO.File]::Replace($entry.Stage, $entry.Target, $entry.Undo)
            if ((Get-Hash $entry.Target) -ne $entry.After) {
                throw "Echec de verification apres remplacement : $($entry.Target)"
            }
        }
        if ($Uninstall) { Write-Host "Les fichiers Steam d'origine sont en place." }
        else { Write-Host "Patch FR installe et verifie. Sauvegarde : $backup" }
        foreach ($entry in $entries) { Remove-Item -LiteralPath $entry.Undo -ErrorAction SilentlyContinue }
    } catch {
        $failure = $_
        for ($i = $entries.Count - 1; $i -ge 0; $i--) {
            $entry = $entries[$i]
            if (-not (Test-Path -LiteralPath $entry.Undo -PathType Leaf)) { continue }
            try {
                if ((Get-Hash $entry.Undo) -ne $entry.Before) { throw 'Empreinte de restauration incorrecte.' }
                $rollback = "$($entry.Undo).rollback"
                if (Test-Path -LiteralPath $entry.Target -PathType Leaf) {
                    [IO.File]::Replace($entry.Undo, $entry.Target, $rollback)
                } else { [IO.File]::Move($entry.Undo, $entry.Target) }
                if ((Get-Hash $entry.Target) -ne $entry.Before) { throw 'Empreinte restauree incorrecte.' }
                Remove-Item -LiteralPath $rollback -ErrorAction SilentlyContinue
            } catch { Write-Warning "Restauration impossible pour $($entry.Target) : $_. $repair" }
        }
        throw $failure
    } finally {
        foreach ($entry in $entries) {
            Remove-Item -LiteralPath $entry.Stage, $entry.TempBackup -ErrorAction SilentlyContinue
        }
        if ($locked) { $mutex.ReleaseMutex() }
        $mutex.Dispose()
    }
}

try {
    $build = Get-Content -LiteralPath (Join-Path $PSScriptRoot 'build.json') -Raw | ConvertFrom-Json
    Invoke-Patch
    exit 0
} catch {
    Write-Host $_.Exception.Message -ForegroundColor Red
    exit 1
}
