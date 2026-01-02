#!/bin/bash
set -e

KERNEL_VERSION="6.14.0-1018-oem"
MODULE_DIR="/lib/modules/$KERNEL_VERSION/kernel/drivers/gpu/drm/i915"
NEW_MODULE="kernel-build/linux-oem-6.14-6.14.0/drivers/gpu/drm/i915/i915.ko"

if [ ! -f "$NEW_MODULE" ]; then
    echo "Error: New module not found at $NEW_MODULE"
    echo "Compilation might not be finished or failed."
    exit 1
fi

echo "Backing up original module..."
if [ -f "$MODULE_DIR/i915.ko.zst" ]; then
    sudo cp "$MODULE_DIR/i915.ko.zst" "$MODULE_DIR/i915.ko.zst.bak"
    echo "Backup created at $MODULE_DIR/i915.ko.zst.bak"
else
    echo "Warning: Original module not found at expected location (might differ in compression?)"
fi

echo "Compressing new module..."
zstd -f "$NEW_MODULE" -o i915.ko.zst

echo "Installing new module..."
sudo cp i915.ko.zst "$MODULE_DIR/i915.ko.zst"

echo "Updating module dependencies..."
sudo depmod -a "$KERNEL_VERSION"

echo "Updating initramfs..."
sudo update-initramfs -u -k "$KERNEL_VERSION"

echo "Done! The new i915 driver with hardcoded parameters is installed for kernel $KERNEL_VERSION."
