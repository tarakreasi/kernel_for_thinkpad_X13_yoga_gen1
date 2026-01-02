#!/bin/bash
set -e

# Config
KERNEL_VER=$(uname -r)
SOURCE_DIR="/home/twantoro/kernel/kernel-build/linux-oem-6.14-6.14.0"
TARGET_MODULE="drivers/gpu/drm/i915/i915.ko"

echo "========================================"
echo "   REBUILDING i915 FOR KERNEL $KERNEL_VER"
echo "========================================"

cd "$SOURCE_DIR"

echo "[1/6] Cleaning previous build..."
# We use 'make M=... clean' if possible, or just clean the specific dir to save time
# But for safety let's just touch the config
if [ -f .config ]; then
    echo "Backing up old .config..."
    mv .config .config.bak
fi

echo "[2/6] Copying running kernel config..."
cp "/boot/config-$KERNEL_VER" .config


echo "[3/6] Copying Module.symvers..."
# Essential for preventing symbol mismatch errors
if [ -f "/usr/src/linux-headers-$KERNEL_VER/Module.symvers" ]; then
    cp "/usr/src/linux-headers-$KERNEL_VER/Module.symvers" .
elif [ -f "/lib/modules/$KERNEL_VER/build/Module.symvers" ]; then
    cp "/lib/modules/$KERNEL_VER/build/Module.symvers" .
else
    echo "WARNING: Module.symvers not found! Build might fail or mismatch."
fi

echo "[4/6] Preparing kernel build environment..."
# This ensures the tree is configured exactly like the running kernel
# preventing 'struct module' size mismatch
make olddefconfig
make modules_prepare

echo "[5/6] Compiling i915 module only..."
# Compiling just the i915 module
make -j$(nproc) M=drivers/gpu/drm/i915 modules

echo "[6/6] Verify..."
if [ -f "$TARGET_MODULE" ]; then
    echo "Success! New module built at:"
    echo "$SOURCE_DIR/$TARGET_MODULE"
    
    # Check if we can get modinfo (basic valid check)
    modinfo "$TARGET_MODULE" | grep filename
else
    echo "Error: Build failed, module not found."
    exit 1
fi

echo "========================================"
echo "Run './install_custom_i915.sh' again to install this fixed module."
