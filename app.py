"""Rocksmith audio child process and optional diagnostic video preview."""
import json
import logging
import os
from pathlib import Path
import platform
import queue
import sys
import threading
import time
import tkinter as tk
from tkinter import ttk, messagebox

import numpy as np
import sounddevice as sd
from PIL import Image, ImageTk

from bridge.protocol import Mapping, RingReader
from bridge.pcm import decode
from bridge.winprocess import game_pids

ROOT = Path(sys.executable).resolve().parent if getattr(sys, 'frozen', False) else Path(__file__).resolve().parent
logging.basicConfig(filename=ROOT / 'bridge.log', level=logging.INFO,
                    format='%(asctime)s %(levelname)s %(message)s', encoding='utf-8')


def output_devices():
    apis = sd.query_hostapis()
    return [(i, d['name']) for i, d in enumerate(sd.query_devices())
            if d['max_output_channels'] >= 2 and 'WASAPI' in apis[d['hostapi']]['name']]


def save_output(name):
    if name not in [device_name for _, device_name in output_devices()]:
        raise ValueError(f'Saída WASAPI indisponível: {name}')
    (ROOT / 'settings.json').write_text(json.dumps({'output': name}, ensure_ascii=False), encoding='utf-8')


def configure_output():
    """Select the user's output without starting the game or the audio worker."""
    root = tk.Tk()
    root.title('Rocksmith Discord Bridge — saída de áudio')
    root.geometry('650x190')
    root.resizable(False, False)
    panel = ttk.Frame(root, padding=16)
    panel.pack(fill='both', expand=True)
    ttk.Label(panel, text='Onde você quer ouvir o jogo?').pack(anchor='w')
    ttk.Label(panel, text='Escolha uma saída estéreo disponível. O Discord capturará esta cópia do áudio.').pack(anchor='w', pady=6)
    names = [name for _, name in output_devices()]
    box = ttk.Combobox(panel, state='readonly', values=names)
    box.pack(fill='x', pady=6)
    preferred = ''
    try:
        preferred = json.loads((ROOT / 'settings.json').read_text(encoding='utf-8')).get('output', '')
    except (OSError, ValueError):
        pass
    if names:
        box.current(names.index(preferred) if preferred in names else 0)
    accepted = []
    def accept():
        try:
            save_output(box.get())
        except (OSError, ValueError) as exc:
            messagebox.showerror('Não foi possível salvar', str(exc), parent=root)
            return
        accepted.append(True)
        root.destroy()
    ttk.Button(panel, text='Salvar saída', command=accept, state='normal' if names else 'disabled').pack(side='right', pady=8)
    root.mainloop()
    return 0 if accepted else 1


