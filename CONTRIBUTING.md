# Contributing

## Build on Windows

Install Python 3.12 x64, Node.js 22, Visual Studio Build Tools 2022 with MSVC v143 (x86/x64), a Windows 10/11 SDK, and Inno Setup 6.7.3 or newer.

```powershell
python -m venv .venv
.\.venv\Scripts\python.exe -m pip install -r requirements.txt
powershell -NoProfile -ExecutionPolicy Bypass -File .\Build.ps1
node --test tests/patch.test.mjs
powershell -NoProfile -ExecutionPolicy Bypass -File .\tests\FindGame.Tests.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File .\tests\Install.Tests.ps1
.\.venv\Scripts\python.exe -m unittest discover -s tests -v
.\.venv\Scripts\python.exe -m pip install 'pyinstaller>=6,<7'
.\.venv\Scripts\python.exe -m PyInstaller --noconfirm RocksmithStreamBridge.spec
.\.venv\Scripts\python.exe tools/collect_licenses.py
.\.venv\Scripts\python.exe tools/package_release.py
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\BuildInstaller.ps1
```

`Build.ps1` downloads the fixed RS_ASIO v0.7.4 release, patches a clean source tree and builds the DLL x86. The player is x64. Native and Python tests verify the shared-memory protocol across those architectures. The installer tests use isolated dummy files, never the actual game.

GitHub Actions also compiles the Inno Setup installer and tests actual installation/uninstallation against a synthetic game folder. It generates Setup.exe and a portable ZIP with SHA256 checksums. Successful main-branch builds publish an **experimental prerelease**, with a unique preview tag for that build, on the repository's Releases page. Pull-request and manually dispatched builds do not publish releases.

## Architecture

`native/BridgeTap.h` copies the final game audio, after software volume, into a bounded shared-memory ring. ASIO never waits for a reader. `native/BridgePlayer.h` optionally launches one windowless player from the game, during output initialization rather than the callback. A UTF-16LE configuration file in the game's directory enables that launch. `app.py --audio-only --parent-pid PID` receives only that parent's audio and exits when the game closes. `--configure-output` selects the WASAPI output without opening the game.

The existing diagnostic video UI remains available by running `app.py` without arguments, but is not used for direct game streaming. Avoid adding blocking operations, allocation or process creation to the ASIO callback.

## Reports

Include Windows/Discord versions, game/RS_ASIO versions, ASIO driver, guitar interface, selected WASAPI output and the exact symptom. Say whether the original game sound works, whether copied audio works locally and whether the remote viewer gets video and audio. Keep personal paths and identifiers out of public logs.

The first release has been tested on one hardware setup. Changes to device selection, process launch, installation/rollback, PCM decoding or synchronization need focused tests. UI-only changes usually need a manual visual check.
