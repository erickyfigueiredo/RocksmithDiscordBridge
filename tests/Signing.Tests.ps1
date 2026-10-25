$ErrorActionPreference = 'Stop'
. (Join-Path (Split-Path $PSScriptRoot) 'tools\Signing.ps1')
$taskRejected = $false
try { Get-BridgeSigningOptions -CertificateThumbprint 'not-a-thumbprint' | Out-Null }
catch { $taskRejected = $_.Exception.Message -like '*40-character*' }
if (-not $taskRejected) { throw 'Invalid certificate identifiers must be rejected before accessing a certificate store.' }
$taskRejected = $false
try { Assert-BridgeSignature -Path $PSCommandPath -CertificateThumbprint ('A' * 40) }
catch { $taskRejected = $_.Exception.Message -like '*signature*missing*' }
if (-not $taskRejected) { throw 'An unsigned artifact must not pass signature verification.' }
Write-Host 'PASS: signing preflight rejects invalid certificate identifiers and unsigned artifacts.'
