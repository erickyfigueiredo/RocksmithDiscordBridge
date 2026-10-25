"""Build a distributable from an explicit file list; never ship local settings/logs."""
from pathlib import Path
import argparse
import hashlib
import json
import shutil
import zipfile

ROOT = Path(__file__).resolve().parents[1]
PUBLIC_FILES = (
    'README.md', 'README.pt-BR.md', 'PRIVACY.md', 'LICENSE', 'THIRD_PARTY_NOTICES.md',
    'Install.ps1', 'Restore.ps1', 'Instalar.cmd', 'Configurar-audio.cmd', 'tools/FindGame.ps1',
)
PRIVATE_NAMES = {'settings.json', 'diagnostics.json', 'bridge.log', 'RSBridgePlayer.txt'}


def package(player, output):
    player = Path(player).resolve()
    output = Path(output).resolve()
    required = [ROOT / name for name in PUBLIC_FILES] + [ROOT / 'bin/RS_ASIO.dll', player / 'RocksmithStreamBridge.exe', player / '_internal']
    for file in required:
        if not file.exists():
            raise FileNotFoundError(file)
    output.mkdir(parents=True, exist_ok=True)
    archive = output / 'RocksmithDiscordBridge-Windows-x64.zip'
    manifest = {}
    files = [(ROOT / name, name) for name in PUBLIC_FILES]
    files.append((ROOT / 'bin/RS_ASIO.dll', 'bin/RS_ASIO.dll'))
    # Only the executable and its runtime are public. No recursively copied user files.
    files.append((player / 'RocksmithStreamBridge.exe', 'player/RocksmithStreamBridge.exe'))
    files.extend((file, 'player/' + file.relative_to(player).as_posix()) for file in sorted((player / '_internal').rglob('*')) if file.is_file())
    licenses = ROOT / 'licenses'
    if licenses.exists():
        files.extend((file, file.relative_to(ROOT).as_posix()) for file in sorted(licenses.rglob('*')) if file.is_file())
    with zipfile.ZipFile(archive, 'w', zipfile.ZIP_DEFLATED, compresslevel=6) as zip_file:
        for file, name in files:
            if file.name in PRIVATE_NAMES or file.suffix == '.log' or '__pycache__' in file.parts:
                raise ValueError(f'Private/runtime-generated file in package: {name}')
            manifest[name] = hashlib.sha256(file.read_bytes()).hexdigest()
            zip_file.write(file, 'RocksmithDiscordBridge/' + name)
        zip_file.writestr('RocksmithDiscordBridge/SHA256.json', json.dumps(manifest, indent=2) + '\n')
    checksum = hashlib.sha256(archive.read_bytes()).hexdigest()
    (output / 'SHA256SUMS.txt').write_text(f'{checksum}  {archive.name}\n', encoding='utf-8')
    return archive


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--player', default=str(ROOT / 'dist/RocksmithStreamBridge'))
    parser.add_argument('--output', default=str(ROOT / 'release'))
    arguments = parser.parse_args()
    print(package(arguments.player, arguments.output))
