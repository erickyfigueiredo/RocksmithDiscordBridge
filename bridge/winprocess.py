import ctypes
from ctypes import wintypes as w


class PROCESSENTRY32W(ctypes.Structure):
    _fields_ = [('dwSize', w.DWORD), ('cntUsage', w.DWORD), ('th32ProcessID', w.DWORD),
                ('th32DefaultHeapID', ctypes.c_size_t), ('th32ModuleID', w.DWORD),
                ('cntThreads', w.DWORD), ('th32ParentProcessID', w.DWORD),
                ('pcPriClassBase', w.LONG), ('dwFlags', w.DWORD), ('szExeFile', w.WCHAR * 260)]


def game_pids():
    k = ctypes.WinDLL('kernel32', use_last_error=True)
    k.CreateToolhelp32Snapshot.argtypes = [w.DWORD, w.DWORD]
    k.CreateToolhelp32Snapshot.restype = w.HANDLE
    k.Process32FirstW.argtypes = [w.HANDLE, ctypes.POINTER(PROCESSENTRY32W)]
    k.Process32NextW.argtypes = k.Process32FirstW.argtypes
    k.CloseHandle.argtypes = [w.HANDLE]
    snap = k.CreateToolhelp32Snapshot(2, 0)
    if snap == ctypes.c_void_p(-1).value:
        return []
    p = PROCESSENTRY32W()
    p.dwSize = ctypes.sizeof(p)
    result = []
    try:
        ok = k.Process32FirstW(snap, ctypes.byref(p))
        while ok:
            if p.szExeFile.lower() == 'rocksmith2014.exe':
                result.append(p.th32ProcessID)
            ok = k.Process32NextW(snap, ctypes.byref(p))
    finally:
        k.CloseHandle(snap)
    return result
