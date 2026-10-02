#!/bin/bash
# Themed i3lock-color invocation - picks up the active theme's colors.
# Invoked by xss-lock from i3/config; extra args (e.g. --nofork) are forwarded.
source "$HOME/.config/themes/current-colors.sh"

# strip a leading '#' and append an alpha channel (default fully opaque)
c() { printf '%s%s' "${1#\#}" "${2:-ff}"; }

# weather.sh (polybar) refreshes this cache every 15min - read only, never
# fetched live here, so locking is never delayed by a network call.
# The date-str *format string* is capped at 31 bytes by i3lock-color (it
# errors out and never locks if exceeded), so keep the weather text short.
DATE_STR="%a, %b %d"
DATE_ALIGN_ARGS=()
WEATHER_CACHE="$HOME/.cache/ricebox/weather"
if [ -r "$WEATHER_CACHE" ]; then
  WEATHER=$(<"$WEATHER_CACHE")
  WEATHER="${WEATHER:0:18}"
  if [ -n "$WEATHER" ]; then
    DATE_STR="%a, %b %d
$WEATHER"
    # i3lock-color's default date centering (align=0) measures text width
    # with cairo_text_extents(), which doesn't understand the \n control
    # code it uses for line breaks - so multi-line date-str ends up
    # mis-centered. Pin it manually instead; offset tuned for this format.
    DATE_ALIGN_ARGS=(--date-align=1 --date-pos="ix-54:iy+30")
  fi
fi

exec i3lock \
  --color="${BG_DARK#\#}" \
  --clock --time-str="%H:%M:%S" --date-str="$DATE_STR" \
  --time-font="0xProto Nerd Font" --date-font="0xProto Nerd Font" \
  --time-size=32 --date-size=14 \
  "${DATE_ALIGN_ARGS[@]}" \
  --radius=140 --ring-width=4 \
  --indicator \
  --inside-color="$(c "$BG" 99)" \
  --insidever-color="$(c "$BG_ALT" cc)" \
  --insidewrong-color="$(c "$ALERT" 66)" \
  --ring-color="$(c "$FG_ALT" ff)" \
  --ringver-color="$(c "$PRIMARY" ff)" \
  --ringwrong-color="$(c "$ALERT" ff)" \
  --line-color="$(c "$BG" 00)" \
  --separator-color="$(c "$BG" 00)" \
  --keyhl-color="$(c "$PRIMARY" ff)" \
  --bshl-color="$(c "$ALERT" ff)" \
  --verif-color="$(c "$FG" ff)" \
  --wrong-color="$(c "$ALERT" ff)" \
  --time-color="$(c "$FG" ff)" \
  --date-color="$(c "$FG_ALT" ff)" \
  --greeter-color="$(c "$FG" ff)" \
  --modif-color="$(c "$SECONDARY" ff)" \
  --layout-color="$(c "$FG_ALT" ff)" \
  "$@"
