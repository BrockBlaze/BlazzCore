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

# Set Plymouth theme
plymouth-set-default-theme -R blazzcore

# Enable services
systemctl enable NetworkManager
systemctl enable seatd
systemctl enable blazzcore-firstboot.service

# Set up user password (empty password for live session)
echo "blazzcore:" | chpasswd -e
echo "root:" | chpasswd -e

# Add blazzcore to sudoers
echo "%wheel ALL=(ALL:ALL) NOPASSWD: ALL" > /etc/sudoers.d/wheel

# Update desktop database so app icons resolve in dock/launcher
update-desktop-database /usr/share/applications/ || true

# Create home directory and standard folders
mkdir -p /home/blazzcore
cp -rT /etc/skel /home/blazzcore
mkdir -p /home/blazzcore/{Desktop,Downloads,Pictures,Documents}
chown -R 1000:1000 /home/blazzcore
