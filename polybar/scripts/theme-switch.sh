#!/bin/bash
# Theme switcher - applies theme across polybar, kitty, i3, rofi

source "$HOME/.config/ricebox.env" 2>/dev/null

THEME_DIR="$HOME/.config/themes"
CURRENT_FILE="$THEME_DIR/.current"

# Get current theme name
current=$(cat "$CURRENT_FILE" 2>/dev/null || echo "dark-green")

# Build rofi menu
themes=""
for f in "$THEME_DIR"/*.sh; do
    name=$(basename "$f" .sh)
    if [ "$name" = "$current" ]; then
        themes+="* ${name}\n"
    else
        themes+="  ${name}\n"
    fi
done

choice=$(echo -e "$themes" | rofi -dmenu -p "theme" -i -theme-str 'window {width: 20%;} listview {lines: 10;}')
[ -z "$choice" ] && exit 0

# Strip prefix
choice=$(echo "$choice" | sed 's/^[* ]*//' | sed 's/^ *//')
theme_file="$THEME_DIR/${choice}.sh"
[ ! -f "$theme_file" ] && exit 1

# Source the theme
source "$theme_file"

# === POLYBAR ===
python3 << PYEOF
import re, sys

with open("$HOME/.config/polybar/config.ini", "r") as f:
    content = f.read()

colors = {
    "background": "$BG",
    "background-alt": "$BG_ALT",
    "foreground": "$FG",
    "foreground-alt": "$FG_ALT",
    "primary": "$PRIMARY",
    "secondary": "$SECONDARY",
    "alert": "$ALERT",
    "disabled": "$DISABLED",
}

for key, val in colors.items():
    content = re.sub(
        rf'^({re.escape(key)}\s*=\s*)#[0-9A-Fa-f]{{6}}',
        rf'\g<1>{val}',
        content,
        flags=re.MULTILINE
    )

with open("$HOME/.config/polybar/config.ini", "w") as f:
    f.write(content)
PYEOF

# === KITTY ===
python3 << PYEOF
with open("$HOME/.config/kitty/kitty.conf", "r") as f:
    lines = f.readlines()

color_map = {
    "foreground": "$FG",
    "background": "$BG_DARK",
    "selection_foreground": "$BG",
    "selection_background": "$PRIMARY",
    "cursor": "$CURSOR",
    "cursor_text_color": "$BG",
    "url_color": "$SECONDARY",
    "color0": "$BLACK",
    "color8": "$BLACK_BRIGHT",
    "color1": "$RED",
    "color9": "$RED_BRIGHT",
    "color2": "$GREEN",
    "color10": "$GREEN_BRIGHT",
    "color3": "$YELLOW",
    "color11": "$YELLOW_BRIGHT",
    "color4": "$BLUE",
    "color12": "$BLUE_BRIGHT",
    "color5": "$MAGENTA",
    "color13": "$MAGENTA_BRIGHT",
    "color6": "$CYAN",
    "color14": "$CYAN_BRIGHT",
    "color7": "$WHITE",
    "color15": "$WHITE_BRIGHT",
    "active_tab_foreground": "$BG",
    "active_tab_background": "$PRIMARY",
    "inactive_tab_foreground": "$FG_ALT",
    "inactive_tab_background": "$BG_ALT",
}

new_lines = []
for line in lines:
    stripped = line.strip()
    matched = False
    for key, val in color_map.items():
        if stripped.startswith(key + " ") or stripped.startswith(key + "\t"):
            parts = stripped.split(None, 1)
            if len(parts) == 2 and parts[1].startswith("#"):
                new_lines.append(f"{key} {val}\n")
                matched = True
                break
    if not matched:
        new_lines.append(line)

with open("$HOME/.config/kitty/kitty.conf", "w") as f:
    f.writelines(new_lines)
PYEOF

# === I3 ===
python3 << PYEOF
import re

with open("$HOME/.config/i3/config", "r") as f:
    content = f.read()

# Window borders
i3_colors = {
    "client.focused": "$PRIMARY $BG_ALT $FG $SECONDARY $PRIMARY",
    "client.focused_inactive": "$DISABLED $BG $FG_ALT $DISABLED $DISABLED",
    "client.unfocused": "$BG_ALT $BG $DISABLED $BG_ALT $BG_ALT",
    "client.urgent": "$ALERT $ALERT $FG $ALERT $ALERT",
    "client.placeholder": "$BG $BG $FG_ALT $BG $BG",
    "client.background": "$BG",
}

# Respect the subtle border - use a muted primary
subtle = "$BG_ALT"
i3_colors["client.focused"] = f"{subtle} $BG_ALT $FG {subtle} {subtle}"

for key, val in i3_colors.items():
    pattern = rf'^{re.escape(key)}\s+.*$'
    replacement = f"{key}          {val}"
    content = re.sub(pattern, replacement, content, flags=re.MULTILINE)

with open("$HOME/.config/i3/config", "w") as f:
    f.write(content)
PYEOF

# === ROFI ===
python3 << PYEOF
import re

with open("$HOME/.config/rofi/config.rasi", "r") as f:
    content = f.read()

rofi_colors = {
    "bg": "$BG",
    "bg-alt": "$BG_ALT",
    "fg": "$FG",
    "fg-alt": "$FG_ALT",
    "primary": "$PRIMARY",
    "secondary": "$SECONDARY",
    "alert": "$ALERT",
}

for key, val in rofi_colors.items():
    content = re.sub(
        rf'({re.escape(key)}:\s*)#[0-9A-Fa-f]{{6}}',
        rf'\g<1>{val}',
        content
    )

with open("$HOME/.config/rofi/config.rasi", "w") as f:
    f.write(content)
PYEOF

# Save current theme
echo "$choice" > "$CURRENT_FILE"

# === NEOVIM ===
# Tell all running nvim instances to switch colorscheme
for sock in /run/user/$(id -u)/nvim.*.0 /tmp/nvim.*/0; do
    [ -S "$sock" ] && nvim --server "$sock" --remote-send "<cmd>colorscheme ricebox-${choice}<cr>" 2>/dev/null
done

# === OBSIDIAN ===
# Swap the active ricebox snippet — obsidian hot-reloads css
OBSIDIAN_SNIPPETS="${RICEBOX_OBSIDIAN_SNIPPETS:-}"
if [ -d "$OBSIDIAN_SNIPPETS" ]; then
    # Copy the chosen theme as the active snippet, using .theme-dark directly (no body class needed)
    sed "s/\.theme-dark\.ricebox-${choice}/.theme-dark/" "$OBSIDIAN_SNIPPETS/ricebox-${choice}.css" > "$OBSIDIAN_SNIPPETS/ricebox-active.css" 2>/dev/null
fi

# === VSCODE ===
VSCODE_SETTINGS="$HOME/.config/Code/User/settings.json"
if [ -f "$VSCODE_SETTINGS" ]; then
    # Convert theme name to title case for vscode
    vscode_theme="Ricebox $(echo "$choice" | sed 's/-/ /g; s/\b\(.\)/\u\1/g')"
    python3 << PYEOF
import json
with open("$VSCODE_SETTINGS", "r") as f:
    settings = json.load(f)
settings["workbench.colorTheme"] = "$vscode_theme"
with open("$VSCODE_SETTINGS", "w") as f:
    json.dump(settings, f, indent=4)
PYEOF
fi

# Reload everything
i3-msg reload > /dev/null 2>&1
pkill -USR1 kitty 2>/dev/null
bash "$HOME/.config/polybar/polybar.sh" &

