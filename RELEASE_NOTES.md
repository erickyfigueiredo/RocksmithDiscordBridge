Experimental Windows preview 0.2.0: graphical installation with Inno Setup.

- Download **RocksmithDiscordBridge-Setup-x64.exe** for the normal installation flow. No PowerShell/CMD is invoked by setup, audio configuration or uninstall.
- Review prerequisites in the wizard and DEPENDENCIES.md. Python and app libraries are bundled.
- Install missing RS_ASIO support from included files and select the initial ASIO driver/channel if needed.
- Optionally download/install ASIO4ALL or Microsoft runtime repairs, only after selecting them, with fixed SHA256 verification and their normal graphical installers.
- Configure audio through the Start menu. Settings/diagnostics are stored per user under LocalAppData.
- Uninstall through Windows Settings to restore previous game files; later user modifications are retained.
- Share **Rocksmith 2014 itself with sound** in Discord, preserving the original game image.

Requires Windows 10/11 x64, Steam's Rocksmith 2014 Remastered, Discord desktop, an appropriate 32-bit ASIO driver and an available stereo Windows output. First-time ASIO users must check interface devices/channels and 48 kHz. Copied audio requests a 60 ms playback buffer. This community preview is unsigned and broader hardware compatibility remains experimental.

The portable ZIP is retained for advanced users. Source code, installer script, tests and build automation are available in the repository. No game files, local machine settings, logs or credentials are included.
