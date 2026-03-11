# BlazzCore

A minimal, fast, Wayland-first Linux operating system built on Arch Linux.

![BlazzCore](BlazzCore.png)

---

## Overview

BlazzCore is a custom Linux distro focused on simplicity, performance, and GPU-accelerated browsing. It ships a complete desktop experience out of the box — floating windows, a dock, clipboard history, and Chromium with hardware video decoding — while staying lean enough to run comfortably on modest hardware.

| Component | Package |
|-----------|---------|
| Base | Arch Linux (rolling release) |
| Compositor | Sway (Wayland) |
| Bar | Waybar |
| Terminal | foot |
| Browser | Chromium (VA-API GPU acceleration) |
| Audio | PipeWire + WirePlumber |
| File Manager | Thunar + PCManFM |
| Dock | nwg-dock |
| Packages | pacman |

---

## Features

- **Floating desktop** — all windows open floating with title bars by default; tiling available via keybinds
- **Desktop icons** — PCManFM runs in desktop mode for file shortcuts
- **Right-click menu** — right-click the desktop to open a quick-launch context menu
- **Dock** — autohiding bottom dock via nwg-dock
- **Clipboard history** — `Super+V` opens a searchable clipboard history (cliphist)
- **Settings GUI** — `Super+,` launches a settings menu for display, themes, wallpaper, sound, and network
- **Wallpaper picker** — file chooser applies wallpaper live and persists it across reboots
- **Multi-monitor support** — wdisplays for graphical display/resolution management
- **Boot splash** — custom Plymouth theme with BlazzCore logo
- **GPU acceleration** — Mesa VA-API drivers for Intel and AMD; Chromium uses hardware video decode
- **Broad hardware support** — linux-firmware, sof-firmware, alsa-firmware, wireless-regdb, b43-fwcutter
- **Tic Tac Toe** — terminal game with singleplayer bot (Easy / Medium / Hard minimax) and multiplayer

---

## Building the ISO

BlazzCore is built automatically via GitHub Actions on every push to `main`. No local Linux install required.

### Download a pre-built ISO

1. Go to the [**Actions**](../../actions) tab
2. Click the latest successful **"Build BlazzCore ISO"** run
3. Download the **`blazzcore-iso`** artifact
4. Extract the zip to get the `.iso` file

### Build locally (requires Arch Linux)

```bash
sudo pacman -S archiso
git clone https://github.com/BrockBlaze/BlazzCore.git
cd BlazzCore
sudo mkarchiso -v -w /tmp/blazzcore-build -o /tmp/blazzcore-out archiso/
```

---

## Flashing to USB

Use [Rufus](https://rufus.ie) (Windows) or [Ventoy](https://ventoy.net):

**Rufus:**
- Device: your USB drive
- Boot selection: select the `.iso`
- Partition scheme: GPT
- Write in **DD Image** mode

**Ventoy:** just copy the `.iso` onto the Ventoy USB drive.

---

## Keyboard Shortcuts

| Shortcut | Action |
|----------|--------|
| `Super + Enter` | Open terminal (foot) |
| `Super + D` | App launcher (wofi) |
| `Super + B` | Open browser (Chromium) |
| `Super + E` | File manager (Thunar) |
| `Super + V` | Clipboard history |
| `Super + ,` | Settings |
| `Super + Print` | Area screenshot |
| `Print` | Full screenshot |
| `Super + Shift + Q` | Close window |
| `Super + Shift + Space` | Toggle floating/tiling |
| `Super + F` | Fullscreen |
| `Super + 1-5` | Switch workspace |
| `Super + Shift + E` | Exit Sway |

---

## Post-Boot

```bash
# Connect to Wi-Fi
nmtui

# Update all packages
sudo pacman -Syu

# Launch browser
blazzcore-browser

# Open settings
blazzcore-settings

# Play Tic Tac Toe
tictactoe
```

---

## Project Structure

```
archiso/
├── profiledef.sh              # ISO profile (name, label, boot modes)
├── packages.x86_64            # Full package list
├── pacman.conf                # Pacman configuration
├── grub/grub.cfg              # GRUB boot menu
├── syslinux/syslinux.cfg      # BIOS boot menu
└── airootfs/
    ├── etc/
    │   ├── motd               # Terminal welcome message
    │   ├── mkinitcpio.conf    # Initramfs hooks (includes archiso + plymouth)
    │   ├── skel/              # Default user config files
    │   │   └── .config/
    │   │       ├── sway/      # Sway compositor config + desktop menu
    │   │       ├── waybar/    # Status bar config
    │   │       └── foot/      # Terminal config
    │   └── systemd/           # Service configs (autologin, etc.)
    ├── usr/
    │   ├── local/bin/         # blazzcore-browser, blazzcore-settings,
    │   │                      # blazzcore-wallpaper, tictactoe
    │   └── share/plymouth/    # Boot splash theme
    └── root/
        └── customize_airootfs.sh  # Chroot setup script (runs during build)

.github/workflows/
└── build-iso.yml              # GitHub Actions CI build pipeline

scripts/
└── build.sh                   # Local build helper
```

---

## License

MIT
