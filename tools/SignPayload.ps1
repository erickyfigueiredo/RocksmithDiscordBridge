param([Parameter(Mandatory=$true)][string]$CertificateThumbprint)
$ErrorActionPreference = 'Stop'
$taskRoot = Split-Path $PSScriptRoot
. (Join-Path $PSScriptRoot 'Signing.ps1')
$taskSigning = Get-BridgeSigningOptions -CertificateThumbprint $CertificateThumbprint
# Sign only our own outputs, leaving third-party runtime signatures alone.
$taskFiles = @('bin\RS_ASIO.dll','bin\avrt.dll','dist\RocksmithStreamBridge\RocksmithStreamBridge.exe') |
    ForEach-Object { Join-Path $taskRoot $_ }
foreach ($taskFile in $taskFiles) {
    if (-not (Test-Path -LiteralPath $taskFile -PathType Leaf)) { throw "Build output missing: $taskFile" }
}
foreach ($taskFile in $taskFiles) {
    & $taskSigning.Tool sign /sha1 $taskSigning.Thumbprint /fd SHA256 /tr http://timestamp.digicert.com /td SHA256 $taskFile
    if ($LASTEXITCODE -ne 0) { throw "Signing failed: $taskFile" }
    Assert-BridgeSignature -Path $taskFile -CertificateThumbprint $taskSigning.Thumbprint
}
Write-Host 'Publisher signatures and timestamps verified. Build the signed installer next.'
