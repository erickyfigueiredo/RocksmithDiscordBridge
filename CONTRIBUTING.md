# Contributing

## Build on Windows

Install Python 3.12 x64, Node.js 22, Visual Studio Build Tools 2022 with MSVC v143 (x86/x64), and a Windows 10/11 SDK.

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
```

`Build.ps1` downloads the fixed RS_ASIO v0.7.4 release, patches a clean source tree and builds the DLL x86. The player is x64. Native and Python tests verify the shared-memory protocol across those architectures. The installer tests use isolated dummy files, never the actual game.

GitHub Actions runs those checks and generates a ZIP with a SHA256 checksum. Successful main-branch builds create a **draft prerelease**; review the workflow results and publish that draft from the repository's Releases page. Drafts are not visible to regular visitors. Pull-request builds do not publish releases.

## Architecture

`native/BridgeTap.h` copies the final game audio, after software volume, into a bounded shared-memory ring. ASIO never waits for a reader. `native/BridgePlayer.h` optionally launches one windowless player from the game, during output initialization rather than the callback. A UTF-16LE configuration file in the game's directory enables that launch. `app.py --audio-only --parent-pid PID` receives only that parent's audio and exits when the game closes. `--configure-output` selects the WASAPI output without opening the game.

The existing diagnostic video UI remains available by running `app.py` without arguments, but is not used for direct game streaming. Avoid adding blocking operations, allocation or process creation to the ASIO callback.

## Reports

Include Windows/Discord versions, game/RS_ASIO versions, ASIO driver, guitar interface, selected WASAPI output and the exact symptom. Say whether the original game sound works, whether copied audio works locally and whether the remote viewer gets video and audio. Keep personal paths and identifiers out of public logs.

The first release has been tested on one hardware setup. Changes to device selection, process launch, installation/rollback, PCM decoding or synchronization need focused tests. UI-only changes usually need a manual visual check.
