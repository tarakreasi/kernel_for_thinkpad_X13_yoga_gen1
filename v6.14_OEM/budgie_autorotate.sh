#!/bin/bash
# Auto-rotate script for Budgie/X11
# Rotates Display AND Wacom Touchscreen/Stylus
# Requires: iio-sensor-proxy, xrandr, xinput

# 1. Detect Display
# Finds the first connected display (e.g. eDP-1 or None-1)
DISPLAY_OUTPUT=$(xrandr | grep " connected" | head -n1 | awk '{print $1}')
echo "[*] Detected Display: $DISPLAY_OUTPUT"

# 2. Detect Input Devices
# Grabs IDs of Wacom devices to sync rotation (Touch + Pen)
INPUT_DEVICES=$(xinput list | grep "Wacom" | grep "slave  pointer" | sed -n 's/.*id=\([0-9]*\).*/\1/p')
echo "[*] Detected Input IDs: $(echo $INPUT_DEVICES | tr '\n' ' ')"

# 3. Monitor Sensor Loop
echo "[*] Starting sensor monitor... (Press Ctrl+C to stop)"

# kill background monitor-sensor on exit
trap "pkill -P $$" EXIT

monitor-sensor | while read -r line; do
    # Default values (Normal)
    ROTATE_CMD="normal"
    # Matrix: Identity
    MATRIX="1 0 0 0 1 0 0 0 1"
    
    echo "Sensor says: $line"

    # Match keywords directly (monitor-sensor updates might not include 'orientation:')
    if [[ $line == *"bottom-up"* ]]; then
        echo "   -> Rotating: Inverted (Bottom-Up)"
        ROTATE_CMD="inverted"
        # Matrix: Inverted (180 deg)
        MATRIX="-1 0 1 0 -1 1 0 0 1"
        
    elif [[ $line == *"left-up"* ]]; then
        echo "   -> Rotating: Left"
        ROTATE_CMD="left"
        # Matrix: 90 deg counter-clockwise
        MATRIX="0 -1 1 1 0 0 0 0 1"
        
    elif [[ $line == *"right-up"* ]]; then
        echo "   -> Rotating: Right"
        ROTATE_CMD="right"
        # Matrix: 90 deg clockwise
        MATRIX="0 1 0 -1 0 1 0 0 1"
        
    elif [[ $line == *"normal"* ]]; then
        echo "   -> Rotating: Normal"
        ROTATE_CMD="normal"
        # Matrix: Identity
        MATRIX="1 0 0 0 1 0 0 0 1"
    else
        # Skip other lines
        continue
    fi
    
    # 4. Apply Rotation to Display
    xrandr --output "$DISPLAY_OUTPUT" --rotate "$ROTATE_CMD"
    
    # 5. Apply Rotation to Input Devices (Matrix)
    for dev in $INPUT_DEVICES; do
        xinput set-prop "$dev" "Coordinate Transformation Matrix" $MATRIX 2>/dev/null
    done
done
