# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Project Is

BlazzCore is a minimal, Wayland-first Linux desktop OS built on Arch Linux. The build system produces a bootable `.iso` using **archiso**. There are no traditional unit tests or linters — the "test" is booting the ISO.

## Building the ISO

**Requires Arch Linux.** Builds cannot run on Windows/macOS natively.

```bash
# Install archiso (Arch Linux only)
sudo pacman -S archiso

# Build locally
sudo mkarchiso -v -w /tmp/blazzcore-build -o /tmp/blazzcore-out archiso/

# Or use the helper script
sudo ./scripts/build.sh
```

The CI/CD pipeline (`.github/workflows/build-iso.yml`) builds on every push to `main` inside an `archlinux:latest` container. The ISO artifact is retained for 14 days.

**Testing on Windows:** `launch-qemu.ps1` launches the ISO in QEMU.

## Architecture

### How the ISO Gets Built

1. `archiso/profiledef.sh` — ISO metadata, compression settings (zstd level 15), and **file permission declarations** for every executable. When adding new scripts to `usr/local/bin/`, permissions must be added here.
2. `archiso/packages.x86_64` — Full package list. Add/remove packages here to change what's included in the ISO.
3. `archiso/airootfs/root/customize_airootfs.sh` — Runs inside the build chroot. Handles service enablement, Plymouth theme, locale pre-seeding, and wallpaper generation.
4. `archiso/airootfs/` — The live filesystem root. Everything here lands on the booted system.

### User Configuration (`etc/skel/`)

`archiso/airootfs/etc/skel/` contains default config files copied to new user home directories. This is the primary place to modify default desktop behavior:

- `.config/labwc/rc.xml` — Window manager settings: keybindings, themes, workspaces, window rules
- `.config/labwc/autostart` — Session startup commands (dock, waybar, notifications, etc.)
- `.config/waybar/config` + `style.css` — Status bar layout and appearance
- `.config/foot/foot.ini` — Terminal emulator settings
- `.config/mako/config` — Notification daemon settings
- `.config/wofi/` — App launcher config
- `.config/swaync/` — Notification center config
- `.config/nwg-dock/` — Dock config
- `.config/starship.toml` — Shell prompt config
- `.bashrc` — Default shell config

### BlazzCore Utility Scripts (`usr/local/bin/`)

All scripts are prefixed `blazzcore-`. The main ones:

| Script | Language | Purpose |
|--------|----------|---------|
| `blazzcore-install` | Bash + zenity | Full-disk installer GUI |
| `blazzcore-firstboot` | Bash + zenity | First-boot setup wizard (timezone, locale, user) |
| `blazzcore-settings` | Python3 + GTK3 | System settings panel |
| `blazzcore-startmenu` | Python3 | Application launcher/start menu |
| `blazzcore-gen-wallpapers` | Python3 | Generates gradient wallpapers at build time |
| `blazzcore-accent` | Bash | Theme accent color changer |
| `blazzcore-drivers` | Bash | GPU driver installer helper |
| `blazzcore-store` | Bash | App store interface |
| `blazzcore-taskmanager` | Bash | Task manager launcher |

### Post-Install (`usr/share/blazzcore/postinstall.sh`)

Runs after `archinstall` completes when installing to disk. Copies scripts, configs, themes, and Plymouth setup into the installed system chroot.

### Desktop Technology Stack

| Component | Package |
|-----------|---------|
| Window Manager | labwc (Wayland, OpenBox-like XML config) |
| Status Bar | waybar |
| Terminal | foot |
| App Launcher | wofi |
| Dock | nwg-dock |
| File Manager | Thunar (browser) + PCManFM (desktop icons) |
| Notifications | swaync |
| Audio | PipeWire + WirePlumber |
| Browser | Chromium (VA-API hardware decode enabled) |
| Boot Splash | Plymouth (custom blazzcore theme) |

## Key Development Notes

- **Adding a new utility script:** Create the script in `archiso/airootfs/usr/local/bin/`, add a `.desktop` file in `usr/share/applications/`, and register the file permissions in `archiso/profiledef.sh` under `file_permissions`.
- **labwc config is XML** (`rc.xml`) — not a scripting language. Keybindings, window rules, and desktop count are all defined there.
- **waybar config is JSON** — `config` defines modules, `style.css` controls appearance.
- **The `customize_airootfs.sh` script runs at build time in chroot**, not at runtime. Runtime startup is handled by `labwc/autostart`.
- **Plymouth theme** is at `usr/share/plymouth/themes/blazzcore/`. Changes require rebuilding initramfs (`mkinitcpio -P`) to take effect.
