@echo off
cd /d "%~dp0"
"%~dp0player\RocksmithStreamBridge.exe" --configure-output
if errorlevel 1 pause
