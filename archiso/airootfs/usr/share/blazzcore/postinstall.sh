#!/usr/bin/env bash
# BlazzCore Post-Install Script
# Copies BlazzCore configs onto a fresh archinstall base.
# Usage: postinstall.sh [mountpoint]   (default: /mnt)
set -euo pipefail

MOUNT="${1:-/mnt}"
LIVE_SKEL="/etc/skel"
LIVE_BIN="/usr/local/bin"
LIVE_SHARE="/usr/share"

RED='\033[0;31m'; GRN='\033[0;32m'; CYN='\033[0;36m'; RST='\033[0m'
info()  { echo -e "  ${CYN}→${RST} $*"; }
ok()    { echo -e "  ${GRN}✓${RST} $*"; }
warn()  { echo -e "  ${RED}!${RST} $*"; }

# ---- Sanity checks ----
[[ -d "$MOUNT/usr" ]] || { warn "Mount point $MOUNT doesn't look like an installation."; exit 1; }

# Require at least 512 MB free on the target mount
FREE_KB=$(df -k "$MOUNT" | awk 'NR==2{print $4}')
if [[ "$FREE_KB" -lt 524288 ]]; then
    warn "Less than 512 MB free on $MOUNT (${FREE_KB} KB). Aborting."
    exit 1
fi
info "Free space on $MOUNT: $((FREE_KB / 1024)) MB — OK."

