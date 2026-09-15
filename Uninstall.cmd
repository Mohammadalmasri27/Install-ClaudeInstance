@echo off
rem Double-click to remove an instance's shortcuts (its data is kept unless you choose otherwise).
set /p NAME=Instance name to remove:
set /p DEL=Also delete its login and data? (y/N):
if /i "%DEL%"=="y" (
  powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0Install-ClaudeInstance.ps1" -Name "%NAME%" -Uninstall -RemoveData
) else (
  powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0Install-ClaudeInstance.ps1" -Name "%NAME%" -Uninstall
)
echo.
pause
