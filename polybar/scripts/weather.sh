#!/bin/bash
# Weather for polybar - uses home city on home wifi, geoip when travelling
source "$HOME/.config/ricebox.env" 2>/dev/null

HOME_SSID="${RICEBOX_HOME_SSID:-}"
HOME_LOCATION="${RICEBOX_HOME_LOCATION:-}"
LANG="en"

current_ssid=$(nmcli -t -f active,ssid dev wifi 2>/dev/null | grep '^yes' | cut -d: -f2)

if [ "$current_ssid" = "$HOME_SSID" ]; then
    LOCATION="$HOME_LOCATION"
else
    LOCATION=$(curl -sf --max-time 5 "https://ipapi.co/city" 2>/dev/null)
    if [ -z "$LOCATION" ]; then
        LOCATION="$HOME_LOCATION"
    fi
fi

WEATHER_JSON=$(curl -sf --max-time 10 "https://wttr.in/${LOCATION}?0pq&format=j1&lang=$LANG")

if [ -z "$WEATHER_JSON" ]; then
    echo ""
    exit 0
fi

TEMPERATURE=$(echo "$WEATHER_JSON" | jq -r '.current_condition[0].temp_F' 2>/dev/null)
WEATHER_CODE=$(echo "$WEATHER_JSON" | jq -r '.current_condition[0].weatherCode' 2>/dev/null)
AREA_NAME=$(echo "$WEATHER_JSON" | jq -r '.nearest_area[0].areaName[0].value' 2>/dev/null | sed 's/\(.\{16\}\).*/\1.../')

if [ -z "$TEMPERATURE" ] || [ "$TEMPERATURE" = "null" ] || [ -z "$WEATHER_CODE" ] || [ "$WEATHER_CODE" = "null" ]; then
    echo ""
    exit 0
fi

# Map wttr.in weather codes to icons
# FA6: sun=f185 cloud-sun=f6c4 cloud=f0c2 cloud-rain=f73d cloud-showers-heavy=f740
#      bolt=f0e7 snowflake=f2dc smog=f75f moon=f186 cloud-moon=f6c3
case "$WEATHER_CODE" in
    113) ICON=$'\uf185' ;;                    # sunny/clear
    116) ICON=$'\uf6c4' ;;                    # partly cloudy
    119|122) ICON=$'\uf0c2' ;;                # cloudy/overcast
    143|248|260) ICON=$'\uf75f' ;;            # fog/mist
    176|263|266|293|296) ICON=$'\uf73d' ;;    # light rain/drizzle
    299|302|305|308|356|359) ICON=$'\uf740' ;;# heavy rain
    200|386|389|392|395) ICON=$'\uf0e7' ;;    # thunderstorm
    179|182|185|227|230|281|284|311|314|317|320|323|326|329|332|335|338|350|362|365|368|371|374|377) ICON=$'\uf2dc' ;; # snow/sleet/ice
    *) ICON=$'\uf0c2' ;;                      # default cloud
esac

echo "$AREA_NAME $TEMPERATURE°F $ICON"
