#!/usr/bin/env bash
# BlazzCore ISO Profile Definition

iso_name="blazzcore"
iso_label="BLAZZCORE_$(date +%Y%m)"
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
airootfs_image_tool_options=('-comp' 'xz' '-Xbcj' 'x86' '-b' '1M' '-Xdict-size' '1M')
file_permissions=(
  ["/etc/shadow"]="0:0:400"
  ["/etc/gshadow"]="0:0:400"
  ["/root/customize_airootfs.sh"]="0:0:755"
  ["/usr/local/bin/blazzcore-browser"]="0:0:755"
  ["/usr/local/bin/blazzcore-setup"]="0:0:755"
  ["/etc/profile.d/blazzcore-sway-autostart.sh"]="0:0:755"
)
