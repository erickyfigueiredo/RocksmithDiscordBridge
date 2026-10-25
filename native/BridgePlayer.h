#pragma once
#include <windows.h>
#include <cwchar>

namespace rsbridge {
// Called only during output initialization, never from the ASIO callback.
// Discord captures audio from the shared game and its child processes.
inline void StartAudioPlayer() noexcept {
    static volatile LONG launched = 0;
    if (InterlockedCompareExchange(&launched, 1, 0) != 0) return;
    wchar_t config[MAX_PATH] = {};
    if (!GetModuleFileNameW(nullptr, config, MAX_PATH)) return;
    wchar_t* separator = wcsrchr(config, L'\\');
    if (!separator) return;
    *(separator + 1) = 0;
    if (wcscat_s(config, L"RSBridgePlayer.txt") != 0) return;
    HANDLE file = CreateFileW(config, GENERIC_READ, FILE_SHARE_READ, nullptr, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, nullptr);
    if (file == INVALID_HANDLE_VALUE) return; // Explicit opt-in; existing installs unchanged.
    wchar_t path[MAX_PATH] = {};
    DWORD bytes = 0;
    const BOOL read = ReadFile(file, path, sizeof(path) - sizeof(wchar_t), &bytes, nullptr);
    CloseHandle(file);
    if (!read || !bytes || bytes % sizeof(wchar_t)) return;
    size_t length = wcslen(path);
    while (length && (path[length-1] == L'\r' || path[length-1] == L'\n')) path[--length] = 0;
    if (!length || wcschr(path, L'"') || GetFileAttributesW(path) == INVALID_FILE_ATTRIBUTES) return;
    wchar_t command[1024] = {};
    swprintf_s(command, L"\"%s\" --auto-start --audio-only --parent-pid %lu", path, GetCurrentProcessId());
    STARTUPINFOW startup = {};
    startup.cb = sizeof(startup);
    startup.dwFlags = STARTF_USESHOWWINDOW;
    startup.wShowWindow = SW_HIDE;
    PROCESS_INFORMATION process = {};
    if (CreateProcessW(path, command, nullptr, nullptr, FALSE, CREATE_NO_WINDOW, nullptr, nullptr, &startup, &process)) {
        CloseHandle(process.hThread);
        CloseHandle(process.hProcess);
    } else {
        InterlockedExchange(&launched, 0);
    }
}
}
