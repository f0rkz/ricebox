#!/usr/bin/env bash

source "$HOME/.config/ricebox.env" 2>/dev/null

CONFIG_DIR=$HOME/.config/polybar
VERTICAL="${RICEBOX_VERTICAL_MONITOR:-}"

killall -q -9 polybar
sleep 0.5

if type "xrandr" > /dev/null 2>&1; then
  # Only outputs with a current geometry are active; connected outputs may be off.
  for m in $(xrandr --query | awk '$2 == "connected" && / [0-9]+x[0-9]+[+-][0-9]+[+-][0-9]+ / {print $1}'); do
    if [ "$m" = "$VERTICAL" ] && [ -n "$VERTICAL" ]; then
      MONITOR=$m polybar --config="$CONFIG_DIR/config.ini" vertical &
    else
      MONITOR=$m polybar --config="$CONFIG_DIR/config.ini" main &
    fi
  done
else
  polybar --config="$CONFIG_DIR/config.ini" main &
fi
