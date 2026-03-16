# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Project Is

BlazzCore is a minimal, Wayland-first Linux desktop OS built on Arch Linux. The build system produces a bootable `.iso` using **archiso**. There are no traditional unit tests or linters — the "test" is booting the ISO in QEMU on the Friday test server.

---

## Building & Deploying

**Requires Arch Linux or Docker.** Builds cannot run natively on Windows/macOS.

```bash
# Build locally (Arch Linux only)
sudo pacman -S archiso
sudo mkarchiso -v -w /tmp/blazzcore-build -o /tmp/blazzcore-out archiso/
```

### CI/CD — Self-hosted runner on Friday

Every push to `main` automatically:
1. Triggers the self-hosted GitHub Actions runner on the **Friday test server** (`192.168.70.2`, user `addy`)
2. Builds the ISO inside a Docker `archlinux:latest` container (~10–15 min, pacman pkg cache speeds up repeat builds)
3. Copies the new ISO to `~/blazzcore-out/` on Friday
4. Restarts the `blazzcore-qemu` systemd service (persistent, survives session exit, auto-restarts on crash)
5. Restarts the `blazzcore-novnc` systemd service (websockify noVNC proxy on port 6080)

**Connect to the running VM:** `http://192.168.70.2:6080/vnc.html`

### SSH access to Friday

Password is stored at `C:\Users\BrockBlazzard\AppData\Local\Temp\zabbixpw`. Use `SSH_ASKPASS` to connect non-interactively (required since shell state doesn't persist between sessions):

```bash
# One-time setup per shell session — recreate the askpass script
cat > /tmp/askpass_zabbix.sh << 'SCRIPT'
#!/bin/bash
cat /c/Users/BrockBlazzard/AppData/Local/Temp/zabbixpw
SCRIPT
chmod +x /tmp/askpass_zabbix.sh

# Then connect like this:
export SSH_ASKPASS=/tmp/askpass_zabbix.sh SSH_ASKPASS_REQUIRE=force DISPLAY=:0
ssh -o StrictHostKeyChecking=no addy@192.168.70.2 "command"
```

Runner service:
```bash
ssh -o StrictHostKeyChecking=no addy@192.168.70.2 "sudo systemctl status actions.runner.BrockBlaze-BlazzCore.friday"
ssh -o StrictHostKeyChecking=no addy@192.168.70.2 "sudo systemctl restart actions.runner.BrockBlaze-BlazzCore.friday"
```

### Manual deploy (skip CI, build on Friday directly)

```bash
ssh -o StrictHostKeyChecking=no addy@192.168.70.2 "~/build-and-run.sh"
# pull latest code → build in Docker → restart QEMU (~10-15 min)
```

### Restart QEMU only (no rebuild needed)

```bash
ssh -o StrictHostKeyChecking=no addy@192.168.70.2 "sudo systemctl restart blazzcore-qemu"
ssh -o StrictHostKeyChecking=no addy@192.168.70.2 "sudo systemctl restart blazzcore-novnc"
```

### Debugging the running VM

```bash
ssh -o StrictHostKeyChecking=no addy@192.168.70.2 'cat /tmp/blazzcore-startmenu.log'        # start menu errors
ssh -o StrictHostKeyChecking=no addy@192.168.70.2 'cat /tmp/blazzcore-serial.log'           # kernel/boot log
ssh -o StrictHostKeyChecking=no addy@192.168.70.2 'sudo journalctl -u blazzcore-qemu -n 50' # QEMU service log
```

---

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
- `.config/wofi/` — App launcher config
- `.config/swaync/` — Notification center config (replaces mako)
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

Runs after `blazzcore-install` completes when installing to disk. Copies scripts, configs, themes, and Plymouth setup into the installed system chroot.

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

- **Adding a new utility script:** Create the script in `archiso/airootfs/usr/local/bin/`, add a `.desktop` file in `usr/share/applications/`, and register the file permissions in `archiso/profiledef.sh` under `file_permissions`: `["/usr/local/bin/blazzcore-myname"]="0:0:755"`.
- **labwc config is XML** (`rc.xml`) — not a scripting language. Keybindings, window rules, and desktop count are all defined there.
- **labwc mouse bindings — do NOT use `<default/>` in `<mouse>`:** Some labwc versions inject a Left+Click → ShowMenu binding for the Desktop context via their defaults. We define all mouse bindings explicitly so left-clicking the desktop does nothing. If you add `<default/>` back, left-click on the desktop will open the right-click context menu.
- **Always use full paths in keybinds and waybar `on-click`:** e.g. `/usr/local/bin/blazzcore-startmenu-toggle` not just `blazzcore-startmenu-toggle`. The Wayland session launched by labwc may not have `/usr/local/bin` in PATH. Bare names fail silently.
- **Start menu toggle uses a PID file** at `/tmp/blazzcore-startmenu.pid`. Every toggle action is logged to `/tmp/blazzcore-startmenu.log`. Check that file first if the start menu isn't responding.
- **waybar config is JSON** — `config` defines modules, `style.css` controls appearance.
- **The `customize_airootfs.sh` script runs at build time in chroot**, not at runtime. Runtime startup is handled by `labwc/autostart`.
- **Plymouth theme** is at `usr/share/plymouth/themes/blazzcore/`. On an installed system, changes require rebuilding initramfs (`mkinitcpio -P`). In QEMU virtio-vga, Plymouth may not get a full KMS framebuffer — the `video=1920x1080` kernel param in `grub.cfg` helps.
- **QEMU and noVNC run as systemd services** on the Friday server (`blazzcore-qemu` and `blazzcore-novnc`), so they persist across SSH sessions and runner job exits. Use `systemctl restart blazzcore-qemu` / `systemctl restart blazzcore-novnc` to restart them.
