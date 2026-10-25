param([string]$Compiler, [string]$SigningThumbprint)
$ErrorActionPreference = 'Stop'
$taskRoot = Split-Path $PSScriptRoot
if (-not $Compiler) {
    $taskCandidates = @(
        (Join-Path ${env:ProgramFiles(x86)} 'Inno Setup 6\ISCC.exe'),
        (Join-Path $env:ProgramFiles 'Inno Setup 7\ISCC.exe')
    )
    $Compiler = $taskCandidates | Where-Object { Test-Path -LiteralPath $_ } | Select-Object -First 1
}
if (-not $Compiler) { throw 'Install Inno Setup 6.7.3 or newer to build the GUI installer.' }
$taskVersion = (Get-Content -Raw -LiteralPath (Join-Path $taskRoot 'VERSION')).Trim()
$taskInnoLicense = Join-Path (Split-Path $Compiler) 'license.txt'
if (Test-Path -LiteralPath $taskInnoLicense) { Copy-Item -LiteralPath $taskInnoLicense -Destination (Join-Path $taskRoot 'licenses\InnoSetup-license.txt') -Force }
$taskCompilerArgs = @("/DAppVersion=$taskVersion")
if ($SigningThumbprint) {
    . (Join-Path $PSScriptRoot 'Signing.ps1')
    $taskSigning = Get-BridgeSigningOptions -CertificateThumbprint $SigningThumbprint
    foreach ($taskName in @('bin\RS_ASIO.dll','bin\avrt.dll','dist\RocksmithStreamBridge\RocksmithStreamBridge.exe')) {
        Assert-BridgeSignature -Path (Join-Path $taskRoot $taskName) -CertificateThumbprint $SigningThumbprint
    }
    $taskCompilerArgs += @('/DSigningEnabled=1', ('/S' + $taskSigning.InnoCommand))
}
& $Compiler @taskCompilerArgs (Join-Path $taskRoot 'installer\BridgeSetup.iss')
if ($LASTEXITCODE -ne 0) { throw 'Inno Setup compilation failed.' }
if ($SigningThumbprint) {
    Assert-BridgeSignature -Path (Join-Path $taskRoot 'release\RocksmithDiscordBridge-Setup-x64.exe') -CertificateThumbprint $SigningThumbprint
} else {
    Write-Host 'Unsigned preview: no publisher certificate was supplied; SmartScreen may warn.'
}
& python -c "from pathlib import Path; import hashlib; p=Path('release'); files=sorted(f for f in p.iterdir() if f.suffix in ('.exe','.zip') and 'source' not in f.name); (p/'SHA256SUMS.txt').write_text(''.join(hashlib.sha256(f.read_bytes()).hexdigest()+'  '+f.name+'\n' for f in files),encoding='utf-8')"
if ($LASTEXITCODE -ne 0) { throw 'Failed to generate release checksums.' }
