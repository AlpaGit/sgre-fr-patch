@echo off
REM Restaure les archives de scenario originales.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0installer\uninstall.ps1"
