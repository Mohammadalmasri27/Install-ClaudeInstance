@echo off
rem Double-click to remove instances' shortcuts (their data is kept unless you choose otherwise).
echo Existing instances:
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0Install-ClaudeInstance.ps1" -List
echo.
set /p NAME=Instance name(s) to remove, comma-separated:
set /p DEL=Also delete their login and data? (y/N):
if /i "%DEL%"=="y" (
  powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0Install-ClaudeInstance.ps1" -Name "%NAME%" -Uninstall -RemoveData
) else (
  powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0Install-ClaudeInstance.ps1" -Name "%NAME%" -Uninstall
)
echo.
pause
