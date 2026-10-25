# Rocksmith Discord Bridge

Stream **Rocksmith 2014 with ASIO audio in Discord**, using the original game window.

[Português](README.pt-BR.md) · [Download stable Setup](https://github.com/erickyfigueiredo/RocksmithDiscordBridge/releases/latest/download/RocksmithDiscordBridge-Setup-x64.exe) · [Dependencies](docs/dependencies.md)

## Requirements

- Windows 10/11 x64, Steam's Rocksmith 2014 Remastered and Discord desktop.
- A guitar interface with a 32-bit ASIO driver, or ASIO4ALL.
- A stereo Windows audio output for your headphones or speakers.

RS_ASIO, Python and the application libraries are included. **RSMods is optional.**

## Installation

1. Run Rocksmith once, then close it.
2. Download **RocksmithDiscordBridge-Setup-x64.exe** from Releases and open it.
3. Choose **USB interface — guided setup**, or your manufacturer's driver under **Advanced**. Review the components and select your guitar input.
4. Follow **Guitar → Headphones → Test**. In ASIO4ALL, enable your interface's input and output. Choose your headphones in the next step.
5. Open the game and play a few notes. After confirming the sound, share **Rocksmith 2014 with sound** in Discord.

Setup supports English and Portuguese. It preserves existing audio/video configuration and backs up game files before changing them. Reinstall in the same folder to update. Close the game before installing or uninstalling.

The installer is **unsigned** and may show a Windows SmartScreen warning. See [Windows warnings](docs/signing.md#windows-warnings). Checksums are available with each release.

## How it works

The RS_ASIO patch copies game audio to a windowless player launched by Rocksmith. Discord captures that child process's audio along with the game. Video comes directly from the game window. See [Discord's capture design](https://discord.com/blog/how-it-all-goes-live-an-overview-of-discords-streaming-technology).

The audio copy requests a 60 ms playback buffer and can add playing latency. Supported audio is stereo 48 kHz. Viewer quality depends on Discord settings and the connection; a minimized game may pause capture.

## Help and development

- [Dependencies and device setup](docs/dependencies.md)
- [Troubleshooting and uninstall](docs/troubleshooting.md)
- [Privacy and local files](docs/privacy.md)
- [Build and contribution guide](CONTRIBUTING.md)
- [Build status](https://github.com/erickyfigueiredo/RocksmithDiscordBridge/actions)

Community project, unaffiliated with Ubisoft or Discord. Licensed under [MIT](LICENSE), with [third-party notices](THIRD_PARTY_NOTICES.md). RS_ASIO is by [Micael Dias](https://github.com/mdias/rs_asio).
