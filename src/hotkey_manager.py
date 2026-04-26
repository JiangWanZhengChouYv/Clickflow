
from pynput import keyboard
from threading import Thread
import sys


class HotkeyManager:
    def __init__(self, callback=None):
        self.callback = callback
        self.listener = None
        self.listener_thread = None
        self.running = False

    def start(self):
        if self.running:
            return

        self.running = True
        self.listener_thread = Thread(target=self._run_listener, daemon=True)
        self.listener_thread.start()

    def _run_listener(self):
        with keyboard.GlobalHotKeys({
            '<cmd>+<shift>+s': self._on_hotkey
        }) as self.listener:
            self.listener.join()

    def _on_hotkey(self):
        if self.callback:
            self.callback()

    def stop(self):
        if not self.running:
            return

        self.running = False
        if self.listener:
            self.listener.stop()
        if self.listener_thread:
            self.listener_thread.join(timeout=1.0)

    def set_callback(self, callback):
        self.callback = callback
