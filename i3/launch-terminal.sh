#!/usr/bin/env bash
set -euo pipefail

# Ubuntu/Debian installs the maintainer-provided kitty here. Use it explicitly
# so i3 does not fall back to the apt binary when ~/.local/bin is absent from
# the desktop-session PATH. Arch continues to use its packaged kitty.
UPSTREAM_KITTY="$HOME/.local/kitty.app/bin/kitty"
if [ -x "$UPSTREAM_KITTY" ]; then
  exec "$UPSTREAM_KITTY"
fi

exec kitty
