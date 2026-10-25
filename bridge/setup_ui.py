"""Short, bilingual audio onboarding. Never edits game files or driver settings."""
import configparser
import ctypes
import json
import os
from pathlib import Path
import subprocess
import time
import tkinter as tk
from tkinter import ttk, messagebox


TEXT = {
    'en': {
        'title': 'Rocksmith Discord Bridge — audio setup',
        'steps': ('1  Guitar', '2  Headphones', '3  Test'),
        'guitar': 'Connect your guitar to your audio interface.',
        'panel': 'Open ASIO4ALL',
        'panel_hint': 'Enable only your interface’s input and output in that panel.',
        'manufacturer': 'Select your interface in your manufacturer’s driver panel.',
        'driver': 'Audio driver: ',
        'headphones': 'Where do you want to hear the game?',
        'refresh': 'Refresh devices',
        'open': 'Open Rocksmith',
        'test_hint': 'Keep the game in front for 10 seconds. Play a few notes, then return here.',
        'waiting_game': 'Open Rocksmith to start the test.',
        'waiting_bridge': 'Game detected. Waiting for the audio bridge…',
        'no_audio': 'No new audio. Bring the game to the front and check the driver panel.',
        'restart_output': 'Close and reopen the game to apply your new headphones output.',
        'receiving': '✓ Game audio is reaching your headphones output.',
        'tested': '✓ Audio tested. The game may pause when you switch away.',
        'signal': '✓ Sound signal detected.',
        'silence': 'Waiting for a sound signal…',
        'closed': 'The game closed. Check the audio settings before trying again.',
        'mods': 'Other game mods were found. If the game crashes, test them separately.',
        'confirm': 'I hear the game and my guitar',
        'ready': 'Ready! Share Rocksmith 2014 with sound in Discord.',
        'receiver': 'Ask your viewer to confirm the picture and sound.',
        'next': 'Next', 'back': 'Back', 'done': 'Finish',
        'output_error': 'Choose an available headphones output first.',
        'panel_error': 'ASIO4ALL panel was not found. Install ASIO4ALL or use your driver’s panel.',
        'details': 'Details', 'save_error': 'Could not save the output',
        'unknown': 'Not configured',
        'close_game': 'Close Rocksmith before changing interface settings.',
    },
    'pt': {
        'title': 'Rocksmith Discord Bridge — configurar áudio',
        'steps': ('1  Guitarra', '2  Fone', '3  Testar'),
        'guitar': 'Conecte a guitarra à sua interface de áudio.',
        'panel': 'Abrir ASIO4ALL',
        'panel_hint': 'No painel, ative só a entrada e a saída da sua interface.',
        'manufacturer': 'Selecione sua interface no painel do driver do fabricante.',
        'driver': 'Driver de áudio: ',
        'headphones': 'Onde você quer ouvir o jogo?',
        'refresh': 'Atualizar dispositivos',
        'open': 'Abrir Rocksmith',
        'test_hint': 'Deixe o jogo em primeiro plano por 10 segundos. Toque algumas notas e volte aqui.',
        'waiting_game': 'Abra o Rocksmith para começar o teste.',
        'waiting_bridge': 'Jogo detectado. Aguardando a ponte de áudio…',
        'no_audio': 'Sem áudio novo. Volte ao jogo e confira o painel do driver.',
        'restart_output': 'Feche e abra o jogo para aplicar a nova saída de fone.',
        'receiving': '✓ O áudio do jogo está chegando à saída do fone.',
        'tested': '✓ Áudio testado. O jogo pode pausar quando você sai dele.',
        'signal': '✓ Sinal de som detectado.',
        'silence': 'Aguardando sinal de som…',
        'closed': 'O jogo fechou. Confira o áudio antes de tentar de novo.',
        'mods': 'Há outros mods no jogo. Se ele fechar sozinho, teste os mods separadamente.',
        'confirm': 'Ouço o jogo e a guitarra',
        'ready': 'Pronto! Compartilhe Rocksmith 2014 com som no Discord.',
        'receiver': 'Peça a quem assiste para confirmar a imagem e o som.',
        'next': 'Continuar', 'back': 'Voltar', 'done': 'Concluir',
        'output_error': 'Escolha uma saída de fone disponível primeiro.',
        'panel_error': 'Painel ASIO4ALL não encontrado. Instale o ASIO4ALL ou use o painel do seu driver.',
        'details': 'Detalhes', 'save_error': 'Não foi possível salvar a saída',
        'unknown': 'Não configurado',
        'close_game': 'Feche o Rocksmith antes de configurar a interface.',
    },
}


