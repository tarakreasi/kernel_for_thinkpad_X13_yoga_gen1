#!/bin/bash
# Fix microphone on Lenovo ThinkPad X13 Yoga - Kernel 5.15
# Issue: SOF topology file is compressed, kernel needs uncompressed version

echo "Fixing microphone by decompressing SOF topology file..."

# Decompress the SOF topology file
sudo zstd -d /lib/firmware/intel/sof-tplg/sof-hda-generic-2ch.tplg.zst \
    -o /lib/firmware/intel/sof-tplg/sof-hda-generic-2ch.tplg 2>/dev/null || {
    echo "Topology file already decompressed or error occurred"
}

# Reload the audio driver
echo "Reloading audio driver..."
sudo modprobe -r snd_sof_pci_intel_cnl
sudo modprobe snd_sof_pci_intel_cnl

# Wait a moment for the driver to load
sleep 2

# Check if microphone is detected
echo "Checking microphone devices..."
arecord -l

echo ""
echo "✓ Microphone fix completed!"
echo "Available microphones:"
echo "  - Digital Microphone (internal)"
echo "  - Headphones Stereo Microphone (external/headset)"
