#!/bin/bash
# Battery wattage with color-coded sparkline graph for polybar

HISTORY_FILE="/tmp/polybar-wattage-history-${MONITOR:-default}"
LOCK_FILE="${HISTORY_FILE}.lock"
MAX_POINTS=15

power_uw=$(cat /sys/class/power_supply/BAT0/power_now 2>/dev/null)
status=$(cat /sys/class/power_supply/BAT0/status 2>/dev/null)

if [ -z "$power_uw" ] || [ "$power_uw" = "0" ]; then
    echo ""
    exit 0
fi

watts=$(awk "BEGIN {printf \"%.1f\", $power_uw / 1000000}")

# Store watts with charge state: +/- prefix
case "$status" in
    Charging)    echo "+${watts}" >> "$HISTORY_FILE" ;;
    Discharging) echo "-${watts}" >> "$HISTORY_FILE" ;;
    *)           echo "0${watts}" >> "$HISTORY_FILE" ;;
esac

# Trim to last MAX_POINTS
tail -n "$MAX_POINTS" "$HISTORY_FILE" > "${HISTORY_FILE}.tmp"
mv "${HISTORY_FILE}.tmp" "$HISTORY_FILE"

# Build sparkline
BLOCKS=(▁ ▂ ▃ ▄ ▅ ▆ ▇ █)
source "$HOME/.config/themes/current-colors.sh"
GREEN="$GREEN"
RED="$ALERT"
TEAL="$SECONDARY"

readarray -t entries < "$HISTORY_FILE"

# Extract absolute values for scaling
abs_values=()
states=()
for e in "${entries[@]}"; do
    state="${e:0:1}"
    val="${e:1}"
    abs_values+=("$val")
    states+=("$state")
done

if [ ${#abs_values[@]} -gt 1 ]; then
    min=999 max=0
    for v in "${abs_values[@]}"; do
        [ "$(awk "BEGIN {print ($v > $max)}")" = "1" ] && max=$v
        [ "$(awk "BEGIN {print ($v < $min)}")" = "1" ] && min=$v
    done

    range=$(awk "BEGIN {print $max - $min}")
    spark=""
    for i in "${!abs_values[@]}"; do
        v="${abs_values[$i]}"
        s="${states[$i]}"

        if [ "$(awk "BEGIN {print ($range == 0)}")" = "1" ]; then
            idx=3
        else
            idx=$(awk "BEGIN {printf \"%d\", (($v - $min) / $range) * 7}")
        fi
        [ "$idx" -gt 7 ] && idx=7
        [ "$idx" -lt 0 ] && idx=0

        case "$s" in
            +) color="$GREEN" ;;
            -) color="$RED" ;;
            *) color="$TEAL" ;;
        esac
        spark="${spark}%{F${color}}${BLOCKS[$idx]}%{F-}"
    done
else
    spark="${BLOCKS[4]}"
fi

case "$status" in
    Charging)    echo "%{F${GREEN}}+${watts}W%{F-} ${spark}" ;;
    Discharging) echo "%{F${RED}}-${watts}W%{F-} ${spark}" ;;
    Full)        echo "%{F${TEAL}}AC%{F-} ${spark}" ;;
    *)           echo "${watts}W ${spark}" ;;
esac
