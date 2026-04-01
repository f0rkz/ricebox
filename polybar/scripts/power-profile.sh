#!/bin/bash
# Power profile display and cycling for polybar
# Sets both platform_profile AND EPP for real impact

source "$HOME/.config/themes/current-colors.sh"
ICON_POWERSAVE=$'\uf06c'
ICON_BALANCED=$'\uf24e'
ICON_PERFORMANCE=$'\uf0e7'

PROFILE_PATH=/sys/firmware/acpi/platform_profile
EPP_PATH=/sys/devices/system/cpu/cpu*/cpufreq/energy_performance_preference

current=$(cat $PROFILE_PATH 2>/dev/null)

case "$1" in
    cycle)
        case "$current" in
            low-power)
                echo "balanced" | sudo tee $PROFILE_PATH > /dev/null
                echo "balance_power" | sudo tee $EPP_PATH > /dev/null
                ;;
            balanced)
                echo "performance" | sudo tee $PROFILE_PATH > /dev/null
                echo "performance" | sudo tee $EPP_PATH > /dev/null
                ;;
            performance)
                echo "low-power" | sudo tee $PROFILE_PATH > /dev/null
                echo "power" | sudo tee $EPP_PATH > /dev/null
                ;;
        esac
        ;;
    *)
        case "$current" in
            low-power)    echo "%{F${SECONDARY}}${ICON_POWERSAVE}%{F-} saver" ;;
            balanced)     echo "%{F${GREEN}}${ICON_BALANCED}%{F-} balanced" ;;
            performance)  echo "%{F${ALERT}}${ICON_PERFORMANCE}%{F-} perf" ;;
            *)            echo "?" ;;
        esac
        ;;
esac
