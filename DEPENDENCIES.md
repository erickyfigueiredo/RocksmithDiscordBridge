# Dependencies / Dependências

| Component | Required, included or optional / Necessário, incluído ou opcional |
| --- | --- |
| Windows 10/11 x64 | Required. The wizard does not install Windows. / Sistema necessário. |
| Steam + Rocksmith 2014 Remastered | Required. Install through Steam and run once. Not included/downloaded by this wizard. / Instale pela Steam e abra uma vez. |
| Discord desktop | Required for streaming. Install from https://discord.com/download. / Necessário para transmitir; instalação separada. |
| 32-bit ASIO driver | Required. Prefer the interface manufacturer's official driver. The wizard detects registered 32-bit drivers and offers ASIO4ALL as an optional fallback. / Prefira o driver oficial do fabricante. |
| RS_ASIO 0.7.4 support | Included. The wizard can install missing support and create an initial driver/channel configuration. / Suporte incluído; configurações existentes preservadas. |
| Stereo Windows output | Required for copied audio; select with Configure audio. / Escolha a saída disponível em Configurar áudio. |
| Python and app libraries | Included: Python, NumPy, sounddevice/PortAudio, Pillow, Windows Capture and their runtime libraries. / Já incluídos. |

## Optional downloads / Downloads opcionais

- **ASIO4ALL 2.22:** choosing **USB interface / not sure** selects its download if it is missing. Review the checkbox on Prepare audio before installing. Downloaded from https://asio4all.org/downloads/ASIO4ALL_2_22.exe with a fixed SHA256 check. Its own graphical setup/license opens. The audio wizard then opens its device panel. Select only your interface's input/output and use 48 kHz. It is not needed when an appropriate manufacturer's ASIO driver is already installed.
- **Microsoft Visual C++ v14 x86/x64:** optional repairs for game/third-party-driver dependencies. Our RS_ASIO DLL links the C++ runtime statically; the player bundles its runtime. These repairs are not claimed as universally required. The wizard uses version-pinned Microsoft URLs and SHA256 checks, with the standard Microsoft progress UI and no forced immediate reboot.

Ao escolher **Interface USB / não sei**, o assistente marca o ASIO4ALL para instalação se ele estiver ausente. A tela Preparar áudio mostra o download antes de instalar. Os reparos Visual C++ ficam em **Avançado** e começam desmarcados. O suporte RS_ASIO já vem incluído. Drivers de fabricantes devem vir dos sites oficiais.

## Interface USB versus ASIO driver

A USB device name is not necessarily an ASIO driver name. If your interface has no native 32-bit ASIO driver, it appears inside the ASIO4ALL device panel instead. The normal USB path selects ASIO4ALL; it never substitutes the first unrelated driver in the registry. Manufacturer drivers remain available in the advanced path. Input **1** in the wizard becomes channel **0** in RS_ASIO.ini.

O nome da interface USB pode não aparecer na lista de drivers. Nesse caso, escolha **Interface USB** e ative a interface dentro do painel ASIO4ALL. A entrada **1** do assistente corresponde ao canal **0** do arquivo técnico.

Dependency installers may request a restart. Uninstalling the bridge does not remove shared ASIO drivers or Microsoft runtimes used by other applications.

## Developer tools / Ferramentas de desenvolvimento

Only developers need Python 3.12 x64, Node.js, MSVC/Windows SDK and Inno Setup 6.7.3 or newer. See CONTRIBUTING.md. Setup.exe does not install those tools on end-user machines.
