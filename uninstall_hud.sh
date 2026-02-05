#!/usr/bin/env bash
# ==========================================================
# Conky HUD Uninstaller
#
# Purpose:
#   - Safely remove the Conky HUD installed by install_hud.sh
#
# Actions:
#   - Stop any running Conky instance
#   - Remove ~/.conkyrc created by this project
#   - Remove GNOME keyboard shortcut ("Toggle Conky HUD")
#
# Non-actions (by design):
#   - Does NOT remove Conky packages
#   - Does NOT touch backup/source files
#
# Reinstall:
#   - You can reinstall anytime using install_hud.sh
# ==========================================================

set -euo pipefail

SCHEMA="org.gnome.settings-daemon.plugins.media-keys"
BASE="/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings"
GSETTINGS="/usr/bin/gsettings"
SED="/usr/bin/sed"

echo "=============================================="
echo " 🧹 Conky HUD Uninstaller"
echo "=============================================="
echo ""

# ----------------------------------------------------------
# 1. Stop running Conky (if any)
# ----------------------------------------------------------
if pgrep -x conky >/dev/null; then
    echo "🛑 Stopping running Conky..."
    pkill conky
    sleep 1
else
    echo "ℹ️  Conky is not running."
fi

# ----------------------------------------------------------
# 2. Remove ~/.conkyrc (HUD config)
# ----------------------------------------------------------
if [[ -f "$HOME/.conkyrc" ]]; then
    echo "🗑️  Removing ~/.conkyrc"
    rm -f "$HOME/.conkyrc"
else
    echo "ℹ️  ~/.conkyrc not found."
fi

# ----------------------------------------------------------
# 3. Remove GNOME keyboard shortcut (if created)
# ----------------------------------------------------------
echo "⌨️  Checking for HUD keyboard shortcut..."

KEYS=$("$GSETTINGS" get $SCHEMA custom-keybindings | tr -d "[]'" | tr ',' '\n')
FOUND=0

for path in $KEYS; do
    NAME=$("$GSETTINGS" get \
        $SCHEMA.custom-keybinding:$path name 2>/dev/null | tr -d "'")

    if [[ "$NAME" == "Toggle Conky HUD" ]]; then
        echo "🗑️  Removing shortcut: $NAME"
        "$GSETTINGS" set \
          $SCHEMA custom-keybindings \
          "$(echo "$KEYS" | grep -v "$path" | paste -sd, - | "$SED" "s/^/'/;s/$/'/")"
        FOUND=1
        break
    fi
done

if [[ "$FOUND" -eq 0 ]]; then
    echo "ℹ️  No Conky HUD shortcut found."
fi

# ----------------------------------------------------------
# 4. Uninstall complete
# ----------------------------------------------------------
echo ""
echo "=============================================="
echo " ✅ HUD UNINSTALLED SUCCESSFULLY"
echo "=============================================="
echo ""
echo "Notes:"
echo " • Conky packages were not removed"
echo " • Backup files remain untouched"
echo " • You can reinstall anytime using install_hud.sh"
