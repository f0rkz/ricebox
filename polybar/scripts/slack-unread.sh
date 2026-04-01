#!/bin/bash
# Check if Slack has unread notifications via window title
source "$HOME/.config/themes/current-colors.sh"

slack_window=$(xdotool search --name "Slack" 2>/dev/null | head -1)

if [ -z "$slack_window" ]; then
    echo ""
    exit 0
fi

title=$(xdotool getwindowname "$slack_window" 2>/dev/null)

if echo "$title" | grep -qP '^\*|!\s|^\(\d+\)'; then
    echo "%{F${PRIMARY}}%{F-}"
else
    echo ""
fi
