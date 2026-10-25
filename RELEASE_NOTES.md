Initial experimental Windows preview.

- Share Rocksmith 2014 directly in Discord, with copied ASIO audio from a windowless child process.
- Keep the original game image; no reduced preview window or always-on-top overlay is required.
- Select your Windows audio output during installation.
- Preserve existing RS_ASIO routes, channels, buffers and game video settings.
- Back up the current installation and support restoration.
- Include a portable x64 player, modified x86 RS_ASIO DLL, license notices and SHA256 checksums.

Requires Windows 10/11 x64, Discord desktop and an existing working RS_ASIO 0.7.4 setup. End-to-end streaming has been confirmed on one Windows setup; broader hardware compatibility remains experimental. The copied audio has a requested 60 ms playback buffer. The package is unsigned.

Extract the entire Windows ZIP, close the game and run `Instalar.cmd`. Open the game through Steam, then share **Rocksmith 2014 with sound** in Discord. See README.md or README.pt-BR.md for details.
