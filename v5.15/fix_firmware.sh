#!/bin/bash

# Fix for Kernel 5.15 not supporting ZIT/ZST compressed firmware
# This script decompresses .zst firmware files so Kernel 5.15 can load them
# Specifically targeting Intel WiFi/BT firmware often found in newer Ubuntu versions

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

echo "[*] Checking for zstd..."
if ! command -v zstd &> /dev/null; then
    echo "zstd could not be found, installing..."
    apt update && apt install -y zstd
fi

echo "[*] Decompressing Intel WiFi/BT firmware..."
# Find and decompress zst files in firmware directory
# We use --rm to remove the compressed file after successful decompression
# This ensures kernel finds the uncompressed version immediately
find /lib/firmware -name "iwlwifi-*.zst" -exec zstd -d --rm {} \;
find /lib/firmware -name "ibt-*.zst" -exec zstd -d --rm {} \;

# Also general catch-all for other firmware if needed
# find /lib/firmware -name "*.zst" -exec zstd -d --rm {} \;

echo "[*] Updating initramfs..."
update-initramfs -u

echo "[*] Done! Please reboot to verify WiFi and Bluetooth functionality."
