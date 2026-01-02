#!/bin/bash
# Toggle Auto-Rotate for Lenovo ThinkPad X13 Yoga
# Purpose: Enable/disable auto-rotation to prevent flickering on kernel 5.15

if systemctl is-active --quiet iio-sensor-proxy; then
    sudo systemctl stop iio-sensor-proxy
    sudo systemctl mask iio-sensor-proxy
    echo "✅ Auto-rotate DISABLED - No more flickering"
    echo "ℹ️  Use 'xrandr --output eDP-1 --rotate [normal|left|right|inverted]' for manual rotation"
else
    sudo systemctl unmask iio-sensor-proxy
    sudo systemctl start iio-sensor-proxy
    echo "✅ Auto-rotate ENABLED"
    echo "⚠️  Warning: May cause screen flickering when laptop is moved"
fi