def system_language():
    try:
        return 'pt' if ctypes.windll.kernel32.GetUserDefaultUILanguage() & 0x3ff == 0x16 else 'en'
    except (AttributeError, OSError):
        return 'en'


def game_configuration(state_file=None):
    """Read only the local installation manifest; do not publish machine paths."""
    try:
        state_file = state_file or Path(os.environ['PROGRAMDATA']) / 'RocksmithDiscordBridge/installation.json'
        state = json.loads(Path(state_file).read_text(encoding='utf-8'))
        if not state.get('active'):
            return None, ''
        game = Path(state['game'])
        config = configparser.ConfigParser(interpolation=None, strict=False)
        config.read(game / 'RS_ASIO.ini', encoding='utf-8-sig')
        return game, config.get('Asio.Output', 'Driver', fallback='')
    except (KeyError, OSError, ValueError, configparser.Error):
        return None, ''


class AudioProbe:
    """Require fresh, advancing packets; a live process alone is not a pass."""
    def __init__(self):
        self.pid = None
        self.blocks = None
        self.last_packet = 0.0
        self.received = False
        self.signal = False
        self.saw_game = False
        self.flow_since = None
        self.verified = False

    def can_confirm(self, state, now):
        # Preserve a recent measured result while the user returns from the game.
        # Never treat a process with static counters as a successful measurement.
        return state in ('receiving', 'no_audio') and self.verified and now - self.last_packet < 30

    def sample(self, data, pids, fresh, now, output=''):
        if not pids:
            return 'closed' if self.saw_game else 'waiting_game'
        self.saw_game = True
        if not fresh or data.get('parent_pid') not in pids:
            return 'waiting_bridge'
        if output and data.get('output') != output:
            return 'restart_output'
        if self.pid != data['parent_pid']:
            self.pid = data['parent_pid']
            self.blocks = None
            self.last_packet = now
            self.received = self.signal = False
            self.flow_since = None
            self.verified = False
        if not data.get('audio_connected'):
            return 'waiting_bridge'
        blocks = data.get('audio_blocks', 0)
        if self.blocks is not None and blocks > self.blocks:
            if self.flow_since is None or now - self.last_packet > 3:
                self.flow_since = now
            self.last_packet = now
            self.received = True
            self.signal |= data.get('audio_peak', 0) > 0.00001
            self.verified |= self.signal and now - self.flow_since >= 5
        self.blocks = blocks
        if now - self.last_packet > 3:
            return 'no_audio'
        return 'receiving' if self.received else 'waiting_bridge'


