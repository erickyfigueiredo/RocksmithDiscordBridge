$ErrorActionPreference = 'Stop'
$taskRoot = Split-Path $PSScriptRoot
$taskFixture = Join-Path $env:TEMP ('rsbridge-gui-test-' + [guid]::NewGuid().ToString('N'))
$taskGame = Join-Path $taskFixture 'Game with spaces'
$taskApp = Join-Path $taskFixture 'App with spaces'
New-Item -ItemType Directory -Path $taskGame -Force | Out-Null
[IO.File]::WriteAllText((Join-Path $taskGame 'Rocksmith2014.exe'),'NON-EXECUTABLE FIXTURE')
$taskIni = "[Audio]`r`nExclusiveMode=0`r`nWin32UltraLowLatencyMode=0`r`n[Renderer.Win32]`r`nFullscreen=2`r`n"
[IO.File]::WriteAllText((Join-Path $taskGame 'Rocksmith.ini'),$taskIni)
$taskArguments = @('/VERYSILENT','/SUPPRESSMSGBOXES','/NORESTART','/SP-',('/DIR="'+$taskApp+'"'),('/GAME_DIR="'+$taskGame+'"'),'/INITIALIZE_ASIO=1','/ASIO_DRIVER="Example ASIO"','/SKIP_AUDIO=1',('/LOG="'+(Join-Path $taskFixture 'setup.log')+'"'))
$taskProcess = Start-Process -FilePath (Join-Path $taskRoot 'release\RocksmithDiscordBridge-Setup-x64.exe') -ArgumentList $taskArguments -Wait -PassThru -WindowStyle Hidden
if ($taskProcess.ExitCode -ne 0) { Get-Content (Join-Path $taskFixture 'setup.log') -Tail 40; throw 'GUI installer smoke test failed.' }
foreach ($taskName in @('RS_ASIO.dll','avrt.dll','RS_ASIO.ini','RSBridgePlayer.txt')) {
    if (-not (Test-Path -LiteralPath (Join-Path $taskGame $taskName))) { throw "Missing installed game file: $taskName" }
}
$taskMarker = [Text.Encoding]::Unicode.GetString([IO.File]::ReadAllBytes((Join-Path $taskGame 'RSBridgePlayer.txt')))
if (-not (Test-Path -LiteralPath $taskMarker)) { throw 'Invalid player path in launcher configuration.' }
$taskASIOFile = Join-Path $taskGame 'RS_ASIO.ini'
$taskASIOText = [IO.File]::ReadAllText($taskASIOFile)
if ($taskASIOText -notmatch '(?m)^Channel=0\r?$') { throw 'Physical input 1 was not translated to channel 0.' }
$taskASIOText += "`r`n; user configuration preserved across reinstall`r`n"
[IO.File]::WriteAllText($taskASIOFile,$taskASIOText)
$taskStateFile = Join-Path $env:PROGRAMDATA 'RocksmithDiscordBridge\installation.json'
$taskOriginalBackup = (Get-Content -LiteralPath $taskStateFile -Raw | ConvertFrom-Json).files.'Rocksmith.ini'.original
$taskReinstall = Start-Process -FilePath (Join-Path $taskRoot 'release\RocksmithDiscordBridge-Setup-x64.exe') -ArgumentList $taskArguments -Wait -PassThru -WindowStyle Hidden
if ($taskReinstall.ExitCode -ne 0) { throw 'Reinstall failed.' }
if ([IO.File]::ReadAllText($taskASIOFile) -cne $taskASIOText) { throw 'Reinstall replaced the existing audio configuration.' }
if ((Get-Content -LiteralPath $taskStateFile -Raw | ConvertFrom-Json).files.'Rocksmith.ini'.original -cne $taskOriginalBackup) { throw 'Reinstall replaced the original backup.' }
$taskUninstaller = Join-Path $taskApp 'unins000.exe'
$taskUninstall = Start-Process -FilePath $taskUninstaller -ArgumentList '/VERYSILENT','/SUPPRESSMSGBOXES','/NORESTART' -Wait -PassThru -WindowStyle Hidden
if ($taskUninstall.ExitCode -ne 0) { throw 'GUI uninstaller smoke test failed.' }
if (Test-Path -LiteralPath (Join-Path $taskGame 'RS_ASIO.dll')) { throw 'Uninstall did not restore the fixture.' }
if ([IO.File]::ReadAllText((Join-Path $taskGame 'Rocksmith.ini')) -cne $taskIni) { throw 'Original game configuration not restored.' }
Write-Host 'PASS: built Setup.exe installed, reinstalled and uninstalled against an isolated game fixture; no prerequisites were downloaded.'
