#!/bin/bash
# Bluetooth status for polybar
source "$HOME/.config/themes/current-colors.sh"

BT_ICON=$'\uf293'
powered=$(bluetoothctl show 2>/dev/null | grep "Powered:" | awk '{print $2}')

if [ "$powered" = "yes" ]; then
    connected=$(bluetoothctl devices Connected 2>/dev/null | head -1)
    if [ -n "$connected" ]; then
        device_name=$(echo "$connected" | cut -d' ' -f3-)
        echo "%{F${PRIMARY}}${BT_ICON}%{F-} $device_name"
    else
        echo "${BT_ICON}"
    fi
else
    echo "%{F${DISABLED}}${BT_ICON}%{F-}"
fi