def run_setup(data_dir, output_devices, save_output, game_pids):
    data_dir = Path(data_dir)
    language = system_language()
    try:
        language = json.loads((data_dir / 'ui.json').read_text(encoding='utf-8')).get('language', language)
    except (OSError, ValueError):
        pass
    language = language if language in TEXT else 'en'
    game, driver = game_configuration()
    root = tk.Tk()
    root.geometry('760x460')
    root.minsize(680, 440)
    shell = ttk.Frame(root, padding=24)
    shell.pack(fill='both', expand=True)
    header = ttk.Frame(shell)
    header.pack(fill='x')
    title = ttk.Label(header, font=('Segoe UI', 15, 'bold'))
    title.pack(side='left')
    locale = ttk.Combobox(header, state='readonly', values=('Português', 'English'), width=12)
    locale.set('Português' if language == 'pt' else 'English')
    locale.pack(side='right')
    body = ttk.Frame(shell, padding=(0, 24))
    body.pack(fill='both', expand=True)
    footer = ttk.Frame(shell)
    footer.pack(fill='x')
    step = 0
    timer = None
    selected_output = ''
    probe = AudioProbe()

    def label(text, **kwargs):
        widget = ttk.Label(body, text=text, wraplength=590, **kwargs)
        widget.pack(anchor='w', pady=(0, 12))
        return widget

    def open_panel():
        if game_pids():
            messagebox.showinfo(TEXT[language]['panel'], TEXT[language]['close_game'], parent=root)
            return
        panel = Path(os.environ.get('ProgramFiles(x86)', 'C:/Program Files (x86)')) / 'ASIO4ALL v2/a4apanel.exe'
        if not panel.is_file():
            messagebox.showerror(TEXT[language]['panel'], TEXT[language]['panel_error'], parent=root)
            return
        subprocess.Popen([str(panel)], creationflags=subprocess.CREATE_NO_WINDOW)

    def advance():
        nonlocal step, selected_output, probe
        if step == 1:
            try:
                selected_output = outputs.get()
                save_output(selected_output)
                probe = AudioProbe()
            except (OSError, ValueError) as exc:
                messagebox.showerror(TEXT[language]['save_error'], str(exc), parent=root)
                return
        step += 1
        render()

    def back():
        nonlocal step
        step -= 1
        render()

    def set_language(event=None):
        nonlocal language, selected_output
        if step == 1 and outputs is not None:
            selected_output = outputs.get()
        language = 'pt' if locale.get() == 'Português' else 'en'
        (data_dir / 'ui.json').write_text(json.dumps({'language': language}), encoding='utf-8')
        render()

    def confirm():
        nonlocal timer
        if timer:
            root.after_cancel(timer)
            timer = None
        for widget in body.winfo_children():
            widget.destroy()
        label(TEXT[language]['ready'], font=('Segoe UI', 13, 'bold'))
        label(TEXT[language]['receiver'])
        next_button.configure(text=TEXT[language]['done'], command=root.destroy, state='normal')

    def details():
        try:
            text = (data_dir / 'diagnostics.json').read_text(encoding='utf-8')
        except OSError:
            text = TEXT[language]['waiting_bridge']
        messagebox.showinfo(TEXT[language]['details'], text, parent=root)

    outputs = None
    back_button = ttk.Button(footer, command=back)
    back_button.pack(side='left')
    next_button = ttk.Button(footer, command=advance)
    next_button.pack(side='right')

    def render():
        nonlocal timer, outputs
        if timer:
            root.after_cancel(timer)
            timer = None
        for widget in body.winfo_children():
            widget.destroy()
        t = TEXT[language]
        root.title(t['title'])
        title.configure(text=t['steps'][step])
        back_button.configure(text=t['back'], state='normal' if step else 'disabled')
        next_button.configure(text=t['next'], command=advance, state='normal')
        if step == 0:
            label(t['guitar'], font=('Segoe UI', 12))
            label(t['driver'] + (driver or t['unknown']))
            if driver.casefold() == 'asio4all v2':
                ttk.Button(body, text=t['panel'], command=open_panel).pack(anchor='w', pady=(0, 12))
                label(t['panel_hint'])
            else:
                label(t['manufacturer'])
        elif step == 1:
            label(t['headphones'], font=('Segoe UI', 12))
            names = [name for _, name in output_devices()]
            outputs = ttk.Combobox(body, state='readonly', values=names)
            outputs.pack(fill='x', pady=(0, 12))
            preferred = selected_output
            if not preferred:
                try:
                    preferred = json.loads((data_dir / 'settings.json').read_text(encoding='utf-8')).get('output', '')
                except (OSError, ValueError):
                    pass
            # Do not guess the first monitor/HDMI output as the user's headphones.
            if preferred in names:
                outputs.set(preferred)
            def refresh():
                nonlocal selected_output
                selected_output = outputs.get()
                render()
            ttk.Button(body, text=t['refresh'], command=refresh).pack(anchor='w')
        else:
            ttk.Button(body, text=t['open'], command=lambda: os.startfile('steam://rungameid/221680')).pack(anchor='w', pady=(0, 12))
            label(t['test_hint'])
            status = label(t['waiting_game'], font=('Segoe UI', 11, 'bold'))
            signal = label('')
            mod_warning = label('')
            ttk.Button(body, text=t['details'], command=details).pack(anchor='w')
            next_button.configure(text=t['confirm'], command=confirm, state='disabled')

            def tick():
                nonlocal timer
                file = data_dir / 'diagnostics.json'
                try:
                    data = json.loads(file.read_text(encoding='utf-8'))
                    fresh = 0 <= time.time() - file.stat().st_mtime < 3
                except (OSError, ValueError):
                    data, fresh = {}, False
                now = time.monotonic()
                state = probe.sample(data, game_pids(), fresh, now, selected_output)
                confirmed = probe.can_confirm(state, now)
                status.configure(text=t['tested' if state == 'no_audio' and confirmed else state])
                has_mods = game and any((game / name).is_file() for name in ('xinput1_3.dll', 'D3DX9_42.dll'))
                mod_warning.configure(text=t['mods'] if state == 'closed' and has_mods else '')
                signal.configure(text=t['signal' if probe.signal else 'silence'] if state == 'receiving' else '')
                next_button.configure(state='normal' if confirmed else 'disabled')
                timer = root.after(500, tick)
            tick()

    locale.bind('<<ComboboxSelected>>', set_language)
    render()
    root.mainloop()
    return 0
