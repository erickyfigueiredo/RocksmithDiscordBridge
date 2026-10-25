#pragma once
// MIT License. New bridge code; upstream RS_ASIO retains its original license.
// Windows x86/x64 only. One writer; readers never hold a lock needed by ASIO.
#include <windows.h>
#include <mmreg.h>
#include <cstdint>
#include <cstring>
#include <cstddef>
#ifdef RSBRIDGE_CHILD_PLAYER
#include "BridgePlayer.h"
#endif

namespace rsbridge {
constexpr uint32_t Magic = 0x31425352; // RSB1
constexpr uint32_t Capacity = 32;
constexpr uint32_t Payload = 65536;
struct Header {
    uint32_t magic, version;
    volatile LONG published;
    uint32_t rate, channels, bits, floating, blockAlign, capacity, payload, pid;
    uint32_t reserved[5];
};
struct Slot {
    volatile LONG stamp;
    uint32_t frames;
    BYTE data[Payload];
};
struct Shared { Header header; Slot slots[Capacity]; };
static_assert(sizeof(Header) == 64, "Wire header layout changed");
static_assert(sizeof(Slot) == Payload + 8, "Wire slot layout changed");
static_assert(offsetof(Header, published) == 8, "Atomic must be aligned");

class Tap {
    HANDLE mapping_ = nullptr;
    Shared* shared_ = nullptr;
    uint32_t sequence_ = 0;
    uint32_t align_ = 0;
    uint32_t generation_ = 0;
public:
    Tap() = default;
    Tap(const Tap&) = delete;
    Tap& operator=(const Tap&) = delete;
    ~Tap() { Close(); }
    void Close() noexcept {
        if (shared_) UnmapViewOfFile(shared_);
        if (mapping_) CloseHandle(mapping_);
        shared_ = nullptr; mapping_ = nullptr; sequence_ = 0;
    }
    // Called on the control thread, BEFORE starting ASIO callbacks.
    bool Initialize(const WAVEFORMATEX& format, bool floating, uint32_t maxFrames) noexcept {
        Close();
        if (format.nSamplesPerSec != 48000 || format.nChannels != 2 ||
            (format.wBitsPerSample != 16 && format.wBitsPerSample != 24 && format.wBitsPerSample != 32) ||
            (floating && format.wBitsPerSample != 32) ||
            format.nBlockAlign != format.nChannels * (format.wBitsPerSample / 8) ||
            !maxFrames || maxFrames > Payload / format.nBlockAlign) return false;
        wchar_t name[96];
        wsprintfW(name, L"Local\\RSASIO_Bridge_v1_%lu", GetCurrentProcessId());
        mapping_ = CreateFileMappingW(INVALID_HANDLE_VALUE, nullptr, PAGE_READWRITE, 0, sizeof(Shared), name);
        if (!mapping_) return false;
        const bool existed = GetLastError() == ERROR_ALREADY_EXISTS;
        shared_ = static_cast<Shared*>(MapViewOfFile(mapping_, FILE_MAP_WRITE, 0, 0, sizeof(Shared)));
        if (!shared_) { Close(); return false; }
        if (existed && shared_->header.pid != GetCurrentProcessId()) { Close(); return false; }
        // A receiver may still hold the previous mapping when the game reopens its output.
        generation_ = existed ? shared_->header.reserved[0] + 1 : 1;
        if (!generation_) generation_ = 1;
        InterlockedExchange(reinterpret_cast<volatile LONG*>(&shared_->header.magic), 0);
        // Touch every page here, not in the audio callback.
        // Do not zero the header here: keeping the generation until the final update
        // lets readers recognize an initialization interrupted halfway through.
        std::memset(shared_->slots, 0, sizeof(shared_->slots));
        auto& h = shared_->header;
        h.published = 0;
        h.version = 1; h.rate = format.nSamplesPerSec; h.channels = format.nChannels;
        h.bits = format.wBitsPerSample; h.floating = floating ? 1 : 0;
        h.blockAlign = align_ = format.nBlockAlign;
        h.capacity = Capacity; h.payload = Payload; h.pid = GetCurrentProcessId();
        h.reserved[0] = generation_;
        MemoryBarrier();
        InterlockedExchange(reinterpret_cast<volatile LONG*>(&h.magic), Magic);
#ifdef RSBRIDGE_CHILD_PLAYER
        StartAudioPlayer();
#endif
        return true;
    }
    // Fixed, bounded copy. No allocation, wait, socket, file I/O, Python or reader handshake.
    // Overwrites old packets if the receiver is slow; the game never waits for it.
    void Publish(const BYTE* data, uint32_t frames) noexcept {
        if (!shared_ || !data || !frames || frames > Payload / align_ ||
            shared_->header.magic != Magic || shared_->header.reserved[0] != generation_) return;
        const uint32_t seq = ++sequence_;
        auto& slot = shared_->slots[(seq - 1) % Capacity];
        InterlockedExchange(&slot.stamp, static_cast<LONG>((seq << 1) | 1));
        slot.frames = frames;
        std::memcpy(slot.data, data, frames * align_);
        MemoryBarrier();
        InterlockedExchange(&slot.stamp, static_cast<LONG>(seq << 1));
        InterlockedExchange(&shared_->header.published, static_cast<LONG>(seq));
    }
};
}
