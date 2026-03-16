# BlazzCore

A minimal, fast, Wayland-first Linux operating system built on Arch Linux by Brock Blazzard

![BlazzCore](BlazzCore.png)

---

## Overview

BlazzCore is a custom Linux distro focused on simplicity, performance, and a consistent native look and feel. It ships a complete desktop experience out of the box — floating windows, a start menu, taskbar, system tray, clipboard history, and Chromium with hardware video decoding — while staying lean enough to run comfortably on modest hardware.

| Component      | Package                            |
| -------------- | ---------------------------------- |
| Base           | Arch Linux (rolling release)       |
| Window Manager | labwc (Wayland, floating)          |
| Status Bar     | Waybar                             |
| Terminal       | foot                               |
| Browser        | Chromium (VA-API GPU acceleration) |
| Audio          | PipeWire + WirePlumber             |
| File Manager   | Thunar                             |
| Notifications  | swaync                             |
| App Launcher   | wofi                               |
| Packages       | pacman                             |

---

## Features

- **Start menu** — fire button in taskbar or `Super+Space` / `Super+D` opens a searchable app launcher with Quick Access panel
- **Native settings** — `Super+,` opens a fully BlazzCore-styled settings panel (Sound, Network, Bluetooth, Appearance, Updates, and more — no third-party popups)
- **Inline system updates** — Settings → Updates lists available packages and installs them with a live progress view
- **Taskbar** — open windows with minimize/maximize/close via right-click, minimize via middle-click
- **Right-click desktop menu** — quick access to apps, screenshots, and power options
- **Clipboard history** — `Super+V` opens searchable clipboard history (cliphist)
- **Boot splash** — custom Plymouth theme with BlazzCore logo and animated progress bar
- **GPU acceleration** — Mesa VA-API drivers; Chromium uses hardware video decode
- **Square corners** — consistent sharp-corner UI throughout (windows, menus, settings, notifications)
- **Dark navy theme** — `#0c0c1a` background throughout; Papirus-Dark icons
- **Night light** — `Super+N` toggles warm color temperature via wlsunset
- **Screen recording** — `Super+Shift+R` toggles wf-recorder MP4 recording
- **Broad hardware support** — linux-firmware, sof-firmware, alsa-firmware, wireless-regdb
- **5 workspaces** — `Super+1-5` to switch, scroll on desktop to cycle

---

## Building the ISO

CI builds automatically on every push to `main` using a self-hosted runner on the Friday test server. The ISO artifact is also uploaded to GitHub Actions.

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

| Shortcut                      | Action                   |
| ----------------------------- | ------------------------ |
| `Super + Enter`               | Open terminal (foot)     |
| `Super + Space` / `Super + D` | Start menu               |
| `Super + B`                   | Open browser (Chromium)  |
| `Super + E`                   | File manager (Thunar)    |
| `Super + ,`                   | Settings                 |
| `Super + V`                   | Clipboard history        |
| `Super + L`                   | Lock screen              |
| `Super + Shift + P`           | Power menu               |
| `Super + N`                   | Toggle night light       |
| `Print`                       | Full screenshot          |
| `Shift + Print`               | Area screenshot          |
| `Super + Shift + R`           | Toggle screen recording  |
| `Super + Shift + Q`           | Close window             |
| `Super + F`                   | Maximize/restore         |
| `Super + Left / Right`        | Snap to half screen      |
| `Super + 1–5`                 | Switch workspace         |
| `Super + Shift + 1–5`         | Move window to workspace |
| `Alt + Tab`                   | Window switcher          |
| `Ctrl + Shift + Esc`          | Task manager             |

---

## Project Structure

```
archiso/
├── profiledef.sh              # ISO profile, file permissions for all executables
├── packages.x86_64            # Full package list
├── grub/grub.cfg              # GRUB boot menu + kernel parameters
└── airootfs/
    ├── etc/
    │   ├── mkinitcpio.conf    # Initramfs hooks (archiso + plymouth)
    │   ├── skel/              # Default user config (copied to home on first boot)
    │   │   └── .config/
    │   │       ├── labwc/     # Window manager (rc.xml, autostart, menu.xml)
    │   │       ├── waybar/    # Status bar (config, style.css)
    │   │       ├── foot/      # Terminal
    │   │       ├── wofi/      # App launcher
    │   │       └── swaync/    # Notification center
    │   └── systemd/           # Service configs (autologin, etc.)
    ├── usr/
    │   ├── local/bin/         # blazzcore-* utility scripts
    │   └── share/
    │       ├── backgrounds/   # Wallpapers
    │       ├── plymouth/      # Boot splash theme
    │       └── blazzcore/     # Post-install script
    └── root/
        └── customize_airootfs.sh  # Chroot setup (runs at build time)

.github/workflows/
└── build-iso.yml              # CI: self-hosted runner on Friday, auto-deploys to QEMU

scripts/
├── build-and-run.sh           # Manual: build on Friday server + restart QEMU
└── build.sh                   # Local build helper
```

---

## License

MIT
