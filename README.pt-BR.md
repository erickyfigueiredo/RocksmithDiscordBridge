# Rocksmith Discord Bridge

Compartilhe **o próprio Rocksmith 2014 no Discord com áudio ASIO**, mantendo a imagem original do jogo.

[English](README.md) · [Baixar instalador](https://github.com/erickyfigueiredo/RocksmithDiscordBridge/releases) · [Dependências](DEPENDENCIES.md)

O mod abre um reprodutor invisível como processo filho do Rocksmith. O Discord captura o áudio desse processo junto do jogo. A imagem não passa pela prévia Python, e não precisa deixar uma janelinha sobre a tela.

## Requisitos — leia antes de instalar

- **Windows 10/11 x64**, Rocksmith 2014 Remastered da Steam e Discord desktop. Abra o jogo uma vez antes. O assistente não compra nem instala o jogo ou o Discord.
- **Driver ASIO de 32 bits** para a interface da guitarra. Prefira o do fabricante. O assistente detecta drivers e oferece **ASIO4ALL opcional** como alternativa.
- **RS_ASIO 0.7.4:** os arquivos de suporte estão incluídos. O assistente pode instalar o que falta e criar uma configuração inicial, preservando configurações existentes.
- Saída estéreo WASAPI disponível para ouvir a cópia do áudio.
- **Python e bibliotecas já incluídos.** Não precisa instalar Python, Node.js, OBS, Voicemeeter ou ferramentas de desenvolvimento.

**RSMods é opcional.** O aplicativo funciona sem ele. O suporte necessário RS_ASIO já está incluído no Setup.

Leia [DEPENDENCIES.md](DEPENDENCIES.md) para conferir requisitos e downloads. A versão 0.3.1 é uma prévia experimental; outros equipamentos ainda precisam de testes.

## Instalação gráfica

1. Em Releases, baixe **RocksmithDiscordBridge-Setup-x64.exe**. Feche o jogo e abra o instalador.
2. Escolha **Interface USB — configuração guiada**, ou o driver do fabricante em **Avançado**. Confira os componentes e selecione a entrada **1, 2…** onde conectou a guitarra.
3. Siga **Guitarra → Fone → Testar**. Na opção USB, abra o painel ASIO4ALL e ative só a entrada e a saída da sua interface. O nome dela aparece nesse painel, não necessariamente na lista de drivers.
4. Escolha seu fone, abra o jogo e toque algumas notas. O assistente verifica se chegam novos blocos e sinal de áudio; confirme que ouve o jogo e a guitarra. Português e inglês podem ser trocados na própria janela.
5. Abra o jogo normalmente pela Steam e compartilhe **Rocksmith 2014 com som** no Discord, na qualidade desejada.

O fluxo principal de instalação, configuração e desinstalação **não executa PowerShell nem CMD**. O ASIO4ALL abre o instalador gráfico/licença próprio. O reparo opcional do Visual C++ mostra o progresso normal da Microsoft. Os downloads têm SHA256 fixo verificado. O assistente avisa caso uma dependência peça reinicialização.

O instalador pede acesso de administrador e faz backup dos arquivos do jogo que alterar. Preserva configurações ASIO e vídeo existentes. Na primeira configuração ASIO, habilita os dois parâmetros de áudio necessários sem alterar o vídeo. Não inclui arquivos do jogo; instaladores de drivers/runtimes de terceiros são baixados de fontes oficiais apenas quando escolhidos.

O ZIP portátil continua disponível para usuários avançados com RS_ASIO funcionando. Os scripts antigos dele não participam do Setup.exe. O botão Source code do GitHub baixa o código, não o aplicativo pronto.

O instalador atual ainda não tem assinatura digital de publicador. O aviso de “aplicativo não reconhecido” do Windows é de reputação do SmartScreen. Isso, sozinho, não é uma detecção específica de vírus. Confira a origem e os checksums publicados. Veja [assinatura e avisos do Windows](SIGNING.md).

## Desinstalar e dados locais

Feche o jogo e desinstale **Rocksmith Discord Bridge** nas Configurações do Windows. Os arquivos anteriores são restaurados. Alterações feitas depois pelo usuário são preservadas, e os backups continuam em ProgramData. Drivers e runtimes compartilhados não são removidos.

Configurações e diagnósticos: `%LOCALAPPDATA%\RocksmithDiscordBridge`. Estado da instalação e backups: `%PROGRAMDATA%\RocksmithDiscordBridge`. O aplicativo não envia esses dados. Veja [PRIVACY.md](PRIVACY.md).

Para instalações antigas pelo script portátil, use o Restore.ps1 e o backup indicados por ele.

Se o jogo fechar sozinho, confira outros mods instalados. O assistente avisa quando encontra mods, mas não os desativa nem altera suas configurações. O teste local não confirma a qualidade recebida no Discord: peça a quem assiste para validar imagem e som.

## Atraso e qualidade

A cópia usa um buffer solicitado de 60 ms e pode adicionar atraso ao tocar; a latência total não foi medida. A saída ASIO original não espera pela cópia. Evite ouvir as duas ao mesmo tempo.

A imagem vem diretamente do jogo. A qualidade recebida depende também das opções da conta Discord, resolução/fps escolhidos, conexão e codificação. Se o jogo minimizar ou parar de renderizar, a captura pode pausar. Leia os limites e instruções de compilação no [README em inglês](README.md).
