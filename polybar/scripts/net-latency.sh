#!/bin/bash
# Network latency sparkline for polybar - pings default gateway and upstream

GW_HISTORY="/tmp/polybar-latency-gw-${MONITOR:-default}"
UP_HISTORY="/tmp/polybar-latency-up-${MONITOR:-default}"
MAX_POINTS=15
UPSTREAM="1.1.1.1"

source "$HOME/.config/themes/current-colors.sh"

get_latency() {
    local host="$1"
    ping -c 1 -W 1 "$host" 2>/dev/null | grep -oP 'time=\K[\d.]+' || echo "9999"
}

latency_color() {
    local ms="$1"
    if awk "BEGIN {exit !($ms < 20)}"; then
        echo "$GREEN"
    elif awk "BEGIN {exit !($ms < 100)}"; then
        echo "$YELLOW"
    else
        echo "$ALERT"
    fi
}

build_spark() {
    local history_file="$1"
    local BLOCKS=(▁ ▂ ▃ ▄ ▅ ▆ ▇ █)

    [ ! -f "$history_file" ] && echo "${BLOCKS[0]}" && return

    readarray -t entries < "$history_file"
    [ ${#entries[@]} -eq 0 ] && echo "${BLOCKS[0]}" && return
    [ ${#entries[@]} -eq 1 ] && echo "${BLOCKS[3]}" && return

    # Cap at 500ms for scaling purposes
    local values=()
    for e in "${entries[@]}"; do
        values+=("$(awk "BEGIN {print ($e > 500) ? 500 : $e}")")
    done

    local min=99999 max=0
    for v in "${values[@]}"; do
        [ "$(awk "BEGIN {print ($v > $max)}")" = "1" ] && max=$v
        [ "$(awk "BEGIN {print ($v < $min)}")" = "1" ] && min=$v
    done

    local range
    range=$(awk "BEGIN {print $max - $min}")

    local spark=""
    for v in "${values[@]}"; do
        local idx
        if [ "$(awk "BEGIN {print ($range == 0)}")" = "1" ]; then
            idx=3
        else
            idx=$(awk "BEGIN {printf \"%d\", (($v - $min) / $range) * 7}")
        fi
        [ "$idx" -gt 7 ] && idx=7
        [ "$idx" -lt 0 ] && idx=0

        local color
        color=$(latency_color "$v")
        spark="${spark}%{F${color}}${BLOCKS[$idx]}%{F-}"
    done
    echo "$spark"
}

fmt_ms() {
    local ms="$1"
    if [ "$ms" = "9999" ]; then
        echo "---"
    else
        awk "BEGIN {printf \"%.0f\", $ms}"
    fi
}

gw=$(ip route show default 2>/dev/null | awk '/default/ {print $3; exit}')
if [ -z "$gw" ]; then
    echo "󰲛 no gw"
    exit 0
fi

gw_ms=$(get_latency "$gw")
up_ms=$(get_latency "$UPSTREAM")

echo "$gw_ms" >> "$GW_HISTORY"
echo "$up_ms" >> "$UP_HISTORY"

tail -n "$MAX_POINTS" "$GW_HISTORY" > "${GW_HISTORY}.tmp" && mv "${GW_HISTORY}.tmp" "$GW_HISTORY"
tail -n "$MAX_POINTS" "$UP_HISTORY" > "${UP_HISTORY}.tmp" && mv "${UP_HISTORY}.tmp" "$UP_HISTORY"

gw_spark=$(build_spark "$GW_HISTORY")
up_spark=$(build_spark "$UP_HISTORY")

gw_color=$(latency_color "$gw_ms")
up_color=$(latency_color "$up_ms")

gw_display=$(fmt_ms "$gw_ms")
up_display=$(fmt_ms "$up_ms")

echo "󱘖 %{F${gw_color}}${gw_display}ms%{F-} ${gw_spark}  %{F${up_color}}${up_display}ms%{F-} ${up_spark}"
