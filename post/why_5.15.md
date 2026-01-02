# Why I Chose Kernel 5.15: A Pragmatic Decision

*Published: January 2, 2026*

In the world of Linux, there's often an unspoken pressure to run the latest kernel version. Newer is better, right? More features, better hardware support, improved performance. Yet here I am, deliberately running kernel 5.15 on my Lenovo ThinkPad X13 Yoga in 2026, and I want to explain why.

## The Flickering Problem

Let me start with the issue that drove this decision: **persistent screen flickering**.

After a few moments of inactivity—anywhere from 1.5 to 2 seconds—my screen would flicker. And not just once. It would happen continuously, immediately upon any interaction. Moving the mouse, typing, touching the screen—anything would trigger the flicker. This wasn't just annoying; it made the laptop genuinely difficult to use for extended periods.

For a machine that I rely on daily, this wasn't acceptable.

## The Search for Solutions

Like many Linux users facing hardware issues, I started down the familiar troubleshooting path:

### Attempt 1: Kernel Parameters
I tried the common Intel graphics fixes:
```bash
i915.enable_psr=0        # Disable Panel Self Refresh
intel_iommu=igfx_off     # Disable IOMMU for Intel graphics
i915.enable_fbc=0        # Disable framebuffer compression
intel_idle.max_cstate=4  # Limit C-states
```

These parameters helped in some cases I'd read about online. For my specific configuration, though, they only provided partial relief. The flickering reduced but never completely disappeared.

### Attempt 2: Different Kernel Versions
I experimented with newer kernels—5.19, 6.1, 6.2. Each promised better Intel graphics support. Each had the same flickering issue, sometimes even worse.

The Intel Comet Lake PCH-LP cAVS graphics on my ThinkPad seemed to have a particular quirk that newer kernels hadn't fully addressed.

### Attempt 3: Driver Alternatives
I explored different graphics stack configurations:
- Switched between Xorg and Wayland (both exhibited flickering)
- Tested different compositor settings
- Tried various display manager configurations

Nothing worked consistently.

## The Kernel 5.15 Discovery

Then I tried kernel 5.15.

The flickering stopped.

Completely.

No kernel parameters needed. No workarounds. No compromises. It just worked.

## Why 5.15 Specifically?

I'll be honest—I don't have a definitive technical explanation for why kernel 5.15 handles my specific hardware configuration better than newer versions. What I do know:

1. **It works**: The screen is stable, responsive, and flicker-free
2. **It's an LTS kernel**: Ubuntu's 5.15 kernel receives long-term support until April 2027
3. **It's well-tested**: By early 2026, this kernel has years of real-world usage and bug fixes
4. **Hardware compatibility**: For Comet Lake graphics, this version seems to have the right balance

## The Trade-offs

Am I giving up features by running an older kernel? Absolutely. Kernel 5.15 doesn't have:
- The latest hardware support for cutting-edge devices
- Some performance optimizations present in newer versions
- Newer security features (though security patches are backported to LTS)

But here's what I'm gaining:
- **A usable laptop**: No flickering means I can actually work
- **Stability**: A mature, well-tested kernel with known behaviors
- **Peace of mind**: I'm not constantly troubleshooting display issues

## The Pragmatic Philosophy

This experience reinforced an important lesson: **use what works for your specific hardware and use case**.

The Linux community often celebrates bleeding-edge technology, and that's wonderful. But there's equal value in stability and reliability. Running the latest kernel isn't always the right choice if it introduces instability on your particular hardware.

I've learned to be pragmatic rather than ideological about these decisions:

- Latest doesn't always mean best for your situation
- LTS kernels exist for good reasons
- Hardware compatibility trumps feature lists
- Your time is valuable—if something works, you don't need to "fix" it

## When I'll Upgrade

I'm not committed to kernel 5.15 forever. I'll consider upgrading when:

1. **The flickering is definitively fixed**: When I see reports or patches specifically addressing Comet Lake flickering issues in newer kernels
2. **LTS support ends**: As we approach 5.15's end-of-life in 2027
3. **Critical features are needed**: If I require hardware or software that absolutely needs a newer kernel
4. **Testing shows stability**: When I can verify in a test environment that newer kernels are stable on my hardware

Until then, kernel 5.15 is my daily driver.

## Lessons for Others

If you're facing similar hardware issues on Linux:

**Don't assume newer is better**: Sometimes older, more mature kernel versions handle specific hardware quirks better.

**LTS kernels are your friend**: They provide a stable base while still receiving security updates.

**Document your configuration**: Keep notes on what works. When troubleshooting, knowing your baseline is invaluable.

**Be willing to go against conventional wisdom**: If something works for you, that's what matters.

**Test thoroughly**: Before committing to a kernel version for daily use, test it extensively in your real workflow.

## The Reality of Hardware Support

Hardware support on Linux is incredible, but it's not perfect. Every hardware configuration is slightly different, and sometimes specific combinations just work better with certain kernel versions.

My Lenovo ThinkPad X13 Yoga is well-supported overall. The WiFi works, Bluetooth functions, the touchscreen is responsive, and the convertible form factor is properly recognized. But that screen flickering issue? It's specific, it's real, and it's solved in kernel 5.15.

That's good enough for me.

## Conclusion

Choosing kernel 5.15 wasn't about nostalgia or resistance to change. It was a practical decision based on real-world testing and prioritizing usability over version numbers.

In a field where we're often encouraged to chase the latest and greatest, there's something satisfying about finding the version that simply works and sticking with it.

Your mileage may vary. Your hardware is different. Your needs are different. But if you're struggling with hardware issues on newer kernels, don't hesitate to try an older, stable LTS version.

Sometimes the best solution is the one that lets you stop troubleshooting and start working.

---

*Running kernel 5.15.196-0515196-generic on Lenovo ThinkPad X13 Yoga with Intel Comet Lake PCH-LP cAVS graphics.*
