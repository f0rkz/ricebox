#!/bin/bash
# Detailed CPU info in rofi

governor=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor)
epp=$(cat /sys/devices/system/cpu/cpu0/cpufreq/energy_performance_preference 2>/dev/null)
boost=$(cat /sys/devices/system/cpu/cpufreq/boost 2>/dev/null)
profile=$(cat /sys/firmware/acpi/platform_profile 2>/dev/null)
model=$(grep "model name" /proc/cpuinfo | head -1 | cut -d: -f2 | xargs)
cores=$(nproc)

# Per-core frequencies
core_freqs=""
for i in $(seq 0 $((cores - 1))); do
    freq=$(cat /sys/devices/system/cpu/cpu${i}/cpufreq/scaling_cur_freq 2>/dev/null)
    ghz=$(awk "BEGIN {printf \"%.2f\", $freq / 1000000}")
    core_freqs+="  cpu${i}: ${ghz} GHz\n"
done

# Top 5 CPU consumers
top_procs=$(ps aux --sort=-%cpu | head -6 | tail -5 | awk '{printf "  %-6s %-4s%% %s\n", $2, $3, $11}')

info="=== CPU ===\n"
info+="  ${model}\n"
info+="  cores: ${cores}  governor: ${governor}\n"
info+="  epp: ${epp}  boost: ${boost}  profile: ${profile}\n"
info+="\n=== Core Frequencies ===\n"
info+="${core_freqs}"
info+="\n=== Top Processes ===\n"
info+="  PID    CPU   CMD\n"
info+="${top_procs}"

echo -e "$info" | rofi -dmenu -p "cpu" -i -theme-str 'window {width: 40%;} listview {lines: 30;}'
