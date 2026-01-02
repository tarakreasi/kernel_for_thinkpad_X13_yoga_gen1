# Taming the Screen Flicker: Part 3 - Permanent Solution

*Published: January 2, 2026*

When soft configurations no longer work and the system refuses to "obey", an *engineer* has one ultimate option: **Change the code.**

The decision to perform *patching* and recompile the kernel module is not taken lightly. However, for the sake of regaining the stability of kernel 5.15 while keeping the modern features of kernel 6.14, this is a price worth paying.

## Code Surgery

My target for surgery was the Intel i915 driver within the kernel source tree. I performed two surgical modifications to address the root causes found in the diagnosis phase.

### 1. Silencing SAGV Forcibly

Target File: `drivers/gpu/drm/i915/display/intel_display_params.h`

I modified the definition of the `enable_sagv` parameter to disable this feature *hardcoded* at the default driver level.

```c
// Original Code:
param(bool, enable_sagv, true, 0600) \

// Modified Code:
param(bool, enable_sagv, false, 0600) \
```

With this change, the driver will always initialize with SAGV disabled, eliminating potential signal interference from system agent voltage fluctuations.

### 2. Straightening Out Firmware Logic

Target File: `drivers/gpu/drm/i915/display/intel_dmc.c`

To fix the "identity crisis" in kernel 6.14, I inserted new conditional logic. The goal was firm: force the kernel to load Cannon Lake (CNL) firmware if it detects Comet Lake (CML) hardware, instead of falling back to Kaby Lake.

```c
// 1. Define the correct firmware path
#define CNL_DMC_PATH DMC_LEGACY_PATH(cnl, 1, 07)
MODULE_FIRMWARE(CNL_DMC_PATH);

// ... inside intel_dmc_init function ...

} else if (IS_COMETLAKE(i915)) {
    // Override: Force load CNL firmware for Comet Lake
    fw_path = CNL_DMC_PATH;
    max_fw_size = KBL_DMC_MAX_FW_SIZE;
} else if (IS_KABYLAKE(i915) || ...
```

## Result: Return of Stability

After a fairly time-consuming module compilation process (and overcoming some build dependency hurdles), I installed the modified (`custom`) `i915` module and *rebooted*.

The moment of truth arrived.

1.  **Firmware Verification**: System logs now proudly reported: **"Finished loading DMC firmware i915/cnl_dmc_ver1_07.bin"**. The kernel finally recognized the hardware identity correctly.
2.  **Parameter Verification**: SAGV status confirmed as **N (Off)** by default.
3.  **Stability Test**: I let the laptop sit *idle*. 5 minutes. 10 minutes. I moved the cursor. I typed.

**Silence. Stable. Perfect.**

No more flickering. The laptop screen is now as calm and stable as when I used kernel 5.15, but with the bonus performance and efficiency of kernel 6.14. So far, OEM kernel 6.14 with this custom patch is running extremely well.

## Conclusion

This journey taught that in an *open source* ecosystem like Linux, we never really hit a dead end. "Incompatibility" is often just code that hasn't been adapted to our specific needs.

With a little courage to dissect and understand how the system works, we can get the best of both worlds: the stability of the past and the technology of the future.

---
*Custom Build OEM Kernel 6.14 is now the new "daily driver" on my ThinkPad X13 Yoga.*
