#!/usr/bin/env bash
# ============================================
# BlazzCore — Customize Airootfs (runs in chroot during ISO build)
# ============================================
set -euo pipefail

# Generate locale
locale-gen

# Set Plymouth theme
plymouth-set-default-theme -R blazzcore

# Enable services
systemctl enable NetworkManager
systemctl enable seatd

# Set up user password (empty password for live session)
echo "blazzcore:" | chpasswd -e
echo "root:" | chpasswd -e

# Add blazzcore to sudoers
echo "%wheel ALL=(ALL:ALL) NOPASSWD: ALL" > /etc/sudoers.d/wheel

# Create home directory
mkdir -p /home/blazzcore
cp -rT /etc/skel /home/blazzcore
chown -R 1000:1000 /home/blazzcore
