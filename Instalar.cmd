@echo off
cd /d "%~dp0"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0Install.ps1" %*
if errorlevel 1 (
  echo A instalacao nao foi concluida. Confira a mensagem acima.
  echo Se houver acesso negado na pasta do jogo, execute este arquivo como administrador.
  pause
  exit /b 1
)
echo Agora abra o jogo pela Steam e compartilhe Rocksmith 2014 com som no Discord.
pause
