#!/bin/bash
# Rofi menu for selecting tailscale exit node

backend_state=$(tailscale status --json 2>/dev/null | jq -r '.BackendState')

# If tailscale is stopped, offer to connect
if [ "$backend_state" != "Running" ]; then
    choice=$(echo -e "  connect" | rofi -dmenu -p "tailscale" -i -theme-str 'window {width: 20%;}')
    if [ "$choice" = "  connect" ]; then
        sudo tailscale up
    fi
    exit 0
fi

status=$(tailscale status --json 2>/dev/null)
current_exit=$(echo "$status" | jq -r '.ExitNodeStatus.ID // empty')

# Get all peers that offer exit node
exit_nodes=$(echo "$status" | jq -r '.Peer[] | select(.ExitNodeOption == true) | .HostName')

# Build menu with disconnect option and mark current
menu=""
if [ -n "$exit_nodes" ]; then
    while IFS= read -r node; do
        node_id=$(echo "$status" | jq -r --arg name "$node" '[.Peer[] | select(.HostName == $name) | .ID] | first')
        if [ "$node_id" = "$current_exit" ]; then
            menu+="* ${node}\n"
        else
            menu+="  ${node}\n"
        fi
    done <<< "$exit_nodes"
fi

if [ -n "$current_exit" ]; then
    menu+="  disconnect exit node\n"
fi
menu+="  disconnect tailscale"

choice=$(echo -e "$menu" | rofi -dmenu -p "exit node" -i -theme-str 'window {width: 20%;}')

if [ -z "$choice" ]; then
    exit 0
fi

# Strip the prefix marker
choice=$(echo "$choice" | sed 's/^[* ] //')

if [ "$choice" = "disconnect tailscale" ]; then
    sudo tailscale down
elif [ "$choice" = "disconnect exit node" ]; then
    sudo tailscale set --exit-node=
else
    node_ip=$(echo "$status" | jq -r --arg name "$choice" '[.Peer[] | select(.HostName == $name) | .TailscaleIPs[0]] | first')
    sudo tailscale set --exit-node="$node_ip"
fi
