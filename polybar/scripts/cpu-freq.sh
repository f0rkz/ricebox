#!/bin/bash
# Average CPU frequency across all cores in GHz

avg=$(awk '{ sum += $1; n++ } END { printf "%.1f", sum / n / 1000000 }' /sys/devices/system/cpu/cpu*/cpufreq/scaling_cur_freq)
echo "${avg}GHz"
