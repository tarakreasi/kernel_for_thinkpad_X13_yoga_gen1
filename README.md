# ThinkPad X13 Yoga Gen 1 Kernel Fixes

This repository documents the journey and technical solutions for running Linux on the Lenovo ThinkPad X13 Yoga Gen 1 (features Intel Comet Lake architecture).

It specifically addresses the persistent **screen flickering issue** on newer kernels and provides a comparison with the stable 5.15 LTS kernel.

## Repository Structure

### [v6.14_OEM](./v6.14_OEM/)
Contains the solution for the **Screen Flickering** issue on Kernel 6.14 OEM.
- **Problem**: Persistent screen flickering when the device is idle or upon input interaction.
- **Root Cause**: Incorrect firmware selection (loading Kaby Lake DMC instead of Cannon Lake) and aggressive SAGV (System Agent Geyserville) power saving.
- **Solution**: Patched kernel module (`i915`) with hardcoded fixes.
- **Contents**: 
    - Full technical documentation (Trilogy of blog posts).
    - Patched source code files.
    - Installation script.

### [v5.15](./v5.15/)
Contains documentation for the "Gold Standard" stability on this device.
- **Status**: Stable, no flickering out-of-the-box.
- **Notes**: Requires specific configuration for Microphone support.
- **Contents**:
    - "Why 5.15" architecture analysis.
    - Microphone fix guide.

## Author
**T. Wantoro**
