#!/usr/bin/env bash
# ============================================
# BlazzCore — Customize Airootfs (runs in chroot during ISO build)
# ============================================
set -euo pipefail

# Pre-configure locale/timezone so systemd-firstboot doesn't interrupt boot
ln -sf /usr/share/zoneinfo/UTC /etc/localtime
echo "LANG=en_US.UTF-8" > /etc/locale.conf
echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
locale-gen

# Pre-fill machine-id so systemd-firstboot is satisfied
systemd-machine-id-setup

# Set Plymouth theme (only if the theme was installed successfully)
if plymouth-set-default-theme blazzcore 2>/dev/null; then
    plymouth-set-default-theme -R blazzcore
else
    echo "WARNING: BlazzCore Plymouth theme not found, skipping theme set" >&2
fi

# Enable services
systemctl enable NetworkManager
systemctl enable seatd
systemctl enable bluetooth
systemctl enable blazzcore-firstboot.service

# Set empty passwords for live session (passwd -d is safe and explicit)
passwd -d blazzcore
passwd -d root

# Add blazzcore to sudoers
echo "%wheel ALL=(ALL:ALL) NOPASSWD: ALL" > /etc/sudoers.d/wheel

# Generate default wallpapers
mkdir -p /usr/share/backgrounds/blazzcore
if ! python3 /usr/local/bin/blazzcore-gen-wallpapers; then
    echo "WARNING: Wallpaper generation failed" >&2
fi

# Write version file for blazzcore-about
echo "1.0 ($(date +%Y.%m.%d))" > /etc/blazzcore-version

# Update desktop database and icon caches
update-desktop-database /usr/share/applications/ || true
gtk-update-icon-cache -f /usr/share/icons/Papirus-Dark/ 2>/dev/null || true
gtk-update-icon-cache -f /usr/share/icons/Papirus/ 2>/dev/null || true
gtk-update-icon-cache -f /usr/share/icons/hicolor/ 2>/dev/null || true

# Create home directory and standard folders
mkdir -p /home/blazzcore
cp -rT /etc/skel /home/blazzcore
mkdir -p /home/blazzcore/{Desktop,Downloads,Pictures,Documents}
chmod +x /home/blazzcore/Desktop/*.desktop 2>/dev/null || true
chown -R 1000:1000 /home/blazzcore