class App:
    def __init__(self, root):
        self.root = root
        self.audio_only = '--audio-only' in sys.argv
        if self.audio_only:
            root.withdraw()
        self.parent_pid = int(sys.argv[sys.argv.index('--parent-pid') + 1]) if '--parent-pid' in sys.argv else None
        root.title('Rocksmith Stream Bridge')
        root.geometry('1000x730')
        root.minsize(720, 540)
        self.messages = queue.SimpleQueue()
        self.frames = queue.Queue(maxsize=1)
        self.stop_event = threading.Event()
        self.worker = None
        self.capture = None
        self.capture_object = None
        self.last_video = 0.0
        self.photo = None
        self.audio_blocks = 0
        self.video_frames = 0
        self.audio_peak = 0.0
        self.audio_connected = False
        self.clean_view = False
        self.window_geometry = None
        self.pinned = False
        self.last_diagnostic = 0.0
        self.devices = output_devices()
        self.status = tk.StringVar(value='Abra o Rocksmith e clique em Iniciar.')
        self.video_status = tk.StringVar(value='Prévia do jogo')
        self.meter = tk.DoubleVar(value=0)
        self.container = ttk.Frame(root)
        self.container.pack(fill='both', expand=True)
        panel = ttk.Frame(self.container, padding=12)
        self.controls = panel
        panel.pack(fill='x')
        ttk.Label(panel, text='Rocksmith Stream Bridge', font=('Segoe UI', 18, 'bold')).pack(anchor='w')
        ttk.Label(panel, text='No Discord, compartilhe esta janela e ative o compartilhamento de som.').pack(anchor='w', pady=5)
        ttk.Label(panel, text='Saída de áudio: selecione onde ouvir a cópia do jogo.').pack(anchor='w')
        self.device_box = ttk.Combobox(panel, state='readonly', values=[name for _, name in self.devices])
        self.device_box.pack(fill='x', pady=5)
        preferred = ''
        try:
            preferred = json.loads((ROOT / 'settings.json').read_text(encoding='utf-8')).get('output', '')
        except (OSError, ValueError):
            pass
        if self.devices:
            names = [name for _, name in self.devices]
            pick = names.index(preferred) if preferred in names else 0
            self.device_box.current(pick)
        buttons = ttk.Frame(panel)
        buttons.pack(fill='x', pady=5)
        self.start_button = ttk.Button(buttons, text='Iniciar', command=self.start)
        self.start_button.pack(side='left')
        ttk.Button(buttons, text='Parar', command=self.stop).pack(side='left', padx=8)
        ttk.Button(buttons, text='Como usar', command=self.help).pack(side='right')
        ttk.Button(buttons, text='Só imagem (F10)', command=lambda: self.set_clean_view(True)).pack(side='left')
        ttk.Button(buttons, text='Fixar prévia (F9)', command=self.toggle_pinned).pack(side='left', padx=5)
        ttk.Button(buttons, text='Abrir Rocksmith', command=lambda: os.startfile('steam://rungameid/221680')).pack(side='right', padx=8)
        ttk.Label(panel, textvariable=self.status, wraplength=950).pack(anchor='w', pady=4)
        ttk.Progressbar(panel, variable=self.meter, maximum=100).pack(fill='x')
        ttk.Label(panel, textvariable=self.video_status).pack(anchor='w', pady=5)
        ttk.Label(panel, text='F9: fixar prévia · F10: imagem/controles · F11: tela cheia · Esc: controles').pack(anchor='w')
        self.preview = tk.Label(self.container, bg='black', fg='white', text='Aguardando o jogo...', font=('Segoe UI', 16), borderwidth=0)
        self.preview.pack(fill='both', expand=True)
        root.protocol('WM_DELETE_WINDOW', self.close)
        root.bind('<F10>', lambda event: self.set_clean_view(not self.clean_view))
        root.bind('<F9>', lambda event: self.toggle_pinned())
        root.bind('<F11>', lambda event: self.toggle_fullscreen())
        root.bind('<Escape>', lambda event: self.set_clean_view(False))
        root.after(40, self.tick)
        if self.audio_only:
            root.withdraw()
        if '--auto-start' in sys.argv:
            root.after(500, self.start)
        if '--clean-view' in sys.argv:
            root.after(600, lambda: self.set_clean_view(True))
        if '--pinned' in sys.argv:
            root.after(650, self.toggle_pinned)
        if '--launch-game' in sys.argv and not game_pids():
            os.startfile('steam://rungameid/221680')

    def set_clean_view(self, enabled):
        if enabled == self.clean_view:
            return
        self.clean_view = enabled
        if enabled:
            self.window_geometry = self.root.geometry()
            self.controls.pack_forget()
            self.root.geometry('1280x720')
        else:
            self.root.attributes('-fullscreen', False)
            self.root.minsize(720, 540)
            self.controls.pack(fill='x', before=self.preview)
            if self.window_geometry:
                self.root.geometry(self.window_geometry)

    def toggle_fullscreen(self):
        fullscreen = bool(self.root.attributes('-fullscreen'))
        if not self.clean_view:
            self.set_clean_view(True)
        self.root.attributes('-fullscreen', not fullscreen)
        self.root.attributes('-topmost', self.pinned and fullscreen)

    def toggle_pinned(self):
        self.pinned = not self.pinned
        self.root.attributes('-fullscreen', False)
        self.root.attributes('-topmost', self.pinned)
        if self.pinned:
            self.set_clean_view(True)
            self.root.minsize(320, 180)
            width, height = 1280, 720
            self.root.geometry(f'{width}x{height}+{max(0, self.root.winfo_screenwidth() - width - 20)}+40')

    def help(self):
        messagebox.showinfo('Como compartilhar',
            '1. Configure sua guitarra e a saída ASIO no RS_ASIO.\n'
            '2. Escolha uma saída WASAPI para ouvir a cópia do áudio.\n'
            '3. Clique em Iniciar e espere aparecerem imagem e sinal de áudio.\n'
            '4. No Discord, compartilhe a janela Rocksmith Stream Bridge com som.\n'
            '5. F10 esconde os controles; F11 coloca só o jogo em tela cheia. Esc mostra os controles.\n'
            '6. Volte ao jogo. Deixe esta janela aberta, sem minimizar.\n\n'
            'Use seu microfone de conversa normalmente no Discord.\n\n'
            'O áudio da ponte pode ter atraso ao tocar. '
            'Evite ouvir simultaneamente o monitoramento direto e a cópia atrasada.')

    def start(self):
        if self.worker and self.worker.is_alive():
            return
        selected = self.device_box.current()
        if selected < 0:
            messagebox.showerror('Saída indisponível', 'Conecte uma segunda saída de áudio e reabra o aplicativo.')
            return
        device, name = self.devices[selected]
        (ROOT / 'settings.json').write_text(json.dumps({'output': name}, ensure_ascii=False), encoding='utf-8')
        self.stop_event.clear()
        self.device_box.configure(state='disabled')
        self.start_button.configure(state='disabled')
        self.status.set('Aguardando o jogo com o mod instalado...')
        self.worker = threading.Thread(target=self.audio_worker, args=(device,), daemon=True)
        self.worker.start()

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
            self.messages.put(('connected', 'Áudio conectado. Compartilhe esta janela no Discord.'))
            with sd.OutputStream(device=device, samplerate=reader.format.rate, channels=2,
                                 dtype='float32', latency=0.06,
                                 extra_settings=sd.WasapiSettings(exclusive=False, auto_convert=True)) as stream:
                last_audio = time.monotonic()
                report = last_audio
                status_report = last_audio
                peak = 0.0
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
                        peak = max(peak, float(np.max(np.abs(samples))))
                        self.audio_peak = float(np.max(np.abs(samples)))
                        last_audio = time.monotonic()
                        if last_audio - status_report >= 1:
                            self.messages.put(('status', 'Áudio do jogo recebido. Compartilhe esta janela no Discord com som.'))
                            status_report = last_audio
                        if underflow:
                            logging.debug('Receiver playback underflow')
                    else:
                        self.stop_event.wait(0.002)
                    now = time.monotonic()
                    if now - report >= 0.25:
                        self.messages.put(('meter', peak * 100))
                        peak = 0.0
                        report = now
                    if now - last_audio > 2:
                        if reader.pid not in game_pids():
                            raise RuntimeError('O jogo foi fechado. Abra-o e clique em Iniciar novamente.')
                        self.messages.put(('status', 'Sem novos blocos de áudio; confira o jogo e o driver ASIO.'))
                        last_audio = now
        except Exception as exc:
            logging.exception('Audio receiver failed')
            self.messages.put(('error', str(exc)))
        finally:
            if mapping:
                mapping.close()
            self.messages.put(('done', None))

    def start_video(self):
        if self.audio_only:
            return
        if self.capture:
            return
        try:
            from windows_capture import WindowsCapture, Frame, InternalCaptureControl
            capture = WindowsCapture(cursor_capture=False, draw_border=False,
                                     monitor_index=None, window_name='Rocksmith 2014')

            @capture.event
            def on_frame_arrived(frame: Frame, capture_control: InternalCaptureControl):
                if self.stop_event.is_set():
                    capture_control.stop()
                    return
                now = time.monotonic()
                if now - self.last_video < 1 / 30:
                    return
                self.last_video = now
                self.video_frames += 1
                # Copy native-owned BGRA frame before returning to the capture library.
                image = Image.fromarray(frame.frame_buffer[:, :, [2, 1, 0]].copy())
                image.thumbnail((1920, 1080), Image.Resampling.BILINEAR)
                try:
                    self.frames.get_nowait()
                except queue.Empty:
                    pass
                try:
                    self.frames.put_nowait(image)
                except queue.Full:
                    pass

            @capture.event
            def on_closed():
                self.messages.put(('video_status', 'A janela do jogo foi fechada.'))

            self.capture_object = capture  # Retain callbacks for the full native capture lifetime.
            self.capture = capture.start_free_threaded()
            self.video_status.set('Imagem do Rocksmith — compartilhe esta janela com som')
        except Exception as exc:
            logging.exception('Video capture failed')
            self.video_status.set(f'Não foi possível capturar a imagem: {exc}')

    def stop_video(self):
        if self.capture:
            try:
                self.capture.stop()
            except Exception:
                logging.exception('Video shutdown failed')
            self.capture = None
            self.capture_object = None

    def stop(self):
        self.stop_event.set()
        self.stop_video()
        self.status.set('Parando...')

    def tick(self):
        while True:
            try:
                event, value = self.messages.get_nowait()
            except queue.Empty:
                break
            if event == 'connected':
                if not self.stop_event.is_set():
                    self.audio_connected = True
                    self.status.set(value)
                    self.start_video()
            elif event in ('status', 'error'):
                self.status.set(value)
            elif event == 'video_status':
                self.video_status.set(value)
            elif event == 'meter':
                self.meter.set(value)
            elif event == 'done':
                self.audio_connected = False
                self.stop_video()
                self.device_box.configure(state='readonly')
                self.start_button.configure(state='normal')
                self.meter.set(0)
                if self.stop_event.is_set():
                    self.status.set('Parado.')
                if self.audio_only:
                    self.close()
                    return
        try:
            image = self.frames.get_nowait()
            image.thumbnail((max(1, self.preview.winfo_width()), max(1, self.preview.winfo_height())), Image.Resampling.BILINEAR)
            self.photo = ImageTk.PhotoImage(image)
            self.preview.configure(image=self.photo, text='')
        except queue.Empty:
            pass
        now = time.monotonic()
        if now - self.last_diagnostic >= 1:
            self.last_diagnostic = now
            try:
                (ROOT / 'diagnostics.json').write_text(json.dumps({
                    'pid': os.getpid(), 'audio_connected': self.audio_connected,
                    'audio_blocks': self.audio_blocks, 'audio_peak': self.audio_peak,
                    'video_frames': self.video_frames, 'status': self.status.get(),
                    'video_status': self.video_status.get(), 'output': self.device_box.get(),
                    'clean_view': self.clean_view, 'fullscreen': bool(self.root.attributes('-fullscreen')),
                    'pinned': self.pinned,
                    'audio_only': self.audio_only, 'parent_pid': self.parent_pid,
                    'preview_size': [self.preview.winfo_width(), self.preview.winfo_height()],
                }, ensure_ascii=False), encoding='utf-8')
            except OSError:
                logging.exception('Could not save diagnostics')
        self.root.after(33, self.tick)

    def close(self):
        self.stop_event.set()
        self.stop_video()
        self.root.destroy()


