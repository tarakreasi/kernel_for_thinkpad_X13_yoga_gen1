# Debugging Story: Blank Screen on Rotation & Sound Mystery

*Written by T. Wantoro*

It felt like victory was already in hand. Kernel 6.14 OEM was installed, the *screen flickering* that had been haunting me was completely cured thanks to the manual i915 patch. The laptop felt smooth, performance was fast.

Confidently, I folded my ThinkPad X13 Yoga screen into tablet mode.

**Instantly, the screen went black.**

My heart sank. Was it a kernel panic? Did the GPU crash again? But the keyboard backlight was still on. I tried `Alt+F2` and typed `r` (restart shell), no reaction. Hard reset.

## Part 1: The Deadly Rotation Mystery

After rebooting, I tried to analyze. The problem only appeared when the laptop was *physically* rotated/folded. The accelerometer sensor worked, sending signals to the OS, the OS tried to rotate the display, and... *blank*.

### Main Suspect: Budgie Desktop vs New Kernel
On the old 5.15 kernel, rotation was a bit slow but safe. On 6.14, it seems the new graphics driver (especially with *fbc* and *psr* that we tweaked) didn't play nicely with how the compositing window manager (Mutter/Budgie) handled instant rotation.

I dug into the `journalctl` logs:
```text
mutter[...]: commons: monitor ... output assignment failed
```
It turned out that when physical rotation occurred, the resolution and orientation changed abruptly, and somehow the video output "disconnected" for a moment causing a permanent *black screen* in the user session.

### Solution: The Middleman Script (`budgie_autorotate.sh`)
Instead of letting the OS rotate "barbarically", I created a hybrid python/bash script that:
1. Reads the monitor-sensor-proxy.
2. *Gracefully* commands `xrandr` to rotate the screen.
3. Simultaneously rotates touchscreen and stylus (Wacom) input so the cursor doesn't get "lost".

The result? Rotation is now smooth. It does need a 1-second delay, but it's far better than having to hard reset every time I want to read a comic in portrait mode.

## Part 2: Sound Verification (Sound & Mic)

Traumatized by kernel 5.15 where the microphone needed `snd_hda_intel dmic_detect=0` or complex patches, I prepared for war again for audio.

I opened *Sound Settings*. Output: **Speaker**. Input: **Microphone Array**.
I tried playing a song on YouTube. Sound came out clear.
I tried recording voice. Sound waves registered.

Wait, **that's it?**

Apparently, Kernel 6.14 OEM brings a **Sound Open Firmware (SOF)** driver that is much more mature for the Intel Comet Lake (CNL) chipset compared to old kernels. On kernel 5.15, the SOF driver often crashed or failed to load DSP topology. On 6.14, "it just works".

The only small tweak I added was disabling *audio power save* which was too aggressive, sometimes causing a "pop" sound when the speaker just started:
```bash
options snd_hda_intel power_save=0 power_save_controller=N
```
I included this in `setup_x13.sh` as well to ensure a premium experience.

## Conclusion

This migration journey to Kernel 6.14 OEM taught one thing: **New Hardware needs New Software**.
Forcing an LTS kernel (5.15) on (relatively) modern hardware like the X13 Yoga turned out to be more *pain* than *gain*. The rotation issue was just a small configuration *hiccup* of the desktop environment, not a kernel panic. And the bonus? Native audio without hacks!

This ThinkPad X13 Yoga is now truly "Complete".