# ---- Detect installed username ----
INSTALL_USER=""
for d in "$MOUNT/home"/*/; do
    name=$(basename "$d")
    [[ "$name" != "lost+found" ]] && INSTALL_USER="$name" && break
done
if [[ -z "$INSTALL_USER" ]]; then
    warn "No user home directory found in $MOUNT/home — using 'blazzcore' as fallback."
    INSTALL_USER="blazzcore"
fi
info "Configuring for user: $INSTALL_USER"

# ---- Copy BlazzCore scripts ----
info "Copying BlazzCore scripts..."
cp -f "$LIVE_BIN"/blazzcore-*   "$MOUNT/usr/local/bin/" 2>/dev/null || true
chmod 755 "$MOUNT/usr/local/bin"/blazzcore-* 2>/dev/null || true
ok "Scripts copied."

# ---- Copy skel / user configs ----
info "Copying desktop configuration..."
cp -rT "$LIVE_SKEL/.config" "$MOUNT/etc/skel/.config" 2>/dev/null || true
cp -rT "$LIVE_SKEL/.local"  "$MOUNT/etc/skel/.local"  2>/dev/null || true

# Apply to the installed user's home
USER_HOME="$MOUNT/home/$INSTALL_USER"
mkdir -p "$USER_HOME"
cp -rT "$LIVE_SKEL/.config" "$USER_HOME/.config" 2>/dev/null || true
cp -rT "$LIVE_SKEL/.local"  "$USER_HOME/.local"  2>/dev/null || true
mkdir -p "$USER_HOME"/{Desktop,Downloads,Pictures,Documents}

# Set ownership — use getent for robust UID/GID detection
INSTALL_UID=$(getent passwd -s files "$INSTALL_USER" 2>/dev/null | cut -d: -f3)
INSTALL_GID=$(getent passwd -s files "$INSTALL_USER" 2>/dev/null | cut -d: -f4)
# Fallback: read directly from target passwd
if [[ -z "$INSTALL_UID" ]]; then
    INSTALL_UID=$(awk -F: -v u="$INSTALL_USER" '$1==u{print $3}' "$MOUNT/etc/passwd" 2>/dev/null)
    INSTALL_GID=$(awk -F: -v u="$INSTALL_USER" '$1==u{print $4}' "$MOUNT/etc/passwd" 2>/dev/null)
fi
INSTALL_UID=${INSTALL_UID:-1000}
INSTALL_GID=${INSTALL_GID:-1000}
chown -R "$INSTALL_UID:$INSTALL_GID" "$USER_HOME"
ok "User configs applied to /home/$INSTALL_USER."

# ---- Wallpapers ----
info "Generating wallpapers..."
mkdir -p "$MOUNT/usr/share/backgrounds/blazzcore"
if command -v python3 &>/dev/null; then
    python3 "$LIVE_BIN/blazzcore-gen-wallpapers" \
        && cp /usr/share/backgrounds/blazzcore/*.png \
              "$MOUNT/usr/share/backgrounds/blazzcore/" 2>/dev/null || true
fi
ok "Wallpapers ready."

# ---- Themes ----
info "Copying window theme..."
if [[ -d "$LIVE_SHARE/themes/BlazzCore" ]]; then
    mkdir -p "$MOUNT/usr/share/themes"
    cp -r "$LIVE_SHARE/themes/BlazzCore" "$MOUNT/usr/share/themes/"
fi
ok "Theme copied."

# ---- Plymouth theme ----
info "Copying Plymouth splash theme..."
if [[ -d "$LIVE_SHARE/plymouth/themes/blazzcore" ]]; then
    mkdir -p "$MOUNT/usr/share/plymouth/themes"
    cp -r "$LIVE_SHARE/plymouth/themes/blazzcore" \
          "$MOUNT/usr/share/plymouth/themes/"
fi
ok "Plymouth theme copied."

# ---- Font config ----
info "Copying font config..."
mkdir -p "$MOUNT/etc/fonts"
[[ -f /etc/fonts/local.conf ]] && cp /etc/fonts/local.conf "$MOUNT/etc/fonts/local.conf"
ok "Font config copied."

# ---- zram config ----
info "Copying zram config..."
mkdir -p "$MOUNT/etc/systemd"
[[ -f /etc/systemd/zram-generator.conf ]] && \
    cp /etc/systemd/zram-generator.conf "$MOUNT/etc/systemd/zram-generator.conf"
ok "zram config copied."

# ---- mkinitcpio.conf (add plymouth hook) ----
info "Configuring Plymouth in mkinitcpio..."
if [[ -f "$MOUNT/etc/mkinitcpio.conf" ]]; then
    # Replace HOOKS line — add plymouth after udev
    sed -i 's/^HOOKS=(\(.*\)udev\(.*\))/HOOKS=(\1udev plymouth\2)/' \
        "$MOUNT/etc/mkinitcpio.conf"
fi
ok "mkinitcpio configured."

# ---- Autologin ----
info "Setting up autologin for $INSTALL_USER..."
mkdir -p "$MOUNT/etc/systemd/system/getty@tty1.service.d"
cat > "$MOUNT/etc/systemd/system/getty@tty1.service.d/autologin.conf" <<EOF
[Service]
ExecStart=
ExecStart=-/sbin/agetty -o '-p -f -- \\\\u' --noclear --autologin ${INSTALL_USER} %I \$TERM
EOF
ok "Autologin configured."

# ---- profile.d autostart ----
info "Copying labwc autostart profile..."
mkdir -p "$MOUNT/etc/profile.d"
[[ -f /etc/profile.d/blazzcore-sway-autostart.sh ]] && \
    cp /etc/profile.d/blazzcore-sway-autostart.sh \
       "$MOUNT/etc/profile.d/blazzcore-sway-autostart.sh" && \
    chmod 755 "$MOUNT/etc/profile.d/blazzcore-sway-autostart.sh"
ok "Autostart script copied."

# ---- arch-chroot commands ----
info "Running post-install commands in chroot..."
arch-chroot "$MOUNT" /bin/bash -s <<'CHROOT'
set -e

# Enable services
systemctl enable NetworkManager    2>/dev/null || true
systemctl enable seatd             2>/dev/null || true
systemctl enable bluetooth         2>/dev/null || true

# Plymouth default theme
plymouth-set-default-theme blazzcore 2>/dev/null || true

# Rebuild initramfs with Plymouth
mkinitcpio -P 2>/dev/null || true

# Add quiet splash to grub
if [[ -f /etc/default/grub ]]; then
    sed -i 's/^GRUB_CMDLINE_LINUX_DEFAULT=.*/GRUB_CMDLINE_LINUX_DEFAULT="quiet splash"/' \
        /etc/default/grub
    grub-mkconfig -o /boot/grub/grub.cfg 2>/dev/null || true
fi

# Locale and timezone
ln -sf /usr/share/zoneinfo/UTC /etc/localtime
echo "LANG=en_US.UTF-8" > /etc/locale.conf
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen 2>/dev/null || true

# XDG user dirs
xdg-user-dirs-update 2>/dev/null || true

# Update desktop database
update-desktop-database /usr/share/applications/ 2>/dev/null || true
gtk-update-icon-cache /usr/share/icons/Papirus-Dark/ -f 2>/dev/null || true
CHROOT

ok "Chroot commands complete."

# ---- Add user to required groups ----
info "Adding $INSTALL_USER to groups..."
for grp in wheel video audio input seat network; do
    arch-chroot "$MOUNT" usermod -aG "$grp" "$INSTALL_USER" 2>/dev/null || true
done
ok "Groups configured."

# ---- sudoers ----
info "Configuring sudo..."
echo "%wheel ALL=(ALL:ALL) NOPASSWD: ALL" \
    > "$MOUNT/etc/sudoers.d/wheel"
chmod 440 "$MOUNT/etc/sudoers.d/wheel"
ok "sudo configured."

echo ""
echo -e "  ${GRN}BlazzCore post-install complete!${RST}"
