@echo off
REM Restaure les archives de scenario, d'interface et les videos originales.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0installer\uninstall.ps1"
