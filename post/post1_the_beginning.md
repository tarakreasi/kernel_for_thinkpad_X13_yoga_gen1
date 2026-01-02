# taming the Screen Flicker: Part 1 - The Beginning

*Published: January 2, 2026*

In the Linux world, we are often faced with a dilemma: stick with a stable, older kernel ("Long Term Support" or LTS), or switch to the latest kernel offering cutting-edge features but full of surprises. For a long time, I was a loyal user of **Kernel 5.15**.

## Why I Left the Comfort Zone of 5.15?

Previously, in the article "Why I Chose Kernel 5.15", I explained my pragmatic decision to stay on that version at length. On my Lenovo ThinkPad X13 Yoga, kernel 5.15 provided irreplaceable stability—"it just works". No screen flicker, solid power management, and mature hardware compatibility.

However, technology never stops moving. The desire for better battery efficiency and maximum support for the 2026 software ecosystem pushed me out of my comfort zone. I decided to install **OEM Kernel 6.14**.

The hope was simple: get maximum performance without sacrificing basic functionality. However, reality is often different from expectations.

## The Problem: Persistent Screen Flickering

Immediately after switching to kernel 6.14, I was "welcomed" back by an old problem that was the main reason I stayed on 5.15: **persistent screen flickering**.

The symptoms were very specific and consistent, exactly like the nightmare I experienced before:
1.  **Time Pattern**: The flickering didn't happen randomly. It appeared after the system was *idle* for about 1.5 to 2 seconds.
2.  **Interaction Trigger**: Immediately after any input—moving the cursor, typing, or touching the screen—the screen would flicker violently.
3.  **Usage Impact**: This wasn't just a minor visual annoyance. This "flirty" flickering, like a broken neon light, made the laptop almost impossible to use for long-term productivity without causing a headache.

For a "daily driver" machine, this condition was clearly unacceptable.

## Initial Investigation and Conventional Attempts

Like any Linux user encountering Intel graphics issues, I started the diagnosis with standard steps that have become a "mantra" in various community forums.

### Attempt 1: Standard Kernel Parameters

The main suspect in this case is almost always related to aggressive power-saving features of the Intel driver. I tried applying classic solutions via GRUB parameters:

```bash
i915.enable_psr=0        # Disable Panel Self Refresh
intel_iommu=igfx_off     # Disable IOMMU for Intel graphics
i915.enable_fbc=0        # Disable Frame Buffer Compression
intel_idle.max_cstate=4  # Limit CPU C-states
```

Theoretically, disabling *Panel Self Refresh* (PSR) and *Frame Buffer Compression* (FBC) is the de facto solution. However, on kernel 6.14, the impact was minimal. The flicker frequency might have reduced slightly, but the main issue persisted.

### Attempt 2: System Verification

Not wanting to just guess, I verified if those parameters were actually applied by the system:

```bash
sudo cat /sys/module/i915/parameters/enable_psr # Output: 0
sudo cat /sys/module/i915/parameters/enable_fbc # Output: 0
```

The verification results showed `0`—meaning those features were indeed disabled. Logically, if the problematic features were off, the screen should be stable. The fact that flickering continued indicated a fundamental change in how kernel 6.14 handles Intel Comet Lake graphics *power management*, which is drastically different from the "calm and cool" behavior in kernel 5.15.

## Turning Point: Realizing the Complexity

This is where I realized that user-space configuration solutions were no longer adequate. Something had changed behind the scenes—a regression or architectural change in the `i915` driver in the new kernel that rendered standard configurations ineffective.

I was faced with two choices:
1.  **Retreat**: Reinstall kernel 5.15 and enjoy stability without new features (a very tempting option).
2.  **Escalate**: Dissect the kernel itself, understand its source code, and force it to work the way I wanted.

With the spirit of "why make it easy if it can be hard" (and the need for new features), I chose the second option. I concluded that I needed to take more drastic action than just editing GRUB: **recompiling the kernel module with hardcoded parameters**.

In the next part, I will document the build environment preparation steps to perform this "surgery" on the kernel.

*(Continued in Part 2)*

---
*Daring to take the risk of a new kernel means being ready for the consequences of late-night debugging.*
