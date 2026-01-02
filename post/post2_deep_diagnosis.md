# Taming the Screen Flicker: Part 2 - Deep Diagnosis

*Published: January 2, 2026*

After standard mitigation attempts via kernel parameters failed to produce satisfactory results, I realized this issue demanded a more serious investigation. The *trial-and-error* approach had to be replaced with forensic analysis. The key question was: **What is the fundamental difference between kernel 5.15 (stable) and kernel 6.14 (problematic) on this specific hardware?**

I decided to dive into system logs and kernel source code to find the answer.

## Finding 1: Mistaken Identity (Firmware Mismatch)

The first step was comparing the kernel initialization logs (`dmesg`) of both versions. A critical difference was immediately apparent in how the graphics driver recognized and loaded the *Display Microcontroller* (DMC) firmware.

This ThinkPad X13 Yoga laptop is powered by an **Intel Comet Lake (CML)** processor.

*   **On Kernel 5.15**: The driver correctly loaded **Cannon Lake (CNL)** firmware: `cnl_dmc_ver1_07.bin`, which is compatible with this laptop's graphics architecture.
*   **On Kernel 6.14**: A regression occurred. The driver incorrectly identified the graphics as **Kaby Lake (KBL)** and loaded the older `kbl_dmc_ver1_04.bin` firmware.

This was a significant finding. Kernel 6.14 was having an "identity crisis", treating the modern Comet Lake processor as an older Kaby Lake variant, thus loading suboptimal microcontroller instructions.

## Finding 2: An "Overzealous" SAGV

Besides the firmware mismatch, I checked an advanced power management feature that is often overlooked: **SAGV (System Agent Geyserville)**. This feature allows the system to dynamically adjust the frequency and voltage of the *System Agent* (including the memory controller) based on workload.

Checking the status in kernel 6.14 showed:

```bash
sudo cat /sys/module/i915/parameters/enable_sagv
# Output: Y (Yes/True)
```

In various technical literature and Intel kernel developer discussions, SAGV is often identified as a source of display instability on Gen9.5 integrated graphics. Aggressive voltage changes when the system is *idle* can disrupt the signal to the display panel, causing flickering exactly like what I was experiencing.

## Working Hypothesis

Based on that data, I formulated two main hypotheses for the cause of the problem:

1.  **Wrong Firmware**: Using Kaby Lake DMC firmware on Comet Lake hardware caused out-of-sync display power management.
2.  **SAGV Aggressiveness**: This memory power-saving feature was too aggressive for this laptop panel's tolerance, causing signal instability when *idle*.

The problem is, changing the `enable_sagv` parameter and `dmc_firmware_path` is often ineffective if done only via GRUB (user-space). The `i915` driver has internal initialization logic that frequently ignores external parameters for vital configurations like this.

If the "soft way" (configuration) is ignored by the kernel, then I have to take the "hard way": **modifying the driver logic itself.**

*(Continued in Part 3)*
