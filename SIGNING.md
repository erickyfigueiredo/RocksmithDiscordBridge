# Publisher signing and Windows warnings

The current GitHub preview is **unsigned**. A build, checksum or antivirus scan does not make it signed. We do not ask users to disable Windows protection.

**Português:** a prévia atual ainda não tem assinatura digital de publicador. O aviso “O Windows protegeu o computador / aplicativo não reconhecido” é de reputação do SmartScreen. Não é uma detecção específica de vírus. Uma assinatura válida identifica o publicador, mas um arquivo novo ainda pode exibir esse aviso enquanto ganha reputação. O RSMods é opcional; o suporte necessário RS_ASIO já vem incluído.

## Prepared signing flow

`tools/SignPayload.ps1` signs our player, RS_ASIO and avrt wrapper using an existing certificate, leaving third-party runtime signatures alone. `tools/BuildInstaller.ps1 -SigningThumbprint ...` requires valid payload signatures, asks Inno Setup to sign Setup and its uninstaller, verifies Setup and then generates checksums. SHA256 digests and RFC3161 timestamps are required. Signing errors stop the build.

No certificate, signing credential or personal publisher identity has been added to the repository. The current CI still builds explicitly unsigned previews.

## Signed build

Obtain a publicly trusted code-signing certificate and complete the provider's publisher identity validation. The key must be accessible through the build account's `CurrentUser\My` store, for example through the provider's supported hardware token. Install the Windows SDK signing tools. Do not commit certificates, keys or passwords.

After building the native DLLs and PyInstaller player:

```powershell
./tools/SignPayload.ps1 -CertificateThumbprint '<40-character thumbprint>'
python tools/collect_licenses.py
python tools/package_release.py
./tools/BuildInstaller.ps1 -SigningThumbprint '<same thumbprint>'
```

Sign the payload **before** generating the ZIP and manifest. Do not publish an older unsigned ZIP alongside a newly signed installer. Signed CI releases still require a provider, validated publisher and protected credentials. Cloud services may require their own provider integration instead of this certificate-store route.

The signed branch needs validation with the real certificate, including checking the installed uninstaller signature. It cannot be verified end to end without one. No certificate or security exception is created and no paid service is subscribed to automatically.

## Download checks

Check the published checksum and Authenticode signature. If an antivirus reports a named threat, record that detection and file hash and request analysis from its vendor. Do not label a reputation warning a confirmed antivirus false positive.

References: [Microsoft SmartScreen reputation](https://learn.microsoft.com/en-us/windows/apps/package-and-deploy/smartscreen-reputation), [Microsoft SignTool](https://learn.microsoft.com/en-us/windows/win32/seccrypto/signtool), [Inno Setup signing](https://jrsoftware.org/ishelp/topic_setup_signtool.htm), [Microsoft file analysis submissions](https://www.microsoft.com/en-us/wdsi/filesubmission).
