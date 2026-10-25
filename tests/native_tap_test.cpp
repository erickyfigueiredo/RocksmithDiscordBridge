#include "../native/BridgeTap.h"
#ifdef NDEBUG
#undef NDEBUG
#endif
#include <cassert>
#include <iostream>

int main(int argc, char** argv) {
    WAVEFORMATEX f = {};
    f.wFormatTag = WAVE_FORMAT_PCM; f.nChannels = 2; f.nSamplesPerSec = 48000;
    f.wBitsPerSample = 16; f.nBlockAlign = 4; f.nAvgBytesPerSec = 192000;
    rsbridge::Tap tap;
    assert(tap.Initialize(f, false, 512));
    if (argc == 2 && std::strcmp(argv[1], "--producer") == 0) {
        short samples[1024];
        for (int i = 0; i < 1024; i += 2) { samples[i] = 16384; samples[i+1] = -16384; }
        std::cout << GetCurrentProcessId() << std::endl;
        Sleep(500);
        for (int i = 0; i < 300; ++i) {
            tap.Publish(reinterpret_cast<const BYTE*>(samples), 512);
            Sleep(10);
        }
        return 0;
    }
    wchar_t name[96];
    wsprintfW(name, L"Local\\RSASIO_Bridge_v1_%lu", GetCurrentProcessId());
    HANDLE h = OpenFileMappingW(FILE_MAP_READ, FALSE, name);
    assert(h);
    auto* s = static_cast<const rsbridge::Shared*>(MapViewOfFile(h, FILE_MAP_READ, 0, 0, sizeof(rsbridge::Shared)));
    assert(s && s->header.magic == rsbridge::Magic && s->header.rate == 48000);
    assert(s->header.published == 0);
    short data[] = {16384, -16384, 0, 32767};
    tap.Publish(reinterpret_cast<const BYTE*>(data), 2);
    assert(s->header.published == 1 && s->slots[0].stamp == 2 && s->slots[0].frames == 2);
    assert(std::memcmp(s->slots[0].data, data, sizeof(data)) == 0);
    tap.Publish(reinterpret_cast<const BYTE*>(data), 999999); // oversized reads must be rejected
    assert(s->header.published == 1);
    for (int i = 0; i < 100; ++i) tap.Publish(reinterpret_cast<const BYTE*>(data), 2);
    assert(s->header.published == 101);
    assert(s->slots[100 % rsbridge::Capacity].stamp == 202);
    // Leave the reader attached while the game reopens its audio output.
    const auto previousGeneration = s->header.reserved[0];
    tap.Close();
    assert(tap.Initialize(f, false, 512));
    assert(s->header.reserved[0] == previousGeneration + 1 && s->header.published == 0);
    tap.Publish(reinterpret_cast<const BYTE*>(data), 2);
    assert(s->header.published == 1);
    UnmapViewOfFile(s); CloseHandle(h); tap.Close();
    f.nSamplesPerSec = 44100;
    assert(!tap.Initialize(f, false, 512));
    f.nSamplesPerSec = 48000; f.nBlockAlign = 0;
    assert(!tap.Initialize(f, false, 512));
    tap.Publish(nullptr, 512); // disabled tap is harmless
    std::cout << "Native ring layout, payload, bounds and overrun: PASS\n";
}
