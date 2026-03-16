#!/usr/bin/env bash
# BlazzCore ISO Profile Definition

iso_name="blazzcore"
iso_label="BLAZZCORE_$(date +%Y%m%d)"
iso_publisher="Blazzard <https://github.com/blazzard>"
iso_application="BlazzCore Live/Install ISO"
iso_version="$(date +%Y.%m.%d)"
install_dir="blazzcore"
buildmodes=('iso')
bootmodes=(
  'bios.syslinux'
  'uefi.grub'
)
arch="x86_64"
pacman_conf="pacman.conf"
airootfs_image_type="squashfs"
airootfs_image_tool_options=('-comp' 'zstd' '-Xcompression-level' '15' '-b' '1M')
file_permissions=(
  ["/etc/shadow"]="0:0:400"
  ["/etc/gshadow"]="0:0:400"
  ["/root/customize_airootfs.sh"]="0:0:755"
  ["/usr/local/bin/blazzcore-browser"]="0:0:755"
  ["/usr/local/bin/blazzcore-settings"]="0:0:755"
  ["/usr/local/bin/blazzcore-wallpaper"]="0:0:755"
  ["/usr/local/bin/tictactoe"]="0:0:755"
  ["/usr/local/bin/blazzcore-firstboot"]="0:0:755"
  ["/usr/local/bin/blazzcore-gen-wallpapers"]="0:0:755"
  ["/etc/skel/.config/labwc/autostart"]="0:0:755"
  ["/usr/local/bin/blazzcore-accent"]="0:0:755"
  ["/usr/local/bin/blazzcore-volume"]="0:0:755"
  ["/usr/local/bin/blazzcore-brightness"]="0:0:755"
  ["/usr/local/bin/blazzcore-lock"]="0:0:755"
  ["/usr/local/bin/blazzcore-power"]="0:0:755"
  ["/usr/local/bin/blazzcore-screenshot"]="0:0:755"
  ["/usr/local/bin/blazzcore-nightlight"]="0:0:755"
  ["/usr/local/bin/blazzcore-dock"]="0:0:755"
  ["/usr/local/bin/blazzcore-install"]="0:0:755"
  ["/etc/skel/Desktop/install-blazzcore.desktop"]="0:0:755"
  ["/usr/local/bin/blazzcore-about"]="0:0:755"
  ["/usr/local/bin/blazzcore-store"]="0:0:755"
  ["/usr/local/bin/blazzcore-taskmanager"]="0:0:755"
  ["/usr/local/bin/blazzcore-startmenu"]="0:0:755"
  ["/usr/local/bin/blazzcore-startmenu-toggle"]="0:0:755"
  ["/usr/share/blazzcore/postinstall.sh"]="0:0:755"
  ["/usr/local/bin/blazzcore-drivers"]="0:0:755"
  ["/usr/local/bin/blazzcore-window-menu"]="0:0:755"
  ["/etc/profile.d/blazzcore-autostart.sh"]="0:0:755"
)
