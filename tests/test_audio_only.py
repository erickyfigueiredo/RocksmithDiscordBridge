import json
from pathlib import Path
import sys
import tempfile
import unittest
import tkinter as tk
from unittest.mock import patch
import app


class HeadlessPlayerTests(unittest.TestCase):
    def test_parent_pid_output_and_exit_without_creating_a_window(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            (root / 'settings.json').write_text(json.dumps({'output': 'Test headphones'}))

            def audio(runner, device):
                self.assertEqual(device, 22)
                self.assertEqual(runner.parent_pid, 1234)
                runner.audio_blocks = 12
                runner.messages.put(('connected', 'Connected'))
                runner.messages.put(('done', None))

            with patch.object(app, 'DATA_DIR', root), patch.object(app, 'output_devices', return_value=[(22, 'Test headphones')]), patch.object(app.AudioReceiver, 'audio_worker', audio), patch.object(tk, 'Tk', side_effect=AssertionError('Headless player created a window')), patch.object(sys, 'argv', ['app.py', '--audio-only', '--parent-pid', '1234']):
                app.run_audio_only()
            result = json.loads((root / 'diagnostics.json').read_text(encoding='utf-8'))
            self.assertTrue(result['audio_only'])
            self.assertFalse(result['audio_connected'])
            self.assertEqual(result['parent_pid'], 1234)
            self.assertEqual(result['audio_blocks'], 12)

    def test_output_selection_rejects_missing_device_without_overwriting_settings(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            settings = root / 'settings.json'
            settings.write_text('{"output":"Original"}')
            with patch.object(app, 'DATA_DIR', root), patch.object(app, 'output_devices', return_value=[(1, 'Available')]):
                with self.assertRaises(ValueError):
                    app.save_output('Disconnected')
                self.assertEqual(json.loads(settings.read_text())['output'], 'Original')
                app.save_output('Available')
                self.assertEqual(json.loads(settings.read_text())['output'], 'Available')
