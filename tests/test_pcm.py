import struct
import unittest
import numpy as np
from bridge.protocol import Format
from bridge.pcm import decode


class TestPCM(unittest.TestCase):
    def test_int16_stereo_signed(self):
        actual = decode(struct.pack('<4h', 0, -32768, 16384, 32767), Format(48000, 2, 16, 0, 4))
        np.testing.assert_allclose(actual, [[0, -1], [0.5, 32767/32768]])

    def test_int24_sign_extension(self):
        actual = decode(bytes.fromhex('000080 ffff7f'), Format(48000, 2, 24, 0, 6))
        np.testing.assert_allclose(actual, [[-1, 8388607/8388608]])

    def test_int32_valid24_left_aligned(self):
        actual = decode(struct.pack('<ii', -2147483648, 1073741824), Format(48000, 2, 32, 0, 8))
        np.testing.assert_allclose(actual, [[-1, 0.5]])

    def test_float_nan_inf_clipping(self):
        actual = decode(struct.pack('<4f', float('nan'), float('inf'), -2, 0.5), Format(48000, 2, 32, 1, 8))
        np.testing.assert_allclose(actual, [[0, 1], [-1, 0.5]])


if __name__ == '__main__':
    unittest.main()
