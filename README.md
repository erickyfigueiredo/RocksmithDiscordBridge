# Rocksmith Discord Bridge

Share **Rocksmith 2014 itself in Discord with its ASIO audio**, preserving the game's original image.

[Português](README.pt-BR.md) · [Download installer](https://github.com/erickyfigueiredo/RocksmithDiscordBridge/releases) · [Dependencies](DEPENDENCIES.md) · [Builds/tests](https://github.com/erickyfigueiredo/RocksmithDiscordBridge/actions)

The mod copies final game audio into a windowless player launched as a child of Rocksmith. Discord captures audio from the shared app and its child processes. Video is captured directly from the game, without a reduced preview or always-on-top window. See [Discord's process-capture description](https://discord.com/blog/how-it-all-goes-live-an-overview-of-discords-streaming-technology).

## Requirements — read before installing

- **Windows 10/11 x64**, Steam's Rocksmith 2014 Remastered and Discord desktop. Run the game once before installing. The wizard does not purchase/install the game or Discord.
- A **32-bit ASIO driver** for your guitar interface. Prefer its manufacturer's driver. The wizard detects registered drivers and offers **optional ASIO4ALL installation** as a fallback.
- **RS_ASIO 0.7.4:** its support files are included. The wizard can install missing files and create an initial driver/channel configuration; it preserves existing configuration.
- An available stereo Windows WASAPI output for the copied sound.
- **Python and app libraries are already included.** You do not need Python, Node.js, OBS, Voicemeeter or developer tools.

**RSMods is optional.** The app works without it. The required RS_ASIO support is already included in Setup.

Read [DEPENDENCIES.md](DEPENDENCIES.md) for required software, bundled components and downloads. Version 0.3.1 is an experimental preview. End-to-end streaming has been confirmed on one Windows setup; wider hardware coverage needs testing.

## Graphical installation

1. Download **RocksmithDiscordBridge-Setup-x64.exe** from Releases. Close Rocksmith and open Setup.exe.
2. Choose **USB interface — guided setup**, or your manufacturer's driver in **Advanced**. Review components and select the physical guitar input **1, 2…**.
3. Follow **Guitar → Headphones → Test**. For USB, open the ASIO4ALL panel and enable only your interface's input and output. Its device name appears there, not necessarily in the ASIO driver list.
4. Choose your headphones, open the game and play a few notes. The wizard checks fresh audio packets and sound signal; confirm that you hear the game and guitar. Switch between English and Portuguese in the window.
5. Open the game normally through Steam. In Discord, share **Rocksmith 2014 with sound**, at your desired resolution/frame rate.

The primary setup/configuration/uninstall flow never invokes PowerShell or CMD. ASIO4ALL opens its own graphical setup/license. Optional Microsoft runtime repairs show their normal progress UI. Dependency downloads use fixed SHA256 checks. If a dependency requests a restart, the wizard reports it without forcing an immediate reboot.

Setup requests administrator rights to update game files. It backs up originals and preserves existing ASIO/video settings. A first-time ASIO setup enables the two RS_ASIO audio settings without changing video. No game files, audio drivers or proprietary Microsoft runtime installers are redistributed inside the package; optional third-party installers are downloaded from official sources after selection.

The portable ZIP is an alternative for advanced users with an existing working RS_ASIO setup. Its legacy scripts are separate from Setup.exe. The GitHub Source code ZIP contains source, not built executables.

The current installer has no digital publisher signature. A Windows “unrecognized app” message is a SmartScreen reputation warning, not by itself a named malware detection. Check the download source and published checksums. See [signing and Windows warnings](SIGNING.md).

## Uninstall and local data

Close the game and uninstall **Rocksmith Discord Bridge** through Windows Settings. The uninstaller restores backed-up game files. Files modified afterward by the user are retained; backups remain under ProgramData. Shared ASIO drivers and Microsoft runtimes are not removed.

Settings and diagnostics live in `%LOCALAPPDATA%\RocksmithDiscordBridge`. Game-integration backups/state live in `%PROGRAMDATA%\RocksmithDiscordBridge`. The app does not upload them. See [PRIVACY.md](PRIVACY.md).

For an older portable-script installation, use its Restore.ps1 with the backup folder printed by that script.

## Limits and troubleshooting

- The copied audio requests a 60 ms playback buffer. Listening through it can add noticeable playing latency; total latency has not been measured. The original ASIO output does not wait for the player. Avoid hearing both paths at once.
- An output opened exclusively by an ASIO driver may not be available for shared WASAPI playback. Choose another output if necessary.
- For no copied sound, close the game, use Configure audio, then reopen it. Check the selected device and local bridge.log.
- Share the **original game**, not the diagnostic player window. A minimized game can stop rendering/producing audio.
- Viewer quality still depends on Discord's selected resolution/frame rate, account features, encoding and connection.
- The tap supports stereo 48 kHz PCM16/24/32 and float32. Other formats are rejected.
- This is an unsigned experimental community mod, unaffiliated with Ubisoft or Discord. Compatibility with other game/RS_ASIO patches is not guaranteed.
- If the game closes, test other game mods separately. The audio wizard reports their presence after a game closes; it does not disable them. The local test cannot verify the viewer's Discord picture/sound.

## Source, builds and credits

The repository contains the source, installer script, tests and CI; binary downloads are published separately in Releases. See [CONTRIBUTING.md](CONTRIBUTING.md) to build. CI compiles and tests the DLL/player, builds Setup.exe and tests actual installation/uninstallation against an isolated game fixture.

New code: [MIT](LICENSE). RS_ASIO: [mdias/rs_asio](https://github.com/mdias/rs_asio), MIT, Micael Dias. See [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md) for bundled components.
