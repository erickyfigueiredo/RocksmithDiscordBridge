import struct
import unittest
from bridge.protocol import RingReader, MAGIC, CAPACITY, PAYLOAD, HEADER_SIZE, SLOT_SIZE, MAPPING_SIZE, MASK


class Memory:
    def __init__(self):
        self.data = bytearray(MAPPING_SIZE)
        struct.pack_into('<16I', self.data, 0, MAGIC, 1, 0, 48000, 2, 16, 0, 4, CAPACITY, PAYLOAD, 123, 0, 0, 0, 0, 0)

    def copy(self, offset, size):
        return bytes(self.data[offset:offset + size])

    def publish(self, seq, samples=b'\x00\x40\x00\xc0', busy=False):
        offset = HEADER_SIZE + ((seq - 1) % CAPACITY) * SLOT_SIZE
        struct.pack_into('<II', self.data, offset, ((seq << 1) | int(busy)) & MASK, len(samples) // 4)
        self.data[offset + 8:offset + 8 + len(samples)] = samples
        struct.pack_into('<I', self.data, 8, seq)


class TestProtocol(unittest.TestCase):
    def test_clean_stereo_and_no_replay(self):
        m = Memory()
        r = RingReader(m.copy)
        m.publish(1)
        self.assertEqual(r.poll(), [b'\x00\x40\x00\xc0'])
        self.assertEqual(r.poll(), [])

    def test_joins_live(self):
        m = Memory()
        m.publish(1)
        self.assertEqual(RingReader(m.copy).poll(), [])

    def test_overrun_drops_old_packets(self):
        m = Memory()
        r = RingReader(m.copy)
        for seq in range(1, 100):
            m.publish(seq)
        self.assertEqual(len(r.poll()), CAPACITY)
        self.assertEqual(r.dropped, 99 - CAPACITY)

    def test_busy_slot_is_never_played(self):
        m = Memory()
        r = RingReader(m.copy)
        m.publish(1, busy=True)
        self.assertEqual(r.poll(), [])
        self.assertEqual(r.dropped, 1)

    def test_overwrite_during_copy_is_rejected(self):
        m = Memory()
        r = RingReader(m.copy)
        m.publish(1)
        def racing_copy(offset, size):
            result = m.copy(offset, size)
            if offset == HEADER_SIZE + 8:
                m.publish(33)
            return result
        r.copy = racing_copy
        self.assertEqual(r.poll(), [])
        self.assertEqual(r.dropped, 1)

    def test_bad_length_and_format_are_rejected(self):
        m = Memory()
        r = RingReader(m.copy)
        m.publish(1)
        struct.pack_into('<I', m.data, HEADER_SIZE + 4, 0xffffffff)
        self.assertEqual(r.poll(), [])
        struct.pack_into('<I', m.data, 28, 100)
        with self.assertRaises(ValueError):
            RingReader(m.copy)

    def test_sequence_wraparound(self):
        m = Memory()
        struct.pack_into('<I', m.data, 8, MASK - 1)
        r = RingReader(m.copy)
        m.publish(MASK)
        m.publish(0)
        m.publish(1)
        self.assertEqual(len(r.poll()), 3)

    def test_engine_restart_with_reader_attached(self):
        m = Memory()
        r = RingReader(m.copy)
        m.publish(10)
        r.poll()
        struct.pack_into('<I', m.data, 0, 0)  # initialization in progress
        self.assertEqual(r.poll(), [])
        struct.pack_into('<I', m.data, 44, 1)
        struct.pack_into('<I', m.data, 8, 0)
        struct.pack_into('<I', m.data, 0, MAGIC)
        self.assertEqual(r.poll(), [])
        m.publish(1)
        self.assertEqual(len(r.poll()), 1)

    def test_restart_during_copy_discards_entire_batch(self):
        m = Memory()
        r = RingReader(m.copy)
        m.publish(1)
        def restarting_copy(offset, size):
            result = m.copy(offset, size)
            if offset == HEADER_SIZE + 8:
                struct.pack_into('<I', m.data, 44, 1)
            return result
        r.copy = restarting_copy
        self.assertEqual(r.poll(), [])


if __name__ == '__main__':
    unittest.main()
