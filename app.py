"""Rocksmith audio player and guided setup."""
import json
import logging
import os
from pathlib import Path
import platform
import queue
import sys
import threading
import time

import numpy as np
import sounddevice as sd

from bridge.protocol import Mapping, RingReader
from bridge.pcm import decode
from bridge.winprocess import game_pids

ROOT = Path(sys.executable).resolve().parent if getattr(sys, 'frozen', False) else Path(__file__).resolve().parent
DATA_DIR = (Path(os.environ['LOCALAPPDATA']) / 'RocksmithDiscordBridge') if getattr(sys, 'frozen', False) else ROOT
DATA_DIR.mkdir(parents=True, exist_ok=True)
logging.basicConfig(filename=DATA_DIR / 'bridge.log', level=logging.INFO,
                    format='%(asctime)s %(levelname)s %(message)s', encoding='utf-8')


def output_devices():
    apis = sd.query_hostapis()
    return [(i, d['name']) for i, d in enumerate(sd.query_devices())
            if d['max_output_channels'] >= 2 and 'WASAPI' in apis[d['hostapi']]['name']]


def save_output(name):
    if name not in [device_name for _, device_name in output_devices()]:
        raise ValueError(f'Saída WASAPI indisponível: {name}')
    (DATA_DIR / 'settings.json').write_text(json.dumps({'output': name}, ensure_ascii=False), encoding='utf-8')


class AudioReceiver:
    def __init__(self, parent_pid):
        self.parent_pid = parent_pid
        self.messages = queue.SimpleQueue()
        self.stop_event = threading.Event()
        self.audio_blocks = 0
        self.audio_peak = 0.0

    def audio_worker(self, device):
        mapping = None
        try:
            while not self.stop_event.is_set():
                pids = game_pids()
                if self.parent_pid is not None:
                    if self.parent_pid not in pids:
                        return
                    pids = [self.parent_pid]
                for pid in pids:
                    try:
                        mapping = Mapping(pid)
                        break
                    except FileNotFoundError:
                        continue
                if mapping:
                    break
                self.stop_event.wait(0.5)
            if not mapping:
                return
            while not self.stop_event.is_set():
                try:
                    reader = RingReader(mapping.copy)
                    break
                except BlockingIOError:
                    self.stop_event.wait(0.01)
            if self.stop_event.is_set():
                return
            if reader.pid not in pids:
                raise RuntimeError('Memória do mod não pertence ao jogo detectado')
            self.messages.put(('connected', 'Áudio conectado. Compartilhe Rocksmith 2014 no Discord com som.'))
            with sd.OutputStream(device=device, samplerate=reader.format.rate, channels=2,
                                 dtype='float32', latency=0.06,
                                 extra_settings=sd.WasapiSettings(exclusive=False, auto_convert=True)) as stream:
                last_audio = time.monotonic()
                status_report = last_audio
                while not self.stop_event.is_set():
                    packets = reader.poll()
                    if packets:
                        # Recover from a stalled receiver by discarding old audio, never delaying ASIO.
                        if len(packets) > 8:
                            reader.dropped += len(packets) - 8
                            packets = packets[-8:]
                        samples = np.concatenate([decode(p, reader.format) for p in packets])
                        underflow = stream.write(samples)
                        self.audio_blocks += len(packets)
                        self.audio_peak = float(np.max(np.abs(samples)))
                        last_audio = time.monotonic()
                        if last_audio - status_report >= 1:
                            self.messages.put(('status', 'Áudio do jogo recebido. Compartilhe Rocksmith 2014 no Discord com som.'))
                            status_report = last_audio
                        if underflow:
                            logging.debug('Receiver playback underflow')
                    else:
                        self.stop_event.wait(0.002)
                    now = time.monotonic()
                    if now - last_audio > 2:
                        if reader.pid not in game_pids():
                            raise RuntimeError('O jogo foi fechado.')
                        self.messages.put(('status', 'Sem novos blocos de áudio; confira o jogo e o driver ASIO.'))
                        last_audio = now
        except Exception as exc:
            logging.exception('Audio receiver failed')
            self.messages.put(('error', str(exc)))
        finally:
            if mapping:
                mapping.close()
            self.messages.put(('done', None))


def run_audio_only():
    """A windowless child of Rocksmith; never create a Tk window or take focus."""
    devices = output_devices()
    preferred = json.loads((DATA_DIR / 'settings.json').read_text(encoding='utf-8')).get('output', '')
    selected = next(((device, name) for device, name in devices if name == preferred), None)
    if selected is None:
        raise RuntimeError(f'Saída de áudio indisponível: {preferred}')
    runner = AudioReceiver(int(sys.argv[sys.argv.index('--parent-pid') + 1]))
    worker = threading.Thread(target=runner.audio_worker, args=(selected[0],), daemon=True)
    worker.start()
    connected = False
    status = 'Aguardando áudio do jogo'
    done = False
    while not done:
        try:
            event, value = runner.messages.get(timeout=0.5)
            if event == 'connected':
                connected = True
                status = 'Áudio conectado. Compartilhe Rocksmith 2014 com som no Discord.'
            elif event in ('status', 'error'):
                status = value
            elif event == 'done':
                connected = False
                done = True
        except queue.Empty:
            pass
        (DATA_DIR / 'diagnostics.json').write_text(json.dumps({
            'pid': os.getpid(), 'parent_pid': runner.parent_pid, 'audio_only': True,
            'audio_connected': connected, 'audio_blocks': runner.audio_blocks,
            'audio_peak': runner.audio_peak, 'status': status, 'output': selected[1],
        }, ensure_ascii=False), encoding='utf-8')


if __name__ == '__main__':
    if sys.platform != 'win32' or platform.machine().lower() not in ('amd64', 'x86_64'):
        raise SystemExit('Use Python x64 no Windows x64.')
    if '--setup-install' in sys.argv or '--setup-uninstall' in sys.argv:
        from bridge.installation import main
        raise SystemExit(main(sys.argv[1:]))
    elif '--configure-output' in sys.argv:
        from bridge.setup_ui import run_setup
        raise SystemExit(run_setup(DATA_DIR, output_devices, save_output, game_pids))
    elif '--set-output' in sys.argv:
        save_output(sys.argv[sys.argv.index('--set-output') + 1])
    elif '--audio-only' in sys.argv:
        run_audio_only()
    else:
        from bridge.setup_ui import run_setup
        raise SystemExit(run_setup(DATA_DIR, output_devices, save_output, game_pids))
