import unittest
import json
from pathlib import Path
import tempfile
import tkinter as tk
from tkinter import ttk
from unittest.mock import patch

from bridge.setup_ui import AudioProbe, TEXT, run_setup


class SetupTests(unittest.TestCase):
    def test_translations_have_same_keys(self):
        self.assertEqual(TEXT['pt'].keys(), TEXT['en'].keys())

    def test_process_alive_and_static_blocks_do_not_pass(self):
        probe = AudioProbe()
        data = dict(parent_pid=10, audio_connected=True, audio_blocks=100, audio_peak=0.1)
        self.assertEqual(probe.sample(data, [10], True, 1), 'waiting_bridge')
        self.assertEqual(probe.sample(data, [10], True, 5), 'no_audio')
        self.assertFalse(probe.received)

    def test_fresh_audio_must_advance_and_match_game(self):
        probe = AudioProbe()
        data = dict(parent_pid=10, audio_connected=True, audio_blocks=1, audio_peak=0.1)
        self.assertEqual(probe.sample(data, [20], True, 1), 'waiting_bridge')
        self.assertEqual(probe.sample(data, [10], False, 1), 'waiting_bridge')
        probe.sample(data, [10], True, 2)
        data['audio_blocks'] += 1
        self.assertEqual(probe.sample(data, [10], True, 3), 'receiving')
        self.assertTrue(probe.signal)
        self.assertEqual(probe.sample(data, [], True, 4), 'closed')
        self.assertEqual(probe.sample(data, [10], True, 7), 'no_audio')

    def test_restart_resets_previous_pass(self):
        probe = AudioProbe()
        probe.sample(dict(parent_pid=10, audio_connected=True, audio_blocks=1), [10], True, 1)
        probe.sample(dict(parent_pid=10, audio_connected=True, audio_blocks=2, audio_peak=0.2), [10], True, 2)
        self.assertTrue(probe.signal)
        self.assertEqual(probe.sample(dict(parent_pid=11, audio_connected=True, audio_blocks=500), [11], True, 3), 'waiting_bridge')
        self.assertFalse(probe.signal)

    def test_changing_output_does_not_validate_previous_device(self):
        probe = AudioProbe()
        data = dict(parent_pid=10, output='Old output', audio_connected=True, audio_blocks=100, audio_peak=0.2)
        self.assertEqual(probe.sample(data, [10], True, 1, 'New headphones'), 'restart_output')
        self.assertFalse(probe.signal)

    def test_recent_audio_measurement_survives_returning_from_game(self):
        probe = AudioProbe()
        data = dict(parent_pid=10, audio_connected=True, audio_blocks=0, audio_peak=0.2)
        probe.sample(data, [10], True, 0)
        for second in range(1, 7):
            data['audio_blocks'] += 100
            state = probe.sample(data, [10], True, second)
        self.assertTrue(probe.can_confirm(state, 6))
        state = probe.sample(data, [10], True, 10)
        self.assertEqual(state, 'no_audio')
        self.assertTrue(probe.can_confirm(state, 10))
        self.assertFalse(probe.can_confirm(state, 40))
        self.assertFalse(probe.can_confirm('closed', 10))

    def test_brief_startup_audio_is_not_a_completed_measurement(self):
        probe = AudioProbe()
        data = dict(parent_pid=10, audio_connected=True, audio_blocks=100, audio_peak=0.2)
        probe.sample(data, [10], True, 0)
        data['audio_blocks'] += 10
        state = probe.sample(data, [10], True, 1)
        self.assertFalse(probe.can_confirm(state, 1))
        self.assertFalse(probe.can_confirm(probe.sample(data, [10], True, 10), 10))

    def test_both_languages_can_select_output_and_run_test_without_touching_game(self):
        real_tk = tk.Tk
        for language in TEXT:
            with self.subTest(language=language), tempfile.TemporaryDirectory() as directory:
                saved = []
                errors = []
                def create_root():
                    root = real_tk()
                    root.withdraw()
                    def children(widget):
                        return [child for item in widget.winfo_children() for child in [item, *children(item)]]
                    def exercise():
                        try:
                            button = next(item for item in children(root) if isinstance(item, ttk.Button) and item.cget('text') == TEXT[language]['next'])
                            button.invoke()
                            box = next(item for item in children(root) if isinstance(item, ttk.Combobox) and 'Example headphones' in item.cget('values'))
                            self.assertEqual(box.get(), '')
                            box.set('Example headphones')
                            button.invoke()
                            root.update_idletasks()
                            self.assertIn(TEXT[language]['waiting_game'], [item.cget('text') for item in children(root) if isinstance(item, ttk.Label)])
                            self.assertEqual(saved, ['Example headphones'])
                        except Exception as exc:
                            errors.append(exc)
                        finally:
                            root.destroy()
                    root.after(20, exercise)
                    return root
                with patch('bridge.setup_ui.tk.Tk', create_root), patch('bridge.setup_ui.system_language', return_value=language), patch('bridge.setup_ui.game_configuration', return_value=(None, 'ASIO4ALL v2')):
                    run_setup(Path(directory), lambda: [(1, 'Example headphones')], saved.append, lambda: [])
                if errors:
                    raise errors[0]


if __name__ == '__main__':
    unittest.main()
