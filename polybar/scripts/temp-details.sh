#!/bin/bash
# Detailed temperature info in rofi

info="=== Temperatures ===\n"

for h in /sys/class/hwmon/hwmon*; do
    name=$(cat "${h}/name" 2>/dev/null)
    [ -z "$name" ] && continue
    
    has_temps=false
    for t in "${h}"/temp*_input; do
        [ -f "$t" ] || continue
        val=$(cat "$t" 2>/dev/null)
        [ -z "$val" ] && continue
        has_temps=true
        label_file="${t%_input}_label"
        if [ -f "$label_file" ]; then
            label=$(cat "$label_file" 2>/dev/null)
        else
            label=$(basename "$t" | sed 's/_input//')
        fi
        celsius=$(awk "BEGIN {printf \"%.1f\", $val / 1000}")
        info+="  ${name}/${label}: ${celsius}°C\n"
    done
done

echo -e "$info" | rofi -dmenu -p "temps" -i -theme-str 'window {width: 35%;} listview {lines: 20;}'
