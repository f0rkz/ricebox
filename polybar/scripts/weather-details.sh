#!/bin/bash
# Detailed weather forecast in rofi with city search
source "$HOME/.config/ricebox.env" 2>/dev/null

HOME_SSID="${RICEBOX_HOME_SSID:-}"
HOME_LOCATION="${RICEBOX_HOME_LOCATION:-}"

fetch_weather() {
    local loc="$1"
    local json=$(curl -sf --max-time 10 "https://wttr.in/${loc}?format=j1")
    [ -z "$json" ] && echo "failed to fetch weather" && return 1

    local area=$(echo "$json" | jq -r '.nearest_area[0].areaName[0].value')
    local region=$(echo "$json" | jq -r '.nearest_area[0].region[0].value')
    local cur=$(echo "$json" | jq -r '.current_condition[0]')
    local temp=$(echo "$cur" | jq -r '.temp_F')
    local feels=$(echo "$cur" | jq -r '.FeelsLikeF')
    local humidity=$(echo "$cur" | jq -r '.humidity')
    local wind_mph=$(echo "$cur" | jq -r '.windspeedMiles')
    local wind_dir=$(echo "$cur" | jq -r '.winddir16Point')
    local uv=$(echo "$cur" | jq -r '.uvIndex')
    local vis=$(echo "$cur" | jq -r '.visibilityMiles')
    local desc=$(echo "$cur" | jq -r '.weatherDesc[0].value')
    local precip=$(echo "$cur" | jq -r '.precipInches')

    local info="=== ${area}, ${region} ===\n"
    info+="  ${desc}\n"
    info+="  temp: ${temp}°F  feels like: ${feels}°F\n"
    info+="  humidity: ${humidity}%%  uv: ${uv}\n"
    info+="  wind: ${wind_mph} mph ${wind_dir}\n"
    info+="  visibility: ${vis} mi  precip: ${precip} in\n"

    for day_idx in 0 1 2; do
        local day=$(echo "$json" | jq -r ".weather[${day_idx}]")
        local date=$(echo "$day" | jq -r '.date')
        local max=$(echo "$day" | jq -r '.maxtempF')
        local min=$(echo "$day" | jq -r '.mintempF')
        local sun_rise=$(echo "$day" | jq -r '.astronomy[0].sunrise')
        local sun_set=$(echo "$day" | jq -r '.astronomy[0].sunset')

        info+="\n=== ${date} ===\n"
        info+="  high: ${max}°F  low: ${min}°F\n"
        info+="  sunrise: ${sun_rise}  sunset: ${sun_set}\n"

        for hour_idx in 2 4 6; do
            local hour=$(echo "$day" | jq -r ".hourly[${hour_idx}]")
            local h_temp=$(echo "$hour" | jq -r '.tempF')
            local h_desc=$(echo "$hour" | jq -r '.weatherDesc[0].value')
            local h_rain=$(echo "$hour" | jq -r '.chanceofrain')

            case "$hour_idx" in
                2) period="morning  " ;;
                4) period="afternoon" ;;
                6) period="evening  " ;;
            esac

            info+="  ${period}: ${h_temp}°F ${h_desc} (rain: ${h_rain}%%)\n"
        done
    done

    echo -e "$info"
}

# Default location
current_ssid=$(nmcli -t -f active,ssid dev wifi 2>/dev/null | grep '^yes' | cut -d: -f2)
if [ "$current_ssid" = "$HOME_SSID" ]; then
    LOCATION="$HOME_LOCATION"
else
    LOCATION=$(curl -sf --max-time 5 "https://ipapi.co/city" 2>/dev/null)
    [ -z "$LOCATION" ] && LOCATION="$HOME_LOCATION"
fi

while true; do
    weather=$(fetch_weather "$LOCATION")
    choice=$(echo -e "${weather}\n\n  >> search another city" | rofi -dmenu -p "weather" -i -theme-str 'window {width: 45%;} listview {lines: 32;}')

    if echo "$choice" | grep -q "search another city"; then
        new_city=$(echo "" | rofi -dmenu -p "city" -i -theme-str 'window {width: 30%;} listview {lines: 0;}')
        [ -z "$new_city" ] && exit 0
        LOCATION=$(echo "$new_city" | tr ' ' '+')
    else
        exit 0
    fi
done
