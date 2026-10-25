# Code signing

## Windows warnings

Distributed installers are currently unsigned. Windows SmartScreen may display an “unrecognized app” warning when a file or publisher lacks reputation. This warning alone is not a named malware detection. Check the release source and SHA256 checksum.

Os instaladores distribuídos estão sem assinatura digital. O SmartScreen pode mostrar “aplicativo não reconhecido” quando o arquivo ou publicador ainda não tem reputação. Esse aviso, sozinho, não é uma detecção específica de vírus. Confira a origem da release e seu checksum SHA256.

A publicly trusted signature identifies the publisher, but new signed files may still need reputation. See [Microsoft's documentation](https://learn.microsoft.com/en-us/windows/apps/package-and-deploy/smartscreen-reputation).

## Signed builds

Use a publicly trusted code-signing certificate with its key accessible in the build account's `CurrentUser\My` store and the Windows SDK signing tools. Cloud services may require provider-specific integration. Keep credentials and private keys outside source control.

After building the DLLs and player:

```powershell
./tools/SignPayload.ps1 -CertificateThumbprint '<40-character thumbprint>'
python tools/collect_licenses.py
./tools/BuildInstaller.ps1 -SigningThumbprint '<same thumbprint>'
```

The payload signer signs only the player and project-built DLLs. Inno Setup signs Setup and the uninstaller. Verification requires the selected publisher, a valid trust chain and a timestamp. SHA256 checksums are generated afterward. Without `-SigningThumbprint`, the build produces an unsigned preview. Validate the signed installer and installed uninstaller with the real certificate before publishing.

References: [SignTool](https://learn.microsoft.com/en-us/windows/win32/seccrypto/signtool), [Inno Setup signing](https://jrsoftware.org/ishelp/topic_setup_signtool.htm).
