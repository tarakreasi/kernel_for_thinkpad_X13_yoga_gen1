# ThinkPad X13 Yoga Gen 1 Kernel Fixes

**Repository**: [github.com/tarakreasi/kernel_for_thinkpad_X13_yoga_gen1](https://github.com/tarakreasi/kernel_for_thinkpad_X13_yoga_gen1)

This repository documents the journey and technical solutions for running Linux on the Lenovo ThinkPad X13 Yoga Gen 1 (Intel Comet Lake architecture).

It addresses specific hardware challenges on both LTS (5.15) and newer OEM (6.14) kernels.

## ✅ Feature Support Matrix

| Feature | Kernel 5.15 (LTS) | Kernel 6.14 (OEM) |
| :--- | :--- | :--- |
| **Screen Flicker** | ✅ Stable (Native) | ✅ **FIXED** (Patched i915) |
| **WiFi / Bluetooth** | ⚠️ Needs Fix (Old Kernel vs New Firmware) | ✅ Native |
| **Microphone** | ⚠️ Needs Fix (ALSA Config) | ✅ Native |
| **Auto-Rotation** | ⚠️ Needs Script | ⚠️ Needs Script (Desktop dependent) |
| **Performance** | 🟡 Standard | 🟢 Optimized |

## Repository Structure

### [v6.14_OEM](./v6.14_OEM/) (The Modern Approach)
Contains the solution for the **Screen Flickering** issue on Kernel 6.14 OEM.
- **Problem**: Persistent screen flickering due to checking wrong firmware (KBL instead of CNL) and aggressive SAGV.
- **Fix Included**:
    - **`build_properly.sh`**: Rebuilds the i915 driver matching the exact running kernel configuration (fixes ABI mismatch).
    - **`install_custom_i915.sh`**: Installs the patched driver.
    - **`agnostic_check.sh`**: Verifies driver loading and Secure Boot status.
    - **`budgie_autorotate.sh`**: Fixes rotation on Budgie/X11 desktops.

### [v5.15](./v5.15/) (The Stability Baseline)
Contains fixes for running the older stable kernel on modern distros.
- **Fix Included**:
    - **`fix_firmware.sh`**: Decompresses `.zst` firmware for WiFi/BT support.
    - **`fix_microphone.sh`**: Fixes internal mic issues.
    - **`toggle_autorotate.sh`**: Simple rotation toggle.

## Author
**T. Wantoro** (tarakreasi.com)
Email: ajarsinau@gmail.com
