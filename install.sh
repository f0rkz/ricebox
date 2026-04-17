#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="$HOME/.config/ricebox.env"

echo "=== ricebox installer ==="

# --- detect OS ---
OS_FAMILY="unknown"
if [ -r /etc/os-release ]; then
  # shellcheck disable=SC1091
  . /etc/os-release
  case "${ID:-}:${ID_LIKE:-}" in
    *arch*|*cachyos*|*:*arch*) OS_FAMILY="arch" ;;
    *debian*|*ubuntu*|*:*debian*|*:*ubuntu*) OS_FAMILY="debian" ;;
  esac
fi
echo "  detected os family: $OS_FAMILY"

# --- dependencies ---
echo "[1/6] checking dependencies..."

DEPS=(
  polybar i3 picom kitty rofi
  jq xdotool xclip maim nitrogen
  nmcli bluetoothctl tailscale
  curl wget unzip
)

MISSING=()
for dep in "${DEPS[@]}"; do
  if ! command -v "$dep" &>/dev/null; then
    MISSING+=("$dep")
  fi
done

if [ ${#MISSING[@]} -gt 0 ]; then
  echo "  missing: ${MISSING[*]}"

  case "$OS_FAMILY" in
    debian)
      declare -A PKG_MAP=(
        [polybar]=polybar
        [i3]=i3
        [picom]=picom
        [kitty]=kitty
        [rofi]=rofi
        [jq]=jq
        [xdotool]=xdotool
        [xclip]=xclip
        [maim]=maim
        [nitrogen]=nitrogen
        [nmcli]=network-manager
        [bluetoothctl]=bluez
        [curl]=curl
        [wget]=wget
        [unzip]=unzip
        [tailscale]=tailscale
      )
      INSTALLER=(sudo apt install -y)
      ;;
    arch)
      declare -A PKG_MAP=(
        [polybar]=polybar
        [i3]=i3-wm
        [picom]=picom
        [kitty]=kitty
        [rofi]=rofi
        [jq]=jq
        [xdotool]=xdotool
        [xclip]=xclip
        [maim]=maim
        [nitrogen]=nitrogen
        [nmcli]=networkmanager
        [bluetoothctl]=bluez-utils
        [curl]=curl
        [wget]=wget
        [unzip]=unzip
        [tailscale]=tailscale
      )
      INSTALLER=(sudo pacman -S --needed --noconfirm)
      ;;
    *)
      echo "  unknown OS family - install manually: ${MISSING[*]}"
      INSTALLER=()
      ;;
  esac

  if [ ${#INSTALLER[@]} -gt 0 ]; then
    echo "  attempting install via ${INSTALLER[0]}..."
    PKGS=()
    for m in "${MISSING[@]}"; do
      if [ "${PKG_MAP[$m]+exists}" ]; then
        PKGS+=("${PKG_MAP[$m]}")
      else
        echo "  skipping $m (install manually)"
      fi
    done

    if [ ${#PKGS[@]} -gt 0 ]; then
      "${INSTALLER[@]}" "${PKGS[@]}"
    fi
  fi
fi

# --- fonts ---
echo "[2/6] installing fonts..."

FONT_DIR="$HOME/.local/share/fonts"
mkdir -p "$FONT_DIR"

if ! fc-list | grep -qi "0xProto Nerd Font"; then
  echo "  installing 0xProto Nerd Font..."
  NERD_VER="v3.3.0"
  wget -qO /tmp/0xProto.zip "https://github.com/ryanoasis/nerd-fonts/releases/download/${NERD_VER}/0xProto.zip"
  unzip -qo /tmp/0xProto.zip -d "$FONT_DIR"
  rm /tmp/0xProto.zip
else
  echo "  0xProto Nerd Font already installed"
fi

if ! fc-list | grep -qi "Font Awesome 6"; then
  echo "  installing Font Awesome 6..."
  wget -qO /tmp/fa6.zip "https://use.fontawesome.com/releases/v6.5.1/fontawesome-free-6.5.1-desktop.zip"
  unzip -qo /tmp/fa6.zip -d /tmp/fa6
  cp /tmp/fa6/fontawesome-free-6.5.1-desktop/otfs/*.otf "$FONT_DIR/"
  rm -rf /tmp/fa6 /tmp/fa6.zip
else
  echo "  Font Awesome 6 already installed"
fi

fc-cache -f

# --- configs ---
echo "[3/6] installing configs..."

declare -A CONFIG_MAP=(
  [polybar]="$HOME/.config/polybar"
  [kitty]="$HOME/.config/kitty"
  [i3]="$HOME/.config/i3"
  [rofi]="$HOME/.config/rofi"
  [picom]="$HOME/.config/picom"
  [themes]="$HOME/.config/themes"
)

for src in "${!CONFIG_MAP[@]}"; do
  dest="${CONFIG_MAP[$src]}"

  if [ -d "$dest" ] && [ ! -L "$dest" ]; then
    if [ -f "$dest/config" ] || [ -f "$dest/config.ini" ] || [ -f "$dest/kitty.conf" ] || [ -f "$dest/config.rasi" ] || [ -f "$dest/picom.conf" ]; then
      echo "  backing up $dest -> ${dest}.pre-ricebox"
      cp -r "$dest" "${dest}.pre-ricebox" 2>/dev/null || true
    fi
  fi

  mkdir -p "$dest"
  cp -r "$SCRIPT_DIR/$src/"* "$dest/"
  echo "  installed $src -> $dest"
done

chmod +x "$HOME/.config/polybar/polybar.sh"
chmod +x "$HOME/.config/polybar/scripts/"*.sh
chmod +x "$HOME/.config/themes/current-colors.sh"

# Generate and install nvim colorschemes
echo "  generating nvim colorschemes..."
mkdir -p "$HOME/.config/nvim/colors"
bash "$SCRIPT_DIR/nvim/generate-themes.sh"
cp "$SCRIPT_DIR/nvim/colors/"*.lua "$HOME/.config/nvim/colors/"

# --- environment config ---
echo "[4/6] configuring environment..."

if [ -f "$ENV_FILE" ]; then
  echo "  $ENV_FILE already exists, skipping"
else
  # Detect home SSID
  CURRENT_SSID=$(nmcli -t -f active,ssid dev wifi 2>/dev/null | grep '^yes' | cut -d: -f2 || echo "")
  if [ -n "$CURRENT_SSID" ]; then
    read -p "  current wifi is '$CURRENT_SSID' - use as home network? [y/N] " yn
    if [[ "$yn" =~ ^[Yy] ]]; then
      HOME_SSID="$CURRENT_SSID"
    fi
  fi

  read -p "  home city for weather (e.g. Seattle+Washington+US): " HOME_LOC

  # Detect DPI
  DPI=96
  PRIMARY_RES=$(xrandr --query 2>/dev/null | grep " connected primary" | grep -oP '\d+x\d+' | head -1)
  if [ -n "$PRIMARY_RES" ]; then
    WIDTH=$(echo "$PRIMARY_RES" | cut -dx -f1)
    if [ "$WIDTH" -ge 3840 ]; then DPI=192
    elif [ "$WIDTH" -ge 2560 ]; then DPI=144
    fi
    echo "  detected resolution $PRIMARY_RES -> dpi $DPI"
  fi

  # Detect vertical monitor
  VERT=""
  ROTATED=$(xrandr --query 2>/dev/null | grep " connected" | grep -E "left|right" | cut -d" " -f1 || true)
  if [ -n "$ROTATED" ]; then
    echo "  detected vertical monitor: $ROTATED"
    VERT="$ROTATED"
  fi

  # Detect laptop panel
  LAPTOP_PANEL=""
  LAPTOP_OUT=$(xrandr --query 2>/dev/null | grep " connected" | grep -oP '^eDP-?\d+' | head -1 || true)
  if [ -n "$LAPTOP_OUT" ]; then
    echo "  detected laptop panel: $LAPTOP_OUT"
    LAPTOP_PANEL="$LAPTOP_OUT"
  fi

  # Detect temp sensor
  TEMP_SENSOR=""
  for h in /sys/class/hwmon/hwmon*; do
    name=$(cat "${h}/name" 2>/dev/null)
    if [ "$name" = "k10temp" ] || [ "$name" = "coretemp" ]; then
      TEMP_SENSOR="${h}/temp1_input"
      echo "  detected temp sensor: $TEMP_SENSOR"
      break
    fi
  done

  # Font selection
  read -p "  font name [0xProto Nerd Font]: " FONT_NAME
  FONT_NAME="${FONT_NAME:-0xProto Nerd Font}"
  read -p "  font size [12]: " FONT_SIZE
  FONT_SIZE="${FONT_SIZE:-12}"

  cat > "$ENV_FILE" << ENVEOF
# ricebox environment config
RICEBOX_HOME_SSID="${HOME_SSID:-}"
RICEBOX_HOME_LOCATION="${HOME_LOC:-}"
RICEBOX_DPI=${DPI}
RICEBOX_VERTICAL_MONITOR="${VERT}"
RICEBOX_LAPTOP_PANEL="${LAPTOP_PANEL:-eDP-1}"
RICEBOX_DEFAULT_THEME="dark-green"
RICEBOX_TEMP_SENSOR="${TEMP_SENSOR}"
RICEBOX_FONT="${FONT_NAME}"
RICEBOX_FONT_SIZE=${FONT_SIZE}
RICEBOX_OBSIDIAN_SNIPPETS=""
ENVEOF

  echo "  wrote $ENV_FILE"
fi

# Apply env to polybar config
source "$ENV_FILE"
if [ -n "${RICEBOX_TEMP_SENSOR:-}" ]; then
  TEMP_ESCAPED=$(echo "$RICEBOX_TEMP_SENSOR" | sed 's/[&/\]/\\&/g')
  sed -i "s|hwmon-path = .*|hwmon-path = $TEMP_ESCAPED|" "$HOME/.config/polybar/config.ini"
fi
if [ -n "${RICEBOX_DPI:-}" ]; then
  sed -i "s/dpi-x = .*/dpi-x = $RICEBOX_DPI/" "$HOME/.config/polybar/config.ini"
  sed -i "s/dpi-y = .*/dpi-y = $RICEBOX_DPI/" "$HOME/.config/polybar/config.ini"
fi

# Apply font settings
FONT="${RICEBOX_FONT:-0xProto Nerd Font}"
FSIZE="${RICEBOX_FONT_SIZE:-12}"
POLYBAR_FSIZE=$((FSIZE - 2))

# polybar
sed -i "s/font-0 = .*/font-0 = ${FONT}:style=Regular:pixelsize=${POLYBAR_FSIZE};2/" "$HOME/.config/polybar/config.ini"
sed -i "s/font-2 = .*/font-2 = ${FONT}:style=Regular:pixelsize=$((POLYBAR_FSIZE + 4));3/" "$HOME/.config/polybar/config.ini"

# kitty
sed -i "s/^font_family .*/font_family      ${FONT}/" "$HOME/.config/kitty/kitty.conf"
sed -i "s/^font_size .*/font_size        ${FSIZE}/" "$HOME/.config/kitty/kitty.conf"

# rofi
sed -i "s|font:.*|font:             \"${FONT} ${FSIZE}\";|" "$HOME/.config/rofi/config.rasi"

echo "  applied font: ${FONT} @ ${FSIZE}px"

if [ ! -f "$HOME/.config/themes/.current" ]; then
  echo "${RICEBOX_DEFAULT_THEME:-dark-green}" > "$HOME/.config/themes/.current"
fi

# --- sudoers ---
echo "[5/6] setting up sudoers rules..."

echo "  needed for power profiles and tailscale switching"
read -p "  install sudoers rules? [y/N] " yn || yn=""
if [[ "$yn" =~ ^[Yy] ]]; then
  USER=$(whoami)
  sudo tee /etc/sudoers.d/ricebox > /dev/null << SUDOEOF
$USER ALL=(ALL) NOPASSWD: /usr/bin/tee /sys/firmware/acpi/platform_profile
$USER ALL=(ALL) NOPASSWD: /usr/bin/tee /sys/devices/system/cpu/cpu*/cpufreq/energy_performance_preference
$USER ALL=(ALL) NOPASSWD: /usr/bin/tailscale set --exit-node=*
$USER ALL=(ALL) NOPASSWD: /usr/bin/tailscale up
$USER ALL=(ALL) NOPASSWD: /usr/bin/tailscale down
SUDOEOF
  sudo chmod 440 /etc/sudoers.d/ricebox
  echo "  sudoers installed"
fi

# --- extras ---
echo "[6/6] optional extras..."

if ! command -v tzupdate &>/dev/null; then
  read -p "  install tzupdate for auto timezone? [y/N] " yn || yn=""
  if [[ "$yn" =~ ^[Yy] ]]; then
    case "$OS_FAMILY" in
      arch)
        # arch blocks system pip (PEP 668) - prefer AUR helper, else pipx
        if command -v paru &>/dev/null; then
          paru -S --needed --noconfirm tzupdate
        elif command -v yay &>/dev/null; then
          yay -S --needed --noconfirm tzupdate
        elif command -v pipx &>/dev/null; then
          pipx install tzupdate
        else
          echo "  no paru/yay/pipx found - install one, or: pacman -S python-pipx && pipx install tzupdate"
        fi
        ;;
      debian)
        if command -v pipx &>/dev/null; then
          pipx install tzupdate
        else
          pip install --user tzupdate
        fi
        ;;
      *)
        pip install --user tzupdate || echo "  install manually"
        ;;
    esac
  fi
fi

if [ ! -f /etc/NetworkManager/dispatcher.d/99-timezone ]; then
  read -p "  install NetworkManager timezone auto-switch? [y/N] " yn || yn=""
  if [[ "$yn" =~ ^[Yy] ]]; then
    TZPATH=$(which tzupdate 2>/dev/null || echo "/usr/local/bin/tzupdate")
    sudo tee /etc/NetworkManager/dispatcher.d/99-timezone > /dev/null << TZEOF
#!/bin/bash
if [ "\$2" = "up" ] || [ "\$2" = "connectivity-change" ]; then
    $TZPATH 2>/dev/null
fi
TZEOF
    sudo chmod 755 /etc/NetworkManager/dispatcher.d/99-timezone
    echo "  timezone dispatcher installed"
  fi
fi

echo ""
echo "=== ricebox installed ==="
echo "  edit $ENV_FILE to change settings"
echo "  reload i3: \$mod+Shift+r"
echo "  switch themes: click the palette icon"
echo ""
