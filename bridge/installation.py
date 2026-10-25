"""Transactional game integration used by the GUI installer; no shell commands."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import re
import shutil
import struct
import uuid

from bridge.winprocess import game_pids


def digest(data):
    return hashlib.sha256(data).hexdigest()


def ini_set(text, section, key, value):
    pattern = re.compile(r'(?ims)^\[' + re.escape(section) + r'\][^\r\n]*\r?\n(?:(?!^\[).)*')
    match = pattern.search(text)
    if not match:
        return text.rstrip() + f'\n[{section}]\n{key}={value}\n'
    block = match.group()
    key_pattern = re.compile(r'(?im)^' + re.escape(key) + r'=[^\r\n]*')
    replacement = f'{key}={value}'
    block = key_pattern.sub(lambda _: replacement, block) if key_pattern.search(block) else block.rstrip() + '\n' + replacement + '\n'
    return text[:match.start()] + block + text[match.end():]


def validate_dll(path):
    data = path.read_bytes()
    if len(data) < 256 or data[:2] != b'MZ':
        raise ValueError('Invalid RS_ASIO DLL')
    offset = struct.unpack_from('<I', data, 0x3c)[0]
    if offset + 24 > len(data) or data[offset:offset+4] != b'PE\0\0' or struct.unpack_from('<H', data, offset+4)[0] != 0x14c:
        raise ValueError('RS_ASIO must be an x86 DLL')


def require_game_closed():
    if game_pids():
        raise RuntimeError('Close Rocksmith 2014 before continuing / Feche o Rocksmith antes de continuar.')


def install(game, package, state_file, initialize=False, driver='', channel=0):
    require_game_closed()
    game, package, state_file = Path(game).resolve(), Path(package).resolve(), Path(state_file).resolve()
    if not (game / 'Rocksmith2014.exe').is_file() or not (game / 'Rocksmith.ini').is_file():
        raise ValueError('Select the game folder and run Rocksmith once before installing.')
    player = package / 'player/RocksmithStreamBridge.exe'
    if not player.is_file() or len(str(player)) >= 260:
        raise ValueError('Player missing, or installation path is too long.')
    validate_dll(package / 'bin/RS_ASIO.dll')
    payload = {
        'RS_ASIO.dll': (package / 'bin/RS_ASIO.dll').read_bytes(),
        'RSBridgePlayer.txt': str(player).encode('utf-16-le'),
    }
    missing_base = not (game / 'avrt.dll').is_file() or not (game / 'RS_ASIO.ini').is_file()
    if missing_base and not initialize:
        raise ValueError('RS_ASIO support is missing. Select its installation in the wizard.')
    if initialize:
        if not (game / 'avrt.dll').exists():
            payload['avrt.dll'] = (package / 'bin/avrt.dll').read_bytes()
        if not (game / 'RS_ASIO.ini').exists():
            if not driver or any(c in driver for c in '\r\n[]=') or not 0 <= channel <= 63:
                raise ValueError('Choose an ASIO driver and an input channel between 0 and 63.')
            text = (package / 'config/RS_ASIO.ini').read_text(encoding='utf-8-sig')
            text = ini_set(text, 'Asio.Output', 'Driver', driver)
            text = ini_set(text, 'Asio.Input.0', 'Driver', driver)
            text = ini_set(text, 'Asio.Input.0', 'Channel', str(channel))
            payload['RS_ASIO.ini'] = text.encode('utf-8')
            audio = (game / 'Rocksmith.ini').read_text(encoding='utf-8-sig')
            for key in ('ExclusiveMode', 'Win32UltraLowLatencyMode'):
                audio = ini_set(audio, 'Audio', key, '1')
            payload['Rocksmith.ini'] = audio.encode('utf-8')
    old = json.loads(state_file.read_text(encoding='utf-8')) if state_file.exists() else None
    if old and old.get('active') and Path(old['game']).resolve() != game:
        raise ValueError('Uninstall the previous game integration before choosing another game folder.')
    backup = state_file.parent / 'backups' / uuid.uuid4().hex
    backup.mkdir(parents=True)
    records = dict(old['files']) if old and old.get('active') else {}
    before = {name: (game / name).read_bytes() if (game / name).exists() else None for name in payload}
    for name, content in before.items():
        if name not in records:
            saved = backup / name
            if content is not None:
                saved.write_bytes(content)
            records[name] = {'original': str(saved) if content is not None else None}
    changed = []
    try:
        for name, content in payload.items():
            changed.append(name)
            (game / name).write_bytes(content)
            records[name]['installed_sha256'] = digest(content)
        state = {'version': 1, 'active': True, 'game': str(game), 'files': records}
        temporary = state_file.with_suffix('.tmp')
        temporary.write_text(json.dumps(state, indent=2), encoding='utf-8')
        os.replace(temporary, state_file)
    except Exception:
        for name in reversed(changed):
            if before[name] is None:
                (game / name).unlink(missing_ok=True)
            else:
                (game / name).write_bytes(before[name])
        raise
    return 'Game integration installed. Configure your audio output, then open the game through Steam.'


def restore(state_file):
    require_game_closed()
    state_file = Path(state_file)
    if not state_file.exists():
        return 'No game integration to restore.'
    state = json.loads(state_file.read_text(encoding='utf-8'))
    if not state.get('active'):
        return 'Game integration already restored.'
    game = Path(state['game']).resolve()
    retained = []
    # Validate the complete restore plan before touching the game.
    for name, record in state['files'].items():
        if Path(name).name != name or name not in {'RS_ASIO.dll', 'avrt.dll', 'RS_ASIO.ini', 'Rocksmith.ini', 'RSBridgePlayer.txt'}:
            raise ValueError('Invalid backup manifest')
        if record['original'] and not Path(record['original']).is_file():
            raise FileNotFoundError('Original backup missing; game files were left untouched.')
    for name, record in state['files'].items():
        current = game / name
        if current.exists() and digest(current.read_bytes()) != record['installed_sha256']:
            retained.append(name)
            continue
        if record['original']:
            shutil.copyfile(record['original'], current)
        else:
            current.unlink(missing_ok=True)
    state['active'] = False
    state_file.write_text(json.dumps(state, indent=2), encoding='utf-8')
    return 'Previous game files restored.' + (' Kept files changed after installation: ' + ', '.join(retained) if retained else '')


def main(argv):
    parser = argparse.ArgumentParser()
    parser.add_argument('--setup-install', action='store_true')
    parser.add_argument('--setup-uninstall', action='store_true')
    parser.add_argument('--game-directory')
    parser.add_argument('--package')
    parser.add_argument('--state-file', required=True)
    parser.add_argument('--initialize-asio', action='store_true')
    parser.add_argument('--driver', default='')
    parser.add_argument('--input-channel', type=int, default=0)
    parser.add_argument('--report', required=True)
    args = parser.parse_args(argv)
    try:
        if args.setup_install:
            message = install(args.game_directory, args.package, args.state_file, args.initialize_asio, args.driver, args.input_channel)
        else:
            message = restore(args.state_file)
        code = 0
    except Exception as exc:
        message, code = str(exc), 1
    Path(args.report).write_text(message, encoding='utf-8')
    return code
