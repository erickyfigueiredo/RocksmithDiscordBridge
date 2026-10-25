"""Read-only reader for native/BridgeTap.h (Windows x86/x64 wire format)."""
import ctypes
import struct
from dataclasses import dataclass

MAGIC = 0x31425352
CAPACITY = 32
PAYLOAD = 65536
HEADER_SIZE = 64
SLOT_SIZE = PAYLOAD + 8
MAPPING_SIZE = HEADER_SIZE + CAPACITY * SLOT_SIZE
MASK = 0xFFFFFFFF


@dataclass(frozen=True)
class Format:
    rate: int
    channels: int
    bits: int
    floating: int
    align: int


class RingReader:
    """copy(offset, length) must return a fresh bytes snapshot, never a live view.

    Slot sequence is checked before AND after copying to reject overwritten data.
    Windows x86/x64 provides coherent, aligned 32-bit loads and ordered loads.
    """
    def __init__(self, copy):
        self.copy = copy
        h = struct.unpack('<16I', copy(0, HEADER_SIZE))
        check = struct.unpack('<16I', copy(0, HEADER_SIZE))
        if h[0] != MAGIC or check[0] != MAGIC or h[11] != check[11] or h[3:8] != check[3:8]:
            raise BlockingIOError('Aguardando inicialização do áudio do jogo')
        if h[0:2] != (MAGIC, 1) or h[8:10] != (CAPACITY, PAYLOAD):
            raise ValueError('Mod ausente ou protocolo incompatível')
        self.format = Format(*h[3:8])
        f = self.format
        if (f.rate != 48000 or f.channels != 2 or f.bits not in (16, 24, 32)
                or f.floating not in (0, 1) or (f.floating and f.bits != 32)
                or f.align != f.channels * (f.bits // 8)):
            raise ValueError('Formato de áudio não suportado')
        self.pid = h[10]
        self.generation = h[11]
        self.last = h[2]  # Join live; do not play old audio accumulated before opening.
        self.dropped = 0

    def u32(self, offset):
        return struct.unpack('<I', self.copy(offset, 4))[0]

    def poll(self):
        if self.u32(0) != MAGIC:
            return []  # Producer is reinitializing, not publishing a usable header yet.
        generation = self.u32(44)
        if generation != self.generation:
            try:
                refreshed = RingReader(self.copy)
            except BlockingIOError:
                return []
            self.format = refreshed.format
            self.pid = refreshed.pid
            self.generation = refreshed.generation
            self.last = refreshed.last
            return []
        latest = self.u32(8)
        count = (latest - self.last) & MASK
        if count > 0x7FFFFFFF:
            self.last = latest
            return []
        if count > CAPACITY:
            self.dropped += count - CAPACITY
            self.last = (latest - CAPACITY) & MASK
        packets = []
        while self.last != latest:
            seq = (self.last + 1) & MASK
            offset = HEADER_SIZE + ((seq - 1) % CAPACITY) * SLOT_SIZE
            expected = (seq << 1) & MASK
            before, frames = struct.unpack('<II', self.copy(offset, 8))
            if before != expected:
                self.last = seq
                self.dropped += 1
                continue
            if not 0 < frames <= PAYLOAD // self.format.align:
                self.last = seq
                self.dropped += 1
                continue
            payload = self.copy(offset + 8, frames * self.format.align)
            after = self.u32(offset)
            if before == after:
                packets.append(payload)
            else:
                self.dropped += 1
            self.last = seq
        if self.u32(0) != MAGIC or self.u32(44) != generation:
            return []  # Never play a packet copied across an output-engine restart.
        return packets


class Mapping:
    def __init__(self, pid):
        from ctypes import wintypes as w
        self.k32 = ctypes.WinDLL('kernel32', use_last_error=True)
        self.k32.OpenFileMappingW.argtypes = [w.DWORD, w.BOOL, w.LPCWSTR]
        self.k32.OpenFileMappingW.restype = w.HANDLE
        self.k32.MapViewOfFile.argtypes = [w.HANDLE, w.DWORD, w.DWORD, w.DWORD, ctypes.c_size_t]
        self.k32.MapViewOfFile.restype = ctypes.c_void_p
        self.k32.UnmapViewOfFile.argtypes = [ctypes.c_void_p]
        self.k32.CloseHandle.argtypes = [w.HANDLE]
        self.handle = self.k32.OpenFileMappingW(4, False, f'Local\\RSASIO_Bridge_v1_{pid}')
        self.address = None
        if not self.handle:
            raise FileNotFoundError('Aguardando Rocksmith com o mod instalado')
        self.address = self.k32.MapViewOfFile(self.handle, 4, 0, 0, MAPPING_SIZE)
        if not self.address:
            self.close()
            raise OSError('Não foi possível abrir a memória do mod')

    def copy(self, offset, size):
        if not self.address or offset < 0 or size < 0 or offset + size > MAPPING_SIZE:
            raise ValueError('Leitura de memória fora dos limites')
        return ctypes.string_at(self.address + offset, size)

    def close(self):
        if self.address:
            self.k32.UnmapViewOfFile(self.address)
            self.address = None
        if self.handle:
            self.k32.CloseHandle(self.handle)
            self.handle = None
