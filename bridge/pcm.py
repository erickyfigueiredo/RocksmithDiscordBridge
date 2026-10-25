import numpy as np


def decode(raw, fmt):
    """Return stereo float32; Windows PCM valid bits are left aligned in containers."""
    if fmt.floating:
        samples = np.frombuffer(raw, dtype='<f4').copy()
    elif fmt.bits == 16:
        samples = np.frombuffer(raw, dtype='<i2').astype(np.float32) / 32768.0
    elif fmt.bits == 32:
        samples = np.frombuffer(raw, dtype='<i4').astype(np.float32) / 2147483648.0
    elif fmt.bits == 24:
        b = np.frombuffer(raw, dtype=np.uint8).reshape(-1, 3).astype(np.int32)
        n = b[:, 0] | (b[:, 1] << 8) | (b[:, 2] << 16)
        n = (n ^ 0x800000) - 0x800000
        samples = n.astype(np.float32) / 8388608.0
    else:
        raise ValueError('PCM não suportado')
    np.nan_to_num(samples, copy=False, nan=0.0, posinf=1.0, neginf=-1.0)
    return np.clip(samples.reshape(-1, fmt.channels), -1.0, 1.0)
