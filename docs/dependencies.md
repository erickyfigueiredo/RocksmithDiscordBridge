# Dependencies / Dependências

| Component | Requirement / Requisito |
| --- | --- |
| Windows 10/11 x64 | Required / Necessário |
| Steam + Rocksmith 2014 Remastered | Install separately and run once / Instale separadamente e abra uma vez |
| Discord desktop | Required for streaming / Necessário para transmitir |
| 32-bit ASIO driver | Manufacturer driver or ASIO4ALL / Driver do fabricante ou ASIO4ALL |
| Stereo Windows output | Headphones or speakers / Fone ou caixas de som |
| RS_ASIO 0.7.4 | Included / Incluído |
| Python, NumPy, sounddevice and runtime libraries | Included / Incluídos |
| RSMods | Optional / Opcional |

## Audio devices / Dispositivos de áudio

Prefer your interface manufacturer's 32-bit ASIO driver. For USB interfaces without one, choose **USB interface — guided setup**. ASIO4ALL is selected for download if missing. Review the components before installing, then enable your interface's input and output in its panel. Use 48 kHz. Choose your listening output in the Headphones step. Physical input 1 corresponds to channel 0 internally.

Prefira o driver ASIO de 32 bits do fabricante. Para interfaces USB sem esse driver, escolha **Interface USB — configuração guiada**. O assistente marca o download do ASIO4ALL se ele estiver ausente. Confira os componentes antes de instalar e ative a entrada e a saída da interface no painel dele. Use 48 kHz. Escolha onde ouvir o jogo na etapa Fone. A entrada física 1 corresponde ao canal interno 0.

## Optional downloads / Downloads opcionais

- **ASIO4ALL 2.22:** downloaded from [asio4all.org](https://asio4all.org/) with a pinned SHA256 check. Its own installer and license are displayed. / Baixado da fonte oficial, com verificação SHA256 e instalador/licença próprios.
- **Microsoft Visual C++ v14 x86/x64:** optional repairs under Advanced for game or driver dependencies. / Reparos opcionais em Avançado para dependências do jogo ou driver.

Shared drivers and runtimes are not removed when uninstalling the bridge. / Drivers e runtimes compartilhados não são removidos ao desinstalar a ponte.
