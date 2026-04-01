#!/bin/bash
# Source the current theme colors - used by polybar scripts
THEME_DIR="$HOME/.config/themes"
current=$(cat "$THEME_DIR/.current" 2>/dev/null || echo "dark-green")
source "$THEME_DIR/${current}.sh"
