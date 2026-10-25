param([Parameter(Mandatory=$true)][string]$BackupDirectory)
$ErrorActionPreference = 'Stop'
$taskBackup = (Resolve-Path -LiteralPath $BackupDirectory).Path
$taskInfo = Get-Content -Raw -LiteralPath (Join-Path $taskBackup 'installation.json') | ConvertFrom-Json
if ($taskInfo.version -ne 1) { throw 'Formato de backup desconhecido.' }
$taskGame = (Resolve-Path -LiteralPath $taskInfo.game).Path
if (Get-Process -Name Rocksmith2014 -ErrorAction SilentlyContinue | Where-Object { $_.Path -and (Split-Path $_.Path) -ieq $taskGame }) { throw 'Feche o Rocksmith antes de restaurar.' }
foreach ($taskName in @('RS_ASIO.dll','RS_ASIO.ini','Rocksmith.ini')) {
    if (-not (Test-Path -LiteralPath (Join-Path $taskBackup $taskName))) { throw "Backup incompleto: $taskName" }
}
if ($taskInfo.hadPlayerConfig -and -not (Test-Path -LiteralPath (Join-Path $taskBackup 'RSBridgePlayer.txt'))) { throw 'Backup incompleto: RSBridgePlayer.txt' }
foreach ($taskName in @('RS_ASIO.dll','RS_ASIO.ini','Rocksmith.ini')) {
    Copy-Item -LiteralPath (Join-Path $taskBackup $taskName) -Destination (Join-Path $taskGame $taskName) -Force
}
$taskMarker = Join-Path $taskGame 'RSBridgePlayer.txt'
if ($taskInfo.hadPlayerConfig) { Copy-Item -LiteralPath (Join-Path $taskBackup 'RSBridgePlayer.txt') -Destination $taskMarker -Force }
elseif (Test-Path -LiteralPath $taskMarker) { Remove-Item -LiteralPath $taskMarker }
Write-Host 'DLL, configurações e configuração do reprodutor anteriores restauradas.'
