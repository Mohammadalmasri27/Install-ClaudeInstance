@echo off
rem Double-click to create a new isolated Claude Desktop instance.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0Install-ClaudeInstance.ps1"
echo.
pause
