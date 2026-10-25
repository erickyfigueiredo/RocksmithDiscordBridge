$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
. (Join-Path $PSScriptRoot '..\tools\FindGame.ps1')
$taskFixture = Join-Path $env:TEMP ('rsbridge-library-test-' + [guid]::NewGuid().ToString('N'))
$taskSteam = Join-Path $taskFixture 'Steam Root'
$taskLibrary = Join-Path $taskFixture 'Other Library'
$taskGame = Join-Path $taskLibrary 'steamapps\common\CustomGameName'
New-Item -ItemType Directory -Path (Join-Path $taskSteam 'steamapps'),$taskGame -Force | Out-Null
[IO.File]::WriteAllText((Join-Path $taskSteam 'steamapps\libraryfolders.vdf'), ('"libraryfolders" { "1" { "path" "' + $taskLibrary.Replace('\','\\') + '" } }'))
[IO.File]::WriteAllText((Join-Path $taskLibrary 'steamapps\appmanifest_221680.acf'),'"AppState" { "installdir" "CustomGameName" }')
[IO.File]::WriteAllText((Join-Path $taskGame 'Rocksmith2014.exe'),'NON-EXECUTABLE FIXTURE')
$taskFound = Find-RocksmithDirectory -SteamRoots @($taskSteam)
if ($taskFound -cne $taskGame) { throw "Biblioteca adicional não encontrada: $taskFound" }
if (Find-RocksmithDirectory -SteamRoots @((Join-Path $taskFixture 'Missing'))) { throw 'Pasta ausente deveria retornar null.' }
Write-Output 'PASS: biblioteca Steam adicional, caminhos com espaços, nome de instalação do manifesto e pasta ausente.'
