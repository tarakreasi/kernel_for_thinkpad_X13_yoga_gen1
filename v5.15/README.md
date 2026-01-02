# Kernel 5.15 LTS - Stability Reference

Kernel 5.15 acts as the baseline for stability on the ThinkPad X13 Yoga Gen 1. 

## Overview

Unlike newer kernels (6.x), 5.15 correctly handles the power management and firmware selection for the Comet Lake graphics chip out of the box, resulting in a flicker-free experience without modification.

However, since modern distributions (like Ubuntu 22.04/24.04) ship firmware compressed with Zstandard (`.zst`), which Kernel 5.15 cannot read, you must manually decompress these files for WiFi and Bluetooth to work.

## Solutions provided

### 1. Fix WiFi & Bluetooth (.zst Firmware Issue)

If your WiFi or Bluetooth is not detected, run the provided script to decompress the firmware files.

```bash
chmod +x fix_firmware.sh
sudo ./fix_firmware.sh
```

This script will:
- Install `zstd` if missing.
- Decompress Intel WiFi (`iwlwifi-*`) and Bluetooth (`ibt-*`) firmware in `/lib/firmware`.
- Update `initramfs`.

### 2. Fix Microphone

If your internal microphone is not detected or has low volume on Kernel 5.15, refer to the **[Microphone Fix Guide](./microphone_fix.md)**.

### 3. Screen Auto-Rotation Control

For 2-in-1 devices like the X13 Yoga, you might want to easily enable or disable the screen auto-rotation sensor (accelerometer).

```bash
chmod +x toggle_autorotate.sh
./toggle_autorotate.sh
```
This script toggles the rotation lock state.

## Contents

- **`fix_firmware.sh`**: Script to fix WiFi/Bluetooth by decompressing firmware.
- **`toggle_autorotate.sh`**: Script to toggle screen auto-rotation.
- **`microphone_fix.md`**: Manual guide specifically for audio issues.
- **`why_5.15.md`**: A detailed reflection on why using this older kernel is a valid pragmatic choice.

## Usage

Use this kernel if you prioritize stability over the newest features or if you are unable to patch newer kernels. Just ensure you run the firmware fix script after installing.
