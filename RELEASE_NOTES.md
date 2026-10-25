Experimental Windows preview 0.3.0: guided audio setup in Portuguese and English.

- Follow Guitar → Headphones → Test, with a language selector.
- The USB path selects ASIO4ALL instead of silently choosing the first registered driver. Choose the USB interface in its own device panel.
- Guitar inputs use physical numbering (1, 2…), translated to zero-based channels internally.
- Manufacturer drivers and optional Microsoft runtime repairs remain available through advanced choices.
- The test requires fresh, advancing audio packets and a sound signal. A live/frozen game process alone cannot pass. Confirm hearing the game and guitar yourself; a Discord viewer must still validate remote sound and picture.
- Existing ASIO settings and the original uninstall backups are preserved on reinstall. Other game mods are never disabled automatically.

Download RocksmithDiscordBridge-Setup-x64.exe. Python and app libraries are included. ASIO4ALL is selected for download only after choosing the USB path when it is missing; review components before installing. See DEPENDENCIES.md for requirements. No PowerShell/CMD in the normal flow.

Windows 10/11 x64, Steam Rocksmith 2014, Discord desktop, a suitable ASIO driver and stereo Windows output are required. Unsigned experimental community preview. The copied audio requests a 60 ms buffer; total playing latency is not measured.