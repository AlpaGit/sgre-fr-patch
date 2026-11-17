param([string]$GameDir, [switch]$Prompt)

& (Join-Path $PSScriptRoot 'patch.ps1') -GameDir $GameDir -Prompt:$Prompt
exit $LASTEXITCODE
