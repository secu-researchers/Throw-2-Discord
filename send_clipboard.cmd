@echo off
powershell.exe -STA -NoProfile -ExecutionPolicy Bypass -File "%~dp0send_clipboard_image.ps1"
if errorlevel 1 (pause) else (timeout /t 2 >nul)