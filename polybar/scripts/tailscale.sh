#!/bin/bash
# Tailscale status for polybar
source "$HOME/.config/themes/current-colors.sh"

VPN_ICON=$'\uf023'    # FA lock
VPN_OFF=$'\uf09c'     # FA unlock

status=$(tailscale status --json 2>/dev/null)

if [ -z "$status" ]; then
    echo "%{F${DISABLED}}${VPN_OFF}%{F-}"
    exit 0
fi

backend_state=$(echo "$status" | jq -r '.BackendState')

if [ "$backend_state" != "Running" ]; then
    echo "%{F${DISABLED}}${VPN_OFF}%{F-} off"
    exit 0
fi

# Check for exit node
exit_node_id=$(echo "$status" | jq -r '.ExitNodeStatus.ID // empty')

if [ -n "$exit_node_id" ]; then
    exit_node_name=$(echo "$status" | jq -r --arg id "$exit_node_id" '[.Peer[] | select(.ID == $id) | .HostName] | first // "exit"')
    echo "%{F${PRIMARY}}${VPN_ICON}%{F-} ${exit_node_name}"
else
    echo "%{F${YELLOW}}${VPN_ICON}%{F-} ts"
fi