def run_audio_only():
    """A windowless child of Rocksmith; never create a Tk window or take focus."""
    devices = output_devices()
    preferred = json.loads((ROOT / 'settings.json').read_text(encoding='utf-8')).get('output', '')
    selected = next(((device, name) for device, name in devices if name == preferred), None)
    if selected is None:
        raise RuntimeError(f'Saída de áudio indisponível: {preferred}')
    runner = App.__new__(App)
    runner.parent_pid = int(sys.argv[sys.argv.index('--parent-pid') + 1])
    runner.messages = queue.SimpleQueue()
    runner.stop_event = threading.Event()
    runner.audio_blocks = 0
    runner.audio_peak = 0.0
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
                status = value.replace('esta janela', 'Rocksmith 2014')
            elif event == 'done':
                connected = False
                done = True
        except queue.Empty:
            pass
        (ROOT / 'diagnostics.json').write_text(json.dumps({
            'pid': os.getpid(), 'parent_pid': runner.parent_pid, 'audio_only': True,
            'audio_connected': connected, 'audio_blocks': runner.audio_blocks,
            'audio_peak': runner.audio_peak, 'status': status, 'output': selected[1],
        }, ensure_ascii=False), encoding='utf-8')


if __name__ == '__main__':
    if sys.platform != 'win32' or platform.machine().lower() not in ('amd64', 'x86_64'):
        raise SystemExit('Use Python x64 no Windows x64.')
    if '--configure-output' in sys.argv:
        raise SystemExit(configure_output())
    elif '--set-output' in sys.argv:
        save_output(sys.argv[sys.argv.index('--set-output') + 1])
    elif '--audio-only' in sys.argv:
        run_audio_only()
    else:
        root = tk.Tk()
        App(root)
        root.mainloop()
