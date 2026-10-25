param(
    [string]$GameDirectory,
    [string]$PlayerPath = (Join-Path $PSScriptRoot 'player\RocksmithStreamBridge.exe'),
    [switch]$SkipOutputSelection
)
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
. (Join-Path $PSScriptRoot 'tools\FindGame.ps1')
if (-not $GameDirectory) {
    $GameDirectory = Find-RocksmithDirectory
    if (-not $GameDirectory) {
        Add-Type -AssemblyName System.Windows.Forms
        $taskPicker = New-Object System.Windows.Forms.FolderBrowserDialog
        $taskPicker.Description = 'Selecione a pasta do Rocksmith 2014 / Select the Rocksmith 2014 folder'
        try {
            if ($taskPicker.ShowDialog() -ne [System.Windows.Forms.DialogResult]::OK) { throw 'Seleção da pasta cancelada. O jogo não foi alterado.' }
            $GameDirectory = $taskPicker.SelectedPath
        } finally { $taskPicker.Dispose() }
    }
}
$taskGame = (Resolve-Path -LiteralPath $GameDirectory).Path
if (Get-Process -Name Rocksmith2014 -ErrorAction SilentlyContinue | Where-Object { $_.Path -and (Split-Path $_.Path) -ieq $taskGame }) { throw 'Feche o Rocksmith antes de instalar.' }
$taskDll = Join-Path $PSScriptRoot 'bin\RS_ASIO.dll'
foreach ($taskFile in @($taskDll, $PlayerPath)) {
    if (-not (Test-Path -LiteralPath $taskFile -PathType Leaf)) { throw "Arquivo ausente: $taskFile. Extraia o ZIP completo da Release." }
}
$taskPlayer = (Resolve-Path -LiteralPath $PlayerPath).Path
if ($taskPlayer.Length -ge 260 -or $taskPlayer.Contains('"')) { throw 'Extraia o pacote em uma pasta com caminho mais curto.' }
$taskBinary = [IO.File]::ReadAllBytes($taskDll)
if ($taskBinary.Length -lt 256 -or $taskBinary[0] -ne 0x4d -or $taskBinary[1] -ne 0x5a) { throw 'DLL inválida.' }
$taskPe = [BitConverter]::ToInt32($taskBinary, 0x3c)
if ($taskPe -lt 0 -or $taskPe + 24 -gt $taskBinary.Length -or [BitConverter]::ToUInt32($taskBinary,$taskPe) -ne 0x4550 -or [BitConverter]::ToUInt16($taskBinary,$taskPe+4) -ne 0x14c) { throw 'DLL precisa ser PE x86 (32 bits).' }
$taskOriginals = @('RS_ASIO.dll','RS_ASIO.ini','Rocksmith.ini')
foreach ($taskName in $taskOriginals + @('avrt.dll','Rocksmith2014.exe')) {
    if (-not (Test-Path -LiteralPath (Join-Path $taskGame $taskName) -PathType Leaf)) { throw "Instalação incompleta: falta $taskName. Configure e teste RS_ASIO 0.7.4 antes de usar esta ponte." }
}
if (-not $SkipOutputSelection) {
    & $taskPlayer '--configure-output'
    if ($LASTEXITCODE -ne 0) { throw 'Seleção de saída cancelada. O jogo não foi alterado.' }
} elseif (-not (Test-Path -LiteralPath (Join-Path (Split-Path $taskPlayer) 'settings.json'))) {
    throw 'Configure a saída de áudio antes de usar -SkipOutputSelection.'
}
$taskMarker = Join-Path $taskGame 'RSBridgePlayer.txt'
if ($taskMarker.Length -ge 260) { throw 'O caminho da pasta do jogo excede o limite suportado pelo launcher.' }
$taskHadMarker = Test-Path -LiteralPath $taskMarker
$taskBackup = Join-Path $PSScriptRoot ('backups\' + (Get-Date -Format 'yyyyMMdd-HHmmss') + '-' + [guid]::NewGuid().ToString('N').Substring(0,8))
New-Item -ItemType Directory -Path $taskBackup -Force | Out-Null
foreach ($taskName in $taskOriginals) { Copy-Item -LiteralPath (Join-Path $taskGame $taskName) -Destination (Join-Path $taskBackup $taskName) }
if ($taskHadMarker) { Copy-Item -LiteralPath $taskMarker -Destination (Join-Path $taskBackup 'RSBridgePlayer.txt') }
@{ game = $taskGame; hadPlayerConfig = [bool]$taskHadMarker; version = 1 } | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $taskBackup 'installation.json') -Encoding UTF8
$taskTouchedDll = $false
$taskTouchedMarker = $false
try {
    Copy-Item -LiteralPath $taskDll -Destination (Join-Path $taskGame 'RS_ASIO.dll') -Force
    $taskTouchedDll = $true
    # UTF-16LE without BOM matches the native launcher. No user ASIO/video settings are changed.
    $taskTouchedMarker = $true
    [IO.File]::WriteAllText($taskMarker,$taskPlayer,(New-Object Text.UnicodeEncoding $false,$false))
} catch {
    $taskFailure = $_
    if ($taskTouchedDll) { Copy-Item -LiteralPath (Join-Path $taskBackup 'RS_ASIO.dll') -Destination (Join-Path $taskGame 'RS_ASIO.dll') -Force }
    if ($taskTouchedMarker) {
        if ($taskHadMarker) { Copy-Item -LiteralPath (Join-Path $taskBackup 'RSBridgePlayer.txt') -Destination $taskMarker -Force }
        elseif (Test-Path -LiteralPath $taskMarker) { Remove-Item -LiteralPath $taskMarker }
    }
    throw $taskFailure
}
Write-Host "Instalado. Backup: $taskBackup"
Write-Host 'Abra Rocksmith pela Steam normalmente. No Discord, compartilhe ROCKSMITH 2014 com som.'
Write-Host 'Mantenha esta pasta no lugar: o jogo abre o reprodutor automaticamente daqui.'
