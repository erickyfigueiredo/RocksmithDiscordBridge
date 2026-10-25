# Rocksmith Discord Bridge

Transmita **Rocksmith 2014 com áudio ASIO no Discord**, usando a própria janela do jogo.

[English](README.md) · [Baixar Setup](https://github.com/erickyfigueiredo/RocksmithDiscordBridge/releases) · [Dependências](docs/dependencies.md)

## Requisitos

- Windows 10/11 x64, Rocksmith 2014 Remastered da Steam e Discord desktop.
- Interface de guitarra com driver ASIO de 32 bits, ou ASIO4ALL.
- Saída de áudio estéreo do Windows para seu fone ou suas caixas de som.

RS_ASIO, Python e as bibliotecas do aplicativo estão incluídos. **RSMods é opcional.**

## Instalação

1. Abra o Rocksmith uma vez e feche o jogo.
2. Baixe **RocksmithDiscordBridge-Setup-x64.exe** em Releases e abra o instalador.
3. Escolha **Interface USB — configuração guiada**, ou o driver do fabricante em **Avançado**. Confira os componentes e selecione a entrada da guitarra.
4. Siga **Guitarra → Fone → Testar**. No ASIO4ALL, ative a entrada e a saída da sua interface. Escolha o fone no próximo passo.
5. Abra o jogo e toque algumas notas. Depois de confirmar o som, compartilhe **Rocksmith 2014 com som** no Discord.

O assistente oferece português e inglês. Ele preserva a configuração de áudio/vídeo existente e faz backup dos arquivos do jogo antes de alterá-los. Para atualizar, reinstale na mesma pasta. Feche o jogo antes de instalar ou desinstalar.

O instalador de prévia está **sem assinatura digital** e pode exibir um aviso do SmartScreen. Veja [avisos do Windows](docs/signing.md#windows-warnings). Cada release inclui os checksums dos arquivos.

## Como funciona

O patch RS_ASIO copia o áudio para um reprodutor invisível iniciado pelo Rocksmith. O Discord captura o áudio desse processo junto do jogo. A imagem vem diretamente da janela do jogo. Veja a [descrição da captura do Discord](https://discord.com/blog/how-it-all-goes-live-an-overview-of-discords-streaming-technology).

A cópia solicita um buffer de 60 ms e pode adicionar atraso ao tocar. O formato suportado é estéreo em 48 kHz. A qualidade recebida depende das opções do Discord e da conexão; minimizar o jogo pode pausar a captura.

## Ajuda e desenvolvimento

- [Dependências e configuração dos dispositivos](docs/dependencies.md)
- [Solução de problemas e desinstalação](docs/troubleshooting.md)
- [Privacidade e arquivos locais](docs/privacy.md)
- [Compilação e contribuição](CONTRIBUTING.md)
- [Status das compilações](https://github.com/erickyfigueiredo/RocksmithDiscordBridge/actions)

Projeto da comunidade, sem vínculo com Ubisoft ou Discord. Licença [MIT](LICENSE), com [avisos de terceiros](THIRD_PARTY_NOTICES.md). RS_ASIO é de [Micael Dias](https://github.com/mdias/rs_asio).
