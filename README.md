# ThinkPad X13 Yoga Gen 1 Kernel Fixes

**Repository**: [github.com/tarakreasi/kernel_for_thinkpad_X13_yoga_gen1](https://github.com/tarakreasi/kernel_for_thinkpad_X13_yoga_gen1)

This repository documents the journey and technical solutions for running Linux on the Lenovo ThinkPad X13 Yoga Gen 1 (Intel Comet Lake architecture).

It addresses specific hardware challenges on both LTS (5.15) and newer OEM (6.14) kernels.

> [!IMPORTANT]
> **Update (Jan 2026):** We have decided to **revert to Kernel 5.15 (LTS)** as the daily driver. Despite extensive patching, the generic Screen Flickering issue on Kernel 6.14 OEM persists and remains unstable for daily use.

## ✅ Feature Support Matrix

| Feature | Kernel 5.15 (LTS) | Kernel 6.14 (OEM) |
| :--- | :--- | :--- |
| **Screen Flicker** | ✅ Stable (Native) | ❌ **UNSTABLE** (Persists) |
| **WiFi / Bluetooth** | ⚠️ Needs Fix (Old Kernel vs New Firmware) | ✅ Native |
| **Microphone** | ⚠️ Needs Fix (ALSA Config) | ✅ Native |
| **Auto-Rotation** | ⚠️ Needs Script | ⚠️ Needs Script (Desktop dependent) |
| **Performance** | 🟡 Standard | 🟢 Optimized |

## 🚀 Cara Install (Recommended: Kernel 5.15)

Mengingat isu flickering yang masih ada di Kernel 6.14, kami sangat menyarankan untuk menggunakan **Kernel 5.15** untuk stabilitas maksimal.

### Langkah 1: Install Kernel 5.15
Pastikan Anda menggunakan Ubuntu 22.04 LTS atau distro yang mendukung kernel 5.15 LTS.

### Langkah 2: Apply Fixes
Jalankan script untuk memperbaiki WiFi/BT dan Microphone pada kernel 5.15:

```bash
cd v5.15
sudo ./fix_firmware.sh
sudo ./fix_microphone.sh
```

*(Catatan: Script `setup_x13.sh` untuk 6.14 masih tersedia untuk keperluan testing/development, namun tidak disarankan untuk daily driver saat ini)*

---

## 📂 Repository Structure

### Root
- **`setup_x13.sh`**: Script utama untuk setup otomatis.

### [v6.14_OEM](./v6.14_OEM/) (The Modern Approach)
Contains the solution for the **Screen Flickering** issue on Kernel 6.14 OEM.
- **Problem**: Persistent screen flickering due to checking wrong firmware (KBL instead of CNL) and aggressive SAGV.
- **Fix Included**:
    - **`build_properly.sh`**: Rebuilds the i915 driver matching the exact running kernel configuration.
    - **`install_custom_i915.sh`**: Installs the patched driver.
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
