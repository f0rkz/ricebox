#!/usr/bin/env bash

source "$HOME/.config/ricebox.env" 2>/dev/null

CONFIG_DIR=$HOME/.config/polybar
VERTICAL="${RICEBOX_VERTICAL_MONITOR:-}"

killall -q -9 polybar
sleep 0.5

if type "xrandr" > /dev/null 2>&1; then
  # Only outputs with a current geometry are active; connected outputs may be off.
  mapfile -t monitors < <(xrandr --query | awk '$2 == "connected" && / [0-9]+x[0-9]+[+-][0-9]+[+-][0-9]+ / {print $1}')
  for m in "${monitors[@]}"; do
    if [ "$m" = "$VERTICAL" ] && [ -n "$VERTICAL" ]; then
      MONITOR=$m polybar --config="$CONFIG_DIR/config.ini" vertical &
    elif [ "$m" = "${RICEBOX_LAPTOP_PANEL:-eDP-1}" ] && [ "${#monitors[@]}" -eq 1 ]; then
      MONITOR=$m polybar --config="$CONFIG_DIR/config.ini" laptop &
      MONITOR=$m polybar --config="$CONFIG_DIR/config.ini" bottom &
    else
      MONITOR=$m polybar --config="$CONFIG_DIR/config.ini" main &
    fi
  done
else
  polybar --config="$CONFIG_DIR/config.ini" main &
fi
