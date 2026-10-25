# Contributing

## Build on Windows

Required tools: Python 3.12 x64, Node.js 22, Visual Studio Build Tools 2022 with MSVC v143 x86/x64, Windows SDK, and Inno Setup 6.7.3 or newer.

```powershell
python -m venv .venv
.\.venv\Scripts\Activate.ps1
python -m pip install -r requirements.txt
./Build.ps1
node --test tests/patch.test.mjs
./tests/Signing.Tests.ps1
python -m unittest discover -s tests -v
python -m pip install 'pyinstaller>=6,<7'
python -m PyInstaller --noconfirm RocksmithStreamBridge.spec
python tools/collect_licenses.py
./tools/BuildInstaller.ps1
```

`Build.ps1` downloads RS_ASIO v0.7.4, applies the patch and builds x86 DLLs and native tests. The Python player is x64. The installer is generated under `release/`. See [publisher signing](docs/signing.md) for signed builds.

GitHub Actions runs native/Python tests and installs, reinstalls and uninstalls Setup against a synthetic game folder. Successful main-branch builds publish installers and SHA256 checksums. The two most recent published previews are retained; older previews and abandoned preview drafts are removed. Stable releases and Git tags are retained. Documentation-only pushes do not publish installers.

Stable releases are promoted through **Publish stable release** in Actions: select the tested preview, matching version and reviewed SHA256. The workflow copies and verifies the existing installer, publishes `vX.Y.Z` as Latest and refuses to overwrite an existing stable release. Stable releases are excluded from preview cleanup.

## Architecture

- `native/BridgeTap.h`: bounded shared-memory audio ring; ASIO never waits for a reader.
- `native/BridgePlayer.h`: launches the player during output initialization.
- `app.py`: WASAPI playback and application entry point.
- `bridge/setup_ui.py`: bilingual setup and diagnostics.
- `bridge/installation.py`: transactional integration and restore.
- `installer/BridgeSetup.iss`: wizard and dependency downloads.

`--audio-only --parent-pid PID` reads that game's audio. Without arguments, or with `--configure-output`, the application opens guided setup. `--set-output NAME` is available for command-line tests.

Changes to audio, process launch and installation require focused regression tests. Keep blocking work and allocation out of the ASIO callback. Check UI changes in both languages.

## Reports

Include Windows/Discord versions, game version, ASIO driver and reproduction steps. Distinguish game audio, local playback and what the viewer receives. Review logs for personal device names and paths before attaching them.
