#!/bin/bash
# Detailed memory info in rofi

read_meminfo() { grep "^$1:" /proc/meminfo | awk '{printf "%.1f GB", $2/1048576}'; }

total=$(read_meminfo MemTotal)
free=$(read_meminfo MemFree)
available=$(read_meminfo MemAvailable)
buffers=$(read_meminfo Buffers)
cached=$(read_meminfo Cached)
swap_total=$(read_meminfo SwapTotal)
swap_free=$(read_meminfo SwapFree)
swap_used=$(awk '/SwapTotal/{t=$2} /SwapFree/{f=$2} END{printf "%.1f GB", (t-f)/1048576}' /proc/meminfo)

used=$(awk '/MemTotal/{t=$2} /MemAvailable/{a=$2} END{printf "%.1f GB", (t-a)/1048576}' /proc/meminfo)
pct=$(awk '/MemTotal/{t=$2} /MemAvailable/{a=$2} END{printf "%.0f", (t-a)/t*100}' /proc/meminfo)

# Top 5 memory consumers
top_procs=$(ps aux --sort=-%mem | head -6 | tail -5 | awk '{printf "  %-6s %-4s%% %-6s %s\n", $2, $4, $6"K", $11}')

info="=== Memory ===\n"
info+="  used: ${used} / ${total} (${pct}%%)\n"
info+="  available: ${available}\n"
info+="  buffers: ${buffers}  cached: ${cached}\n"
info+="\n=== Swap ===\n"
info+="  used: ${swap_used} / ${swap_total}\n"
info+="  free: ${swap_free}\n"
info+="\n=== Top Processes ===\n"
info+="  PID    MEM   RSS    CMD\n"
info+="${top_procs}"

echo -e "$info" | rofi -dmenu -p "memory" -i -theme-str 'window {width: 40%;} listview {lines: 20;}'
