#!/usr/bin/env bash
# ==========================================================
# Conky HUD Installer
#
# Purpose:
#   - Install and configure a minimal Conky-based system HUD
#   - Generate a user-specific ~/.conkyrc
#   - Optionally create a GNOME keyboard shortcut (Alt + R)
#
# Characteristics:
#   - Declarative and safe to re-run
#   - No helper scripts in $HOME
#   - GNOME-native shortcut handling
#
# Uninstall:
#   - Use uninstall_hud.sh to fully remove this HUD
# ==========================================================

set -euo pipefail

HUD_BACKUP_DIR="$(cd "$(dirname "$0")" && pwd)"
CONKYRC_SOURCE="$HUD_BACKUP_DIR/.conkyrc_nvtop"
CONKYRC_TARGET="$HOME/.conkyrc"
GPU_SCRIPT_SOURCE="$HUD_BACKUP_DIR/.conky_gpu.py"
GPU_SCRIPT_TARGET="$HOME/.conky_gpu.py"

SED="/usr/bin/sed"
GSETTINGS="/usr/bin/gsettings"

echo "=============================================="
echo " 🖥️  Conky HUD Installer"
echo "=============================================="
echo ""

# ----------------------------------------------------------
# 1. Validate installer source files
# ----------------------------------------------------------
if [[ ! -f "$CONKYRC_SOURCE" ]]; then
    echo "❌ Missing .conkyrc_nvtop in project directory."
    exit 1
fi

# ----------------------------------------------------------
# 2. Install required system dependencies
# ----------------------------------------------------------
echo "📦 Installing Conky and required tools (sudo may prompt)..."
sudo apt update
sudo apt install -y conky-all lm-sensors curl

[[ -x /usr/bin/conky ]] || sudo chmod +x /usr/bin/conky

# ----------------------------------------------------------
# 3. Ask user for HUD screen position
# ----------------------------------------------------------
echo ""
echo "📍 Select HUD position (enter the number):"
echo ""
echo "  1) Top-left corner"
echo "  2) Top-right corner  ← recommended"
echo "  3) Bottom-left corner"
echo "  4) Bottom-right corner"
echo ""
echo "Enter a number (1–4) and press Enter."
echo ""

select POS in "top_left" "top_right" "bottom_left" "bottom_right"; do
    [[ -n "$POS" ]] && break
    echo "❌ Invalid choice. Please enter a number between 1 and 4."
done

case "$POS" in
    top_left) ALIGN="top_left"; GAP_X=20; GAP_Y=40 ;;
    top_right) ALIGN="top_right"; GAP_X=20; GAP_Y=40 ;;
    bottom_left) ALIGN="bottom_left"; GAP_X=20; GAP_Y=40 ;;
    bottom_right) ALIGN="bottom_right"; GAP_X=20; GAP_Y=40 ;;
esac

# ----------------------------------------------------------
# 4. Generate user-specific ~/.conkyrc
# ----------------------------------------------------------
echo "🛠️  Generating ~/.conkyrc..."

"$SED" \
  -e "s/alignment = '.*'/alignment = '$ALIGN'/" \
  -e "s/gap_x = [0-9]\\+/gap_x = $GAP_X/" \
  -e "s/gap_y = [0-9]\\+/gap_y = $GAP_Y/" \
  "$CONKYRC_SOURCE" > "$CONKYRC_TARGET"

chmod 644 "$CONKYRC_TARGET"

# ----------------------------------------------------------
# Install GPU helper script (required by Conky config)
# ----------------------------------------------------------
echo "📁 Installing GPU helper script..."
cp -f "$GPU_SCRIPT_SOURCE" "$GPU_SCRIPT_TARGET"
chmod +x "$GPU_SCRIPT_TARGET"

# ----------------------------------------------------------
# 5. Optional GNOME keyboard shortcut (Alt + R)
# ----------------------------------------------------------
echo ""
read -rp "⌨️  Create keyboard shortcut to toggle HUD? (y/n): " WANT_KEY

if [[ "$WANT_KEY" =~ ^[Yy]$ ]]; then
    SCHEMA="org.gnome.settings-daemon.plugins.media-keys"
    BASE="/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings"

    EXISTING_RAW=$("$GSETTINGS" get $SCHEMA custom-keybindings)
    EXISTING_PATHS=$(echo "$EXISTING_RAW" | tr -d "[]'" | tr ',' '\n' | "$SED" '/^$/d')

    IDX=$(echo "$EXISTING_PATHS" | wc -l)
    NEW_PATH="$BASE/custom$IDX/"

    NEW_LIST=$(printf "'%s', " $EXISTING_PATHS "$NEW_PATH")
    NEW_LIST="[${NEW_LIST%, }]"

    "$GSETTINGS" set $SCHEMA custom-keybindings "$NEW_LIST"

    "$GSETTINGS" set $SCHEMA.custom-keybinding:$NEW_PATH name "Toggle Conky HUD"
    "$GSETTINGS" set $SCHEMA.custom-keybinding:$NEW_PATH \
        command "bash -c 'pgrep -x conky >/dev/null && pkill conky || conky'"
    "$GSETTINGS" set $SCHEMA.custom-keybinding:$NEW_PATH binding "<Alt>r"

    echo "✅ Shortcut created: Alt + R"
    echo "ℹ️  You can change this later in Settings → Keyboard → Custom Shortcuts"
else
    echo "⏭️  Skipping shortcut setup."
fi

# ----------------------------------------------------------
# 6. Installation complete
# ----------------------------------------------------------
echo ""
echo "=============================================="
echo " 🎉 HUD INSTALLED SUCCESSFULLY"
echo "=============================================="
echo ""
echo "Start HUD manually:"
echo "  conky"
echo ""
echo "Uninstall anytime using:"
echo "  ./uninstall_hud.sh"
