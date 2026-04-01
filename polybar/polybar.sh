#!/usr/bin/env bash

source "$HOME/.config/ricebox.env" 2>/dev/null

CONFIG_DIR=$HOME/.config/polybar
VERTICAL="${RICEBOX_VERTICAL_MONITOR:-}"

killall -q -9 polybar
sleep 0.5

if type "xrandr" > /dev/null 2>&1; then
  # Count external monitors
  ext_count=$(xrandr --query | grep " connected" | grep -cv "eDP")

  for m in $(xrandr --query | grep " connected" | cut -d" " -f1); do
    if [ "$m" = "$VERTICAL" ] && [ -n "$VERTICAL" ]; then
      MONITOR=$m polybar --config=$CONFIG_DIR/config.ini vertical &
    elif [ "$m" = "${RICEBOX_LAPTOP_PANEL:-eDP-1}" ] && [ "$ext_count" -gt 0 ]; then
      continue
    else
      MONITOR=$m polybar --config=$CONFIG_DIR/config.ini main &
    fi
  done
else
  polybar --config=$CONFIG_DIR/config.ini main &
fi
