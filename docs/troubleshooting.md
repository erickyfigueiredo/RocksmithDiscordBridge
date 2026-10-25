# Troubleshooting / Solução de problemas

| Symptom / Sintoma | Check / Verificação |
| --- | --- |
| Interface missing / Interface ausente | USB devices without native ASIO appear inside ASIO4ALL's panel. / Dispositivos USB sem ASIO nativo aparecem no painel ASIO4ALL. |
| No local sound / Sem som local | Choose a stereo output and restart the game. Exclusive use may block an output. / Escolha uma saída estéreo e reabra o jogo. Uso exclusivo pode bloquear uma saída. |
| No guitar / Sem guitarra | Check the enabled input, input number and 48 kHz. / Confira a entrada ativada, seu número e os 48 kHz. |
| Game closes / Jogo fecha sozinho | Test other mods separately and check local diagnostics. / Teste outros mods separadamente e confira os diagnósticos locais. |
| Capture pauses / Captura pausa | Keep Rocksmith rendering in the foreground. / Mantenha o Rocksmith renderizando em primeiro plano. |
| Poor viewer quality / Qualidade ruim | Check Discord resolution, frame rate and connection. / Confira resolução, fps e conexão no Discord. |
| Windows warning / Aviso do Windows | See [signing](signing.md#windows-warnings). / Veja [assinatura](signing.md#windows-warnings). |

The audio copy requests a 60 ms buffer; total playing latency depends on the devices. Avoid hearing direct monitoring and the delayed copy together. Local tests cannot verify the remote stream.

A cópia solicita um buffer de 60 ms; o atraso total depende dos dispositivos. Evite ouvir o monitoramento direto junto da cópia atrasada. O teste local não verifica a transmissão recebida por outra pessoa.

## Update and uninstall / Atualizar e desinstalar

Close the game and run Setup in the same application/game folders to update. Configuration and original backups are preserved. Uninstall through Windows Settings. Files modified after installation are retained, as are shared drivers, runtimes, preferences and backups.

Feche o jogo e execute o Setup nas mesmas pastas do aplicativo/jogo para atualizar. A configuração e os backups originais são preservados. Desinstale pelas Configurações do Windows. Arquivos alterados após a instalação são preservados, assim como drivers compartilhados, runtimes, preferências e backups.
