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

## 📖 Kisah Perjalanan & Debugging

Dokumentasi lengkap mengenai _"Why & How"_ di balik solusi ini dapat dibaca di folder `post/`:

1. [**Awal Mula: Frustrasi dengan Flicker**](post/post1_awal_mula.md) - Mengapa kernel bawaan Ubuntu tidak cukup.
2. [**Diagnosa Mendalam**](post/post2_diagnosa_mendalam.md) - Menelusuri masalah i915, PSR, dan FBC.
3. [**Solusi Permanen**](post/post3_solusi_permanen.md) - Cara hardcode driver untuk mematikan fitur bermasalah.
4. [**Bonus: Debugging Rotasi & Suara**](post/story_debugging_autorotate_sound.md) - (Baru!) Perjuangan memperbaiki layar blank saat dilipat dan verifikasi audio di Kernel 6.14.

## 🚀 Cara Install (All-in-One)

Kami telah menyederhanakan proses instalasi menjadi satu script utama untuk Kernel 6.14 OEM.

**Jalankan:**
```bash
chmod +x setup_x13.sh
sudo ./setup_x13.sh
```

Script ini akan otomatis:
1. Menginstall Kernel Linux OEM 6.14.
2. Mengkonfigurasi GRUB (parameter anti-flicker).
3. Memperbaiki setting Audio (disable power save).
4. Memberi petunjuk langkah selanjutnya.

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
