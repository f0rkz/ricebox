#!/usr/bin/env bash
# Build and run ricebox installer tests for each supported OS.
# Usage: test/run.sh [debian|arch]    (no arg = both)
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

TARGETS=("$@")
if [ ${#TARGETS[@]} -eq 0 ]; then
  TARGETS=(debian arch)
fi

# post-install verification (runs inside the container)
VERIFY='
set -e
fail=0
check() {
  if [ -e "$2" ]; then
    echo "  ✓ $1 ($2)"
  else
    echo "  ✗ missing: $1 ($2)"
    fail=1
  fi
}
echo "--- verifying install ---"
check "polybar config"  "$HOME/.config/polybar/config.ini"
check "kitty config"    "$HOME/.config/kitty/kitty.conf"
check "i3 config"       "$HOME/.config/i3/config"
check "rofi config"     "$HOME/.config/rofi/config.rasi"
check "picom config"    "$HOME/.config/picom/picom.conf"
check "themes dir"      "$HOME/.config/themes"
check "theme state"     "$HOME/.config/themes/.current"
check "ricebox.env"     "$HOME/.config/ricebox.env"
check "nvim colors"     "$HOME/.config/nvim/colors"
exit "$fail"
'

run_test() {
  local name=$1
  local dockerfile="test/Dockerfile.$name"
  local tag="ricebox-test:$name"

  echo
  echo "================================================"
  echo "  building: $name  ($dockerfile)"
  echo "================================================"
  docker build -t "$tag" -f "$dockerfile" "$REPO_ROOT"

  echo
  echo "------------------------------------------------"
  echo "  running installer: $name"
  echo "------------------------------------------------"
  docker run --rm "$tag" bash -c "./install.sh && $VERIFY"

  echo "=== $name: PASS ==="
}

for t in "${TARGETS[@]}"; do
  case "$t" in
    debian|arch) run_test "$t" ;;
    *) echo "unknown target: $t" >&2; exit 1 ;;
  esac
done

echo
echo "all tests passed 🎉"
