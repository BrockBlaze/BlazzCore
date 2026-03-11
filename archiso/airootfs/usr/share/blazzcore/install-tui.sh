#!/usr/bin/env bash
# BlazzCore — TUI Installer (runs inside a foot terminal)
set -euo pipefail

# ---- Colours ----
RED='\033[0;31m'; YEL='\033[0;33m'; GRN='\033[0;32m'
CYN='\033[0;36m'; BLD='\033[1m'; RST='\033[0m'

print_header() {
    clear
    echo -e "${CYN}"
    echo "  ██████╗ ██╗      █████╗ ███████╗███████╗ ██████╗ ██████╗ ██████╗ ███████╗"
    echo "  ██╔══██╗██║     ██╔══██╗╚══███╔╝╚══███╔╝██╔════╝██╔═══██╗██╔══██╗██╔════╝"
    echo "  ██████╔╝██║     ███████║  ███╔╝   ███╔╝ ██║     ██║   ██║██████╔╝█████╗  "
    echo "  ██╔══██╗██║     ██╔══██║ ███╔╝   ███╔╝  ██║     ██║   ██║██╔══██╗██╔══╝  "
    echo "  ██████╔╝███████╗██║  ██║███████╗███████╗╚██████╗╚██████╔╝██║  ██║███████╗"
    echo "  ╚═════╝ ╚══════╝╚═╝  ╚═╝╚══════╝╚══════╝ ╚═════╝ ╚═════╝ ╚═╝  ╚═╝╚══════╝"
    echo -e "${RST}"
    echo -e "  ${BLD}Disk Installer${RST}  —  Arch Linux base + BlazzCore desktop"
    echo -e "  ─────────────────────────────────────────────────────────"
    echo ""
}

print_header

echo -e "${YEL}  This installer uses archinstall to set up the base system,"
echo -e "  then automatically applies the BlazzCore desktop on top.${RST}"
echo ""
echo -e "  ${BLD}Steps:${RST}"
echo -e "    1. archinstall   — partition disk, set user/password, install packages"
echo -e "    2. postinstall   — copy BlazzCore configs and enable all services"
echo ""
echo -e "  ${YEL}⚠  Warning: your selected disk will be erased.${RST}"
echo ""
read -rp "  Press Enter to launch archinstall, or Ctrl+C to cancel... "

echo ""
echo -e "${CYN}  Launching archinstall...${RST}"
echo ""

# Run archinstall with our pre-filled config (user can override any setting)
archinstall --config /usr/share/blazzcore/archinstall-config.json

# ---- Post-install ----
echo ""
echo -e "${GRN}  ✓ archinstall finished.${RST}"
echo ""

# Verify the installation mount point exists
MOUNT=/mnt
if [[ ! -d "$MOUNT/usr" ]]; then
    echo -e "${YEL}  Could not find installed system at $MOUNT."
    echo -e "  If archinstall used a different mount point, run manually:"
    echo -e "    sudo bash /usr/share/blazzcore/postinstall.sh <mountpoint>${RST}"
    read -rp "  Press Enter to exit..."
    exit 0
fi

echo -e "  Applying BlazzCore desktop configuration to installed system..."
echo ""
bash /usr/share/blazzcore/postinstall.sh "$MOUNT"

echo ""
echo -e "${GRN}  ╔══════════════════════════════════════════════╗"
echo -e "  ║   BlazzCore installation complete!  🎉      ║"
echo -e "  ╚══════════════════════════════════════════════╝${RST}"
echo ""
echo -e "  You can now reboot into your new BlazzCore system."
echo -e "  ${BLD}Remember to remove the ISO / USB before rebooting.${RST}"
echo ""
read -rp "  Press Enter to close..."
