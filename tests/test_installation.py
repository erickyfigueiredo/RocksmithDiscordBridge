import json
from pathlib import Path
import struct
import tempfile
import unittest
from unittest.mock import patch
from bridge import installation as setup


class InstallationTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.game = self.root / 'Game with spaces'
        self.package = self.root / 'Installed app'
        self.state = self.root / 'state/installation.json'
        self.game.mkdir()
        (self.package / 'bin').mkdir(parents=True)
        (self.package / 'player').mkdir()
        (self.package / 'config').mkdir()
        pe = bytearray(512)
        pe[:2] = b'MZ'
        struct.pack_into('<I', pe, 0x3c, 128)
        pe[128:132] = b'PE\0\0'
        struct.pack_into('<H', pe, 132, 0x14c)
        (self.package / 'bin/RS_ASIO.dll').write_bytes(pe)
        (self.package / 'bin/avrt.dll').write_bytes(b'wrapper')
        (self.package / 'player/RocksmithStreamBridge.exe').write_bytes(b'fixture')
        (self.package / 'config/RS_ASIO.ini').write_bytes((Path(__file__).resolve().parents[1] / 'config/RS_ASIO.ini').read_bytes())
        (self.game / 'Rocksmith2014.exe').write_bytes(b'game fixture')
        self.audio = '[Audio]\nExclusiveMode=0\nWin32UltraLowLatencyMode=0\nLatencyBuffer=4\n[Renderer.Win32]\nFullscreen=2\n'
        (self.game / 'Rocksmith.ini').write_text(self.audio)
        self.closed = patch.object(setup, 'game_pids', return_value=[])
        self.closed.start()
        self.addCleanup(self.closed.stop)

    def install(self, **kwargs):
        return setup.install(self.game, self.package, self.state, **kwargs)

    def test_fresh_rsasio_install_and_restore_preserves_video_and_removes_new_files(self):
        self.install(initialize=True, driver='Example ASIO', channel=3)
        text = (self.game / 'RS_ASIO.ini').read_text()
        self.assertIn('Driver=Example ASIO', text)
        self.assertIn('Channel=3', text)
        self.assertIn('[Renderer.Win32]\nFullscreen=2', (self.game / 'Rocksmith.ini').read_text())
        self.assertEqual((self.game / 'RSBridgePlayer.txt').read_bytes().decode('utf-16-le'), str(self.package / 'player/RocksmithStreamBridge.exe'))
        setup.restore(self.state)
        self.assertFalse((self.game / 'RS_ASIO.dll').exists())
        self.assertFalse((self.game / 'avrt.dll').exists())
        self.assertFalse((self.game / 'RS_ASIO.ini').exists())
        self.assertEqual((self.game / 'Rocksmith.ini').read_text(), self.audio)

    def test_existing_config_and_wrapper_preserved_across_upgrade_and_restore(self):
        (self.game / 'RS_ASIO.ini').write_bytes(b'custom channels and buffers')
        (self.game / 'avrt.dll').write_bytes(b'original wrapper')
        (self.game / 'RS_ASIO.dll').write_bytes(b'original rsasio')
        self.install()
        self.install()
        self.assertEqual((self.game / 'RS_ASIO.ini').read_bytes(), b'custom channels and buffers')
        setup.restore(self.state)
        self.assertEqual((self.game / 'RS_ASIO.dll').read_bytes(), b'original rsasio')
        self.assertEqual((self.game / 'avrt.dll').read_bytes(), b'original wrapper')

    def test_restore_keeps_later_user_changes(self):
        self.install(initialize=True, driver='Example ASIO')
        (self.game / 'RS_ASIO.ini').write_bytes(b'later user configuration')
        self.assertIn('RS_ASIO.ini', setup.restore(self.state))
        self.assertEqual((self.game / 'RS_ASIO.ini').read_bytes(), b'later user configuration')

    def test_missing_original_backup_aborts_before_any_restore(self):
        (self.game / 'RS_ASIO.dll').write_bytes(b'original')
        self.install(initialize=True, driver='Example ASIO')
        state = json.loads(self.state.read_text())
        Path(state['files']['RS_ASIO.dll']['original']).unlink()
        before = (self.game / 'RS_ASIO.dll').read_bytes()
        with self.assertRaises(FileNotFoundError): setup.restore(self.state)
        self.assertEqual((self.game / 'RS_ASIO.dll').read_bytes(), before)

    def test_write_failure_rolls_back_game_transaction(self):
        original = Path.write_bytes
        def failing(path, data):
            if path == self.game / 'RSBridgePlayer.txt': raise OSError('simulated write failure')
            return original(path, data)
        with patch.object(Path, 'write_bytes', failing):
            with self.assertRaises(OSError): self.install(initialize=True, driver='Example ASIO')
        self.assertFalse((self.game / 'RS_ASIO.dll').exists())
        self.assertFalse(self.state.exists())

    def test_game_running_and_missing_dependencies_block_install(self):
        with patch.object(setup, 'game_pids', return_value=[123]):
            with self.assertRaises(RuntimeError): self.install(initialize=True, driver='Example ASIO')
        with self.assertRaises(ValueError): self.install()
        self.assertFalse((self.game / 'RS_ASIO.dll').exists())
