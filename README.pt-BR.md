# Rocksmith Discord Bridge

Compartilhe **o próprio Rocksmith 2014 no Discord com o áudio ASIO**, preservando a imagem original do jogo.

[English](README.md) · [Baixar / Releases](https://github.com/erickyfigueiredo/RocksmithDiscordBridge/releases)

O mod copia o áudio final do jogo e abre um reprodutor invisível como processo filho do Rocksmith. O Discord captura o áudio do aplicativo compartilhado e dos filhos dele. A imagem não passa pela prévia Python, e não precisa deixar uma janelinha sobre o jogo.

## Requisitos

- Windows 10/11 x64 e Discord para desktop.
- Rocksmith 2014 Remastered já funcionando com **RS_ASIO 0.7.4** e seu driver ASIO configurado.
- Uma saída estéreo WASAPI disponível para reproduzir a cópia do áudio.

Prévia experimental 0.1.0: a transmissão foi confirmada em uma configuração Windows. Cada pessoa escolhe a própria saída e mantém sua configuração ASIO; a compatibilidade com outros equipamentos ainda precisa de testes. O ZIP pronto inclui Python: não precisa instalar Python, Node, OBS ou Voicemeeter para usar.

## Instalar

1. Em **Releases**, baixe `RocksmithDiscordBridge-Windows-x64.zip`. O botão “Source code” baixa apenas o código.
2. Extraia **todo o ZIP** para uma pasta permanente onde você possa gravar, por exemplo em Documentos. Não mova essa pasta depois de instalar.
3. Feche o Rocksmith e execute `Instalar.cmd`. Ele procura as bibliotecas Steam automaticamente ou pede a pasta do jogo; em seguida você escolhe onde ouvir o áudio. Se houver acesso negado na pasta do jogo, execute o instalador como administrador.
4. Abra o jogo normalmente pela Steam. O reprodutor invisível será aberto pelo mod.
5. No Discord, compartilhe **Rocksmith 2014**, com som ligado. Escolha a resolução e a taxa de quadros desejadas no Discord.

O instalador faz backup da DLL e das configurações anteriores. Ele troca `RS_ASIO.dll` e escreve `RSBridgePlayer.txt`, preservando canais de entrada/saída, buffers e configurações de vídeo. Não instala drivers nem inclui arquivos do jogo.

Para outra biblioteca Steam:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\Install.ps1 -GameDirectory 'D:\SteamLibrary\steamapps\common\Rocksmith2014'
```

Para mudar o fone, feche o jogo, execute `Configurar-audio.cmd` e abra o jogo de novo. Não abra outra ponte manualmente junto do reprodutor automático, pois isso pode duplicar o áudio.

## Atraso e qualidade

A cópia usa um buffer solicitado de 60 ms; quem ouve por ela pode perceber atraso ao tocar. A latência total não foi medida. A saída ASIO original não espera pelo reprodutor. Se você já ouve diretamente pela interface, use outra saída para a cópia da transmissão e evite ouvir o jogo duas vezes.

A imagem vem diretamente do jogo. A qualidade que chega a quem assiste depende também das opções da conta Discord, resolução/fps escolhidos, conexão e codificação. Se o jogo for minimizado ou parar de renderizar, a captura pode pausar; mantenha-o visível enquanto joga ou use o modo janela dele.

## Restaurar

Com o jogo fechado, use a pasta de backup informada pelo instalador:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\Restore.ps1 -BackupDirectory '.\backups\PASTA-DO-SEU-BACKUP'
```

O reprodutor grava diagnósticos locais em `player/diagnostics.json` e `player/bridge.log`. O aplicativo não envia esses arquivos. O pacote é comunitário, experimental e ainda não é assinado digitalmente. Leia os limites e instruções de compilação no [README em inglês](README.md).
