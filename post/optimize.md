# Optimizing the "Perfect" Stable Kernel: The Hidden .zst Issue

*Published: January 2, 2026*

In my previous post, I explained why I deliberately chose Kernel 5.15 for my Lenovo ThinkPad X13 Yoga: it was the only version that completely solved the persistent screen flickering issue involving the Intel Comet Lake graphics.

However, choosing an older kernel on a modern Linux distribution (like Ubuntu 22.04/24.04) comes with a hidden trade-off. It’s not about features—it’s about **file formats**.

## The Hidden Problem: Compressed Firmware

Modern Linux distributions have started compressing firmware files to save disk space. The standard format used is **Zstandard (.zst)**.

Here is the conflict:
1.  **Modern Distros**: Pack thousands of firmware files as `.bin.zst` or `.tplg.zst`.
2.  **Kernel 5.15**: Does **not** support loading Zstd-compressed firmware directly. It expects uncompressed raw files.

This creates a silent failure. The kernel tries to load firmware, can't find the uncompressed version, and gives up. It usually doesn't crash the system; it just disables advanced features.

## The Impact on the ThinkPad X13 Yoga

On my ThinkPad, this "silent failure" hit two critical areas:

### 1. Power Management (The i915 DMC Issue)
The graphics driver (i915) needs a **Display Microcontroller (DMC)** firmware to handle low-power states when the screen is idle.

*   **Symptom**: The kernel logs showed:
    `Direct firmware load for i915/kbl_dmc_ver1_04.bin failed with error -2`
*   **Result**: The system disabled "Runtime Power Management". This means the GPU couldn't fully sleep, leading to significantly higher battery drain and a warmer laptop, even when doing nothing.

### 2. Microphone Functionality (The SOF Issue)
The audio system (Sound Open Firmware) couldn't load its topology file because it was compressed.

*   **Symptom**: No input devices detected.
*   **Result**: The microphone simply didn't exist to the OS.

## The Solution: Manual Decompression

The fix is surprisingly simple: we just need to decompress the specific files the kernel is looking for. We don't need to decompress everything (there are over 3,000 firmware files!), just the ones our hardware needs.

### Step-by-Step Optimization

I have identified the exact files needed for the ThinkPad X13 Yoga (Comet Lake) and created a script to handle them.

#### The Quick Fix
I created a script called `optimize_thinkpad.sh` that checks for the existence of these compressed files and extracts them to the raw format kernel 5.15 expects.

```bash
# optimize_thinkpad.sh

# 1. Fix Graphics Power Management (i915 DMC)
# Decompresses CNL (Cannon Lake) and KBL (Kaby Lake) firmware
sudo zstd -d /lib/firmware/i915/cnl_dmc_ver1_07.bin.zst -o /lib/firmware/i915/cnl_dmc_ver1_07.bin
sudo zstd -d /lib/firmware/i915/kbl_dmc_ver1_04.bin.zst -o /lib/firmware/i915/kbl_dmc_ver1_04.bin

# 2. Fix Microphone (SOF Topology)
sudo zstd -d /lib/firmware/intel/sof-tplg/sof-hda-generic-2ch.tplg.zst \
    -o /lib/firmware/intel/sof-tplg/sof-hda-generic-2ch.tplg
```

After running this and rebooting, the difference is immediate:
*   **dmesg** shows: `[drm] DMC firmware loaded successfully`
*   **Power usage** drops as the GPU enters deeper sleep states (DC5/DC6).
*   **Microphone** is detected and works perfectly.

## Why This Matters

This optimization gives us the "Holy Grail" for this specific laptop:
1.  **Stability**: Zero screen flickering (thanks to Kernel 5.15).
2.  **Efficiency**: Full power management enabled (thanks to decompressed firmware).
3.  **Functionality**: Fully working audio and sensors.

Sometimes, sticking with older, stable software requires a little bit of manual intervention to make it play nice with modern packaging. But for a stable, flicker-free, and battery-efficient daily driver, it is absolutely worth it.

---
*Note: If you update your `linux-firmware` package in the future, you may need to re-run the decompression commands.*
