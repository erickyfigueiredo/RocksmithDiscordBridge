# Developer build helpers. No certificate is created, imported or exported.
function Get-BridgeSigningOptions {
    param([Parameter(Mandatory=$true)][string]$CertificateThumbprint)
    if ($CertificateThumbprint -notmatch '^[A-Fa-f0-9]{40}$') { throw 'Provide a 40-character certificate thumbprint.' }
    $taskCertificate = Get-Item -LiteralPath ('Cert:\CurrentUser\My\' + $CertificateThumbprint) -ErrorAction Stop
    if (-not $taskCertificate.HasPrivateKey -or $taskCertificate.NotAfter -le (Get-Date) -or $taskCertificate.NotBefore -gt (Get-Date)) {
        throw 'A valid code-signing certificate with its private key must be available in CurrentUser\My.'
    }
    $taskTool = Get-Command signtool.exe -ErrorAction SilentlyContinue | Select-Object -First 1 -ExpandProperty Source
    if (-not $taskTool) {
        $taskKits = (Get-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Microsoft\Windows Kits\Installed Roots' -ErrorAction Stop).KitsRoot10
        $taskTool = Get-ChildItem -LiteralPath (Join-Path $taskKits 'bin') -Directory |
            Where-Object { $_.Name -match '^10\.0\.[0-9]+\.[0-9]+$' } |
            Sort-Object { [version]$_.Name } -Descending |
            ForEach-Object { Join-Path $_.FullName 'x64\signtool.exe' } |
            Where-Object { Test-Path -LiteralPath $_ } | Select-Object -First 1
    }
    if (-not $taskTool) { throw 'Install the Windows SDK signing tools before signing a release.' }
    [pscustomobject]@{
        Tool = $taskTool
        Thumbprint = $CertificateThumbprint
        # Inno expands $q to a quote and $f to a quoted filename; no shell is used.
        InnoCommand = 'BridgeSign=$q' + $taskTool + '$q sign /sha1 ' + $CertificateThumbprint + ' /fd SHA256 /tr http://timestamp.digicert.com /td SHA256 $f'
    }
}

function Assert-BridgeSignature {
    param([Parameter(Mandatory=$true)][string]$Path, [Parameter(Mandatory=$true)][string]$CertificateThumbprint)
    $taskSignature = Get-AuthenticodeSignature -LiteralPath $Path
    if ($taskSignature.Status -ne 'Valid' -or -not $taskSignature.SignerCertificate -or
        $taskSignature.SignerCertificate.Thumbprint -ne $CertificateThumbprint -or -not $taskSignature.TimeStamperCertificate) {
        throw "Trusted, timestamped signature from the selected publisher is missing: $Path"
    }
}
