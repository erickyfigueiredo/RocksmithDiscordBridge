$ErrorActionPreference = 'Stop'
$taskPackage = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).Path
$taskFixture = Join-Path $env:TEMP ('rsbridge-install-test-' + [guid]::NewGuid().ToString('N'))
$taskGame = Join-Path $taskFixture 'fake-game'
$taskInstaller = Join-Path $taskFixture 'installer'
New-Item -ItemType Directory -Path $taskGame,(Join-Path $taskInstaller 'player'),(Join-Path $taskInstaller 'bin'),(Join-Path $taskInstaller 'tools') -Force | Out-Null
foreach ($taskName in @('Install.ps1','Restore.ps1')) { Copy-Item -LiteralPath (Join-Path $taskPackage $taskName) -Destination $taskInstaller }
Copy-Item -LiteralPath (Join-Path $taskPackage 'tools\FindGame.ps1') -Destination (Join-Path $taskInstaller 'tools')
$taskIni = "[Config]`r`nEnableAsio=1`r`n[Asio.Output]`r`nDriver=User ASIO Driver`r`nBaseChannel=2`r`n[Asio.Input.0]`r`nDriver=User ASIO Driver`r`nChannel=3`r`n"
$taskAudio = "[Audio]`r`nExclusiveMode=1`r`nLatencyBuffer=4`r`n[Renderer.Win32]`r`nFullscreen=2`r`n"
[IO.File]::WriteAllText((Join-Path $taskGame 'RS_ASIO.ini'),$taskIni)
[IO.File]::WriteAllText((Join-Path $taskGame 'Rocksmith.ini'),$taskAudio)
foreach ($taskName in @('RS_ASIO.dll','avrt.dll','Rocksmith2014.exe')) { [IO.File]::WriteAllText((Join-Path $taskGame $taskName),"ORIGINAL-$taskName") }
[IO.File]::WriteAllText((Join-Path $taskInstaller 'player\RocksmithStreamBridge.exe'),'NON-EXECUTABLE FIXTURE')
[IO.File]::WriteAllText((Join-Path $taskInstaller 'player\settings.json'),'{"output":"Test"}')
$taskOriginalHash = (Get-FileHash -LiteralPath (Join-Path $taskGame 'RS_ASIO.dll')).Hash
# Non-executable PE fixture for file-copy tests, never installed into the actual game.
$taskPe = New-Object byte[] 512
$taskPe[0]=0x4d; $taskPe[1]=0x5a; $taskPe[0x3c]=0x80
$taskPe[0x80]=0x50; $taskPe[0x81]=0x45; $taskPe[0x84]=0x4c; $taskPe[0x85]=0x01
[IO.File]::WriteAllBytes((Join-Path $taskInstaller 'bin\RS_ASIO.dll'),$taskPe)
foreach ($taskExistingMarker in @($false,$true)) {
    $taskBeforeBackups = @(Get-ChildItem -LiteralPath (Join-Path $taskInstaller 'backups') -Directory -ErrorAction SilentlyContinue | ForEach-Object FullName)
    if ($taskExistingMarker) { [IO.File]::WriteAllText((Join-Path $taskGame 'RSBridgePlayer.txt'),'PREVIOUS CONFIG') }
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File (Join-Path $taskInstaller 'Install.ps1') -GameDirectory $taskGame -SkipOutputSelection
    if ($LASTEXITCODE -ne 0) { throw 'Instalação fictícia falhou.' }
    if ((Get-FileHash -LiteralPath (Join-Path $taskGame 'RS_ASIO.dll')).Hash -eq $taskOriginalHash) { throw 'DLL não foi copiada.' }
    if ([IO.File]::ReadAllText((Join-Path $taskGame 'RS_ASIO.ini')) -cne $taskIni) { throw 'Rotas ASIO foram alteradas.' }
    if ([IO.File]::ReadAllText((Join-Path $taskGame 'Rocksmith.ini')) -cne $taskAudio) { throw 'Configurações de áudio/vídeo foram alteradas.' }
    if ([IO.File]::ReadAllText((Join-Path $taskGame 'avrt.dll')) -cne 'ORIGINAL-avrt.dll') { throw 'avrt.dll foi alterado.' }
    $taskMarkerBytes = [IO.File]::ReadAllBytes((Join-Path $taskGame 'RSBridgePlayer.txt'))
    $taskExpectedPath = Join-Path $taskInstaller 'player\RocksmithStreamBridge.exe'
    if ([Text.Encoding]::Unicode.GetString($taskMarkerBytes) -cne $taskExpectedPath) { throw 'Caminho ou encoding do reprodutor incorreto.' }
    $taskBackup = Get-ChildItem -LiteralPath (Join-Path $taskInstaller 'backups') -Directory | Where-Object { $_.FullName -notin $taskBeforeBackups } | Select-Object -First 1
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File (Join-Path $taskInstaller 'Restore.ps1') -BackupDirectory $taskBackup.FullName
    if ($LASTEXITCODE -ne 0) { throw 'Restauração fictícia falhou.' }
    if ((Get-FileHash -LiteralPath (Join-Path $taskGame 'RS_ASIO.dll')).Hash -ne $taskOriginalHash) { throw 'DLL original não foi restaurada.' }
    if ($taskExistingMarker) {
        if ([IO.File]::ReadAllText((Join-Path $taskGame 'RSBridgePlayer.txt')) -cne 'PREVIOUS CONFIG') { throw 'Configuração anterior do reprodutor não restaurada.' }
    } elseif (Test-Path -LiteralPath (Join-Path $taskGame 'RSBridgePlayer.txt')) { throw 'Configuração criada pela ponte não foi removida.' }
}
$taskPe[0x84]=0x64; $taskPe[0x85]=0x86
[IO.File]::WriteAllBytes((Join-Path $taskInstaller 'bin\RS_ASIO.dll'),$taskPe)
$ErrorActionPreference = 'Continue'
& powershell.exe -NoProfile -ExecutionPolicy Bypass -File (Join-Path $taskInstaller 'Install.ps1') -GameDirectory $taskGame -SkipOutputSelection 2>$null | Out-Null
$ErrorActionPreference = 'Stop'
if ($LASTEXITCODE -eq 0) { throw 'DLL x64 deveria ter sido rejeitada.' }
if ((Get-FileHash -LiteralPath (Join-Path $taskGame 'RS_ASIO.dll')).Hash -ne $taskOriginalHash) { throw 'DLL inválida alterou o jogo fictício.' }
Write-Output 'PASS: instalação, encoding UTF-16LE sem BOM, backup/restauração com e sem configuração anterior, preservação de ASIO/vídeo/avrt e rejeição x64.'
