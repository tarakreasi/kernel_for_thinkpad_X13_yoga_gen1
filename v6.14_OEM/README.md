# Kernel 6.14 OEM - Screen Flicker Fix

This directory contains the patch and documentation for fixing the screen flicker issue on ThinkPad X13 Yoga (Comet Lake) running Kernel 6.14 OEM.

## The Solution

The fix involves modifying the `i915` driver source code to:
1.  **Force Disable SAGV**: Hardcodes `enable_sagv` to `false`.
2.  **Force Correct Firmware**: Forces the driver to load Cannon Lake (CNL) DMC firmware instead of the incorrect Kaby Lake (KBL) fallback.

## Directory Contents

- **`src/`**: Contains the modified C source files.
    - `intel_display_params.h`: Modified to default `enable_sagv` to false.
    - `intel_dmc.c`: Modified to enforce CNL firmware for Comet Lake.
- **`docs/`**: A 3-part detailed blog post series explaining the journey:
    - [Part 1: The Beginning](./docs/post1_awal_mula.md)
    - [Part 2: Deep Diagnosis](./docs/post2_diagnosa_mendalam.md)
    - [Part 3: Permanent Solution](./docs/post3_solusi_permanen.md)
- **`build_properly.sh`**: Critical script to build the module using the **exact configuration** of the running kernel. Prevents "module loading errors" due to config mismatch.
- **`agnostic_check.sh`**: Diagnostic tool to verify if the i915 driver is loaded correctly or blocked by Secure Boot.
- **`install_custom_i915.sh`**: Helper script used to install the built module.
- **`budgie_autorotate.sh`**: Auto-rotation script for Desktop Environments (like Budgie) that don't support it natively. Rotates screen and touchscreen input.

## Usage

### 1. Install Kernel Fix
To apply this fix, you need the kernel source for your specific version. Replace the files in `drivers/gpu/drm/i915/display/` with the files in `src/`, then recompile the `i915` module.

### 2. Enable Auto-Rotate (Budgie/Others)
If your desktop doesn't rotate automatically:
```bash
./budgie_autorotate.sh
```
Add this script to your "Startup Applications" to make it permanent.
