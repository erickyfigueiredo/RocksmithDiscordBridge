param([string]$SourceDirectory, [string]$Toolset = 'v143')
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
$taskRoot = $PSScriptRoot
if (-not (Get-Command node -ErrorAction SilentlyContinue)) { throw 'Instale Node.js LTS para aplicar o patch.' }
$taskVswhere = Join-Path ${env:ProgramFiles(x86)} 'Microsoft Visual Studio\Installer\vswhere.exe'
if (-not (Test-Path -LiteralPath $taskVswhere)) {
    throw 'Falta Visual Studio Build Tools 2022 com Desktop development with C++, MSVC v143 x86/x64 e Windows SDK. Nenhuma DLL foi instalada.'
}
$taskMSBuild = & $taskVswhere -latest -products '*' -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -find 'MSBuild\**\Bin\MSBuild.exe' | Select-Object -First 1
if (-not $taskMSBuild) { throw 'Compilador C++ x86/x64 não encontrado no Visual Studio Build Tools.' }
if (-not $SourceDirectory) {
    $taskVendor = Join-Path $taskRoot 'vendor'
    New-Item -ItemType Directory -Path $taskVendor -Force | Out-Null
    $taskZip = Join-Path $taskVendor 'rs_asio-v0.7.4.zip'
    $taskSource = Join-Path $taskVendor ('build-' + [guid]::NewGuid().ToString('N'))
    # Build against the pinned upstream release.
    Invoke-WebRequest -Uri 'https://codeload.github.com/mdias/rs_asio/zip/refs/tags/v0.7.4' -OutFile $taskZip -UseBasicParsing
    Expand-Archive -LiteralPath $taskZip -DestinationPath $taskSource
    $SourceDirectory = Join-Path $taskSource 'rs_asio-0.7.4'
}
$SourceDirectory = (Resolve-Path -LiteralPath $SourceDirectory).Path
& node (Join-Path $taskRoot 'tools\patch.mjs') $SourceDirectory
if ($LASTEXITCODE -ne 0) { throw 'Falha ao aplicar o patch. Use fonte limpa do RS_ASIO v0.7.4.' }
$taskOut = Join-Path $taskRoot 'bin'
New-Item -ItemType Directory -Path $taskOut -Force | Out-Null
& $taskMSBuild (Join-Path $SourceDirectory 'RS_ASIO.sln') /m /t:Rebuild /p:Configuration=Release /p:Platform=x86 "/p:PlatformToolset=$Toolset" "/p:OutDir=$taskOut/"
if ($LASTEXITCODE -ne 0) { throw 'Compilação da DLL falhou; jogo não alterado.' }
if (-not (Test-Path -LiteralPath (Join-Path $taskOut 'RS_ASIO.dll'))) { throw 'A compilação não produziu RS_ASIO.dll.' }
& $taskMSBuild (Join-Path $taskRoot 'tests\NativeTests.vcxproj') /t:Rebuild /p:Configuration=Release /p:Platform=Win32 "/p:PlatformToolset=$Toolset"
if ($LASTEXITCODE -ne 0) { throw 'Compilação do teste nativo falhou.' }
& (Join-Path $taskOut 'tests\native_tap_test.exe')
if ($LASTEXITCODE -ne 0) { throw 'Teste nativo falhou; não instale a DLL.' }
Get-FileHash -LiteralPath (Join-Path $taskOut 'RS_ASIO.dll') -Algorithm SHA256
Write-Host 'DLL x86 compilada e teste nativo aprovado. Gere o instalador com tools/BuildInstaller.ps1.'
