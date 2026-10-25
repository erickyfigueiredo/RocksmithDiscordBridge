from pathlib import Path
import subprocess
import sys
import time
import unittest
from bridge.protocol import Mapping, RingReader

EXE = Path(__file__).resolve().parents[1] / 'bin/tests/native_tap_test.exe'


@unittest.skipUnless(sys.platform == 'win32' and EXE.exists(), 'Build the native x86 test first')
class NativeIntegration(unittest.TestCase):
    def test_x86_cpp_producer_to_x64_python_reader(self):
        process = subprocess.Popen([str(EXE), '--producer'], stdout=subprocess.PIPE, text=True)
        mapping = None
        try:
            pid = int(process.stdout.readline().strip())
            mapping = Mapping(pid)
            reader = RingReader(mapping.copy)
            self.assertEqual(reader.pid, pid)
            deadline = time.monotonic() + 2
            received = []
            while time.monotonic() < deadline and len(received) < 10:
                received.extend(reader.poll())
                time.sleep(0.005)
            self.assertGreaterEqual(len(received), 10)
            for packet in received:
                self.assertEqual(packet, b'\x00\x40\x00\xc0' * 512)
        finally:
            if mapping:
                mapping.close()
            process.terminate()
            process.communicate(timeout=5)
