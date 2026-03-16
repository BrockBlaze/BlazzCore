# BlazzCore Feature Tracker

This document tracks every feature in the OS — what's implemented, what's confirmed working, and what still needs verification.

---

## Desktop Shell

| Feature | Status | Notes |
|---|---|---|
| Wallpaper (stars.jpg) | ✅ Implemented | `swaybg` via autostart. File at `/usr/share/backgrounds/blazzcore/stars.jpg` |
| Waybar status bar (bottom) | ✅ Implemented | Start button, taskbar, clock, CPU, RAM, network, volume, battery, notifications |
| Start menu (Super+Space / Super+D) | ⚠️ Needs verification | GtkLayerShell OVERLAY layer, 42px bottom margin. Errors logged to `/tmp/blazzcore-startmenu.log` — check this first if broken |
| Start menu toggle (click to close) | ✅ Implemented | `blazzcore-startmenu-toggle` kills running instance or launches new one |
| App list in start menu (searchable) | ✅ Implemented | All `.desktop` files, filtered by `should_show()` |
| Quick Access panel in start menu | ✅ Implemented | Files, Terminal, Settings, Browser, Downloads, Documents + user-pinned |
| Pin app to Quick Access (right-click) | ✅ Implemented | Saved to `~/.config/blazzcore/startmenu-pinned.json` |
| Pin app to taskbar dock (right-click) | ✅ Implemented | Writes to `~/.config/nwg-dock/pinned`, restarts nwg-dock |
| Taskbar (open windows) | ✅ Implemented | `wlr/taskbar` module in waybar |
| Taskbar right-click → window menu | ✅ Implemented | Restore/Minimize/Maximize/Close via `blazzcore-window-menu` |
| Taskbar middle-click → minimize | ✅ Implemented | `minimize-raise` action in waybar |
| Desktop scroll → switch workspace | ✅ Implemented | `GoToDesktop` via labwc rc.xml |
| Desktop right-click → context menu | ✅ Implemented | `ShowMenu root-menu` in rc.xml |
| Left-click on desktop (should do nothing) | ⚠️ Needs verification | Removed `pcmanfm --desktop` which was intercepting clicks |
| Notification bell (bottom-right tray) | ✅ Implemented | swaync, click to open center |
| System tray (network, bluetooth) | ✅ Implemented | nm-applet + blueman-applet (BT only if hardware present) |
| Clock (bottom-right) | ✅ Implemented | `{:%a %b %d · %H:%M}` format |
| MPRIS media controls in bar | ✅ Implemented | Shows playing track, click to play/pause |

---

## Window Management

| Feature | Status | Notes |
|---|---|---|
| Move windows (drag titlebar) | ✅ Implemented | `<default/>` labwc bindings |
| Resize windows (drag edges) | ✅ Implemented | `<default/>` labwc bindings |
| Close button (X) | ✅ Implemented | `<default/>` labwc bindings handle this natively |
| Maximize button (□) | ✅ Implemented | `<default/>` |
| Minimize button (−) | ✅ Implemented | `<default/>` |
| Super+F → maximize | ✅ Implemented | rc.xml keybind |
| Super+Shift+Q → close | ✅ Implemented | rc.xml keybind |
| Super+Left/Right → snap to half | ✅ Implemented | `SnapToEdge` action |
| Super+Up → maximize | ✅ Implemented | rc.xml keybind |
| Super+Down → minimize | ✅ Implemented | rc.xml keybind |
| Alt+Tab window switcher | ✅ Implemented | `NextWindow` / `PreviousWindow` |
| Server-side decorations (all windows) | ✅ Implemented | windowRule `*` → `serverDecoration: yes` |
| SSD disabled for Chromium/GTK4 apps | ✅ Implemented | windowRule list: chromium, nautilus, gedit, gnome-calculator |
| Always on top (Super+Shift+Space) | ✅ Implemented | `ToggleAlwaysOnTop` |

---

## Workspaces

| Feature | Status | Notes |
|---|---|---|
| 5 workspaces | ✅ Implemented | Named 1–5 in rc.xml |
| Super+1–5 → switch workspace | ✅ Implemented | `GoToDesktop` |
| Super+Shift+1–5 → move window | ✅ Implemented | `SendToDesktop` |
| Ctrl+Alt+Left/Right → cycle | ✅ Implemented | Wraps around |
| Super+Shift+Left/Right → move + follow | ✅ Implemented | `SendToDesktop` with `follow: yes` |

---

## Applications

| Feature | Status | Notes |
|---|---|---|
| Terminal (Super+Return) | ✅ Implemented | `foot` |
| Browser (Super+B) | ✅ Implemented | Chromium with VA-API hardware decode |
| File manager (Super+E) | ✅ Implemented | Thunar |
| Settings (Super+,) | ✅ Implemented | `blazzcore-settings` GTK3 app |
| App launcher (wofi) | ✅ Implemented | `.config/wofi/` config |
| Task manager (Ctrl+Shift+Esc) | ✅ Implemented | `blazzcore-taskmanager` |

---

## Settings App (Super+,)

| Feature | Status | Notes |
|---|---|---|
| Single-click sidebar tabs | ✅ Implemented | `set_activate_on_single_click(True)` on realize |
| Display & Monitors | ⚠️ VM only — "No displays detected" | `wlr-randr` finds no outputs in QEMU virtio-vga. Works on real hardware |
| Appearance (wallpaper, accent color) | ✅ Implemented | |
| Taskbar (restart waybar) | ✅ Implemented | |
| Sound (pavucontrol) | ✅ Implemented | |
| Network (nmtui) | ✅ Implemented | |
| Bluetooth (blueman) | ✅ Implemented | |
| Night Light | ✅ Implemented | Toggle + temperature sliders |
| Keyboard layout | ✅ Implemented | Via localectl |
| Power Management | ✅ Implemented | Idle lock/DPMS timers |
| Date & Time | ✅ Implemented | Via timedatectl |
| System Updates | ✅ Implemented | `sudo pacman -Syu` in terminal |
| Drivers | ✅ Implemented | `blazzcore-drivers` |
| About | ✅ Implemented | Version, kernel, package count, uptime |

---

## Media Keys & OSD

| Feature | Status | Notes |
|---|---|---|
| Volume up/down/mute (media keys) | ✅ Implemented | `wpctl` + `wob` OSD bar |
| Brightness up/down (media keys) | ✅ Implemented | `brightnessctl` + `wob` OSD |
| OSD bar (wob) | ✅ Implemented | Navy/blue themed, 28px height |

---

## Screenshots & Recording

| Feature | Status | Notes |
|---|---|---|
| Print → full screenshot | ✅ Implemented | `grim` → `~/Pictures/` + clipboard copy |
| Shift+Print → area select | ✅ Implemented | `slurp` + `grim` |
| Ctrl+Print → clipboard only | ✅ Implemented | No file saved |
| Super+Shift+R → screen record | ✅ Implemented | Toggle `wf-recorder` MP4 |

---

## System

| Feature | Status | Notes |
|---|---|---|
| Lock screen (Super+L) | ✅ Implemented | `swaylock` with wallpaper background + accent color ring |
| Power menu (Super+Shift+P) | ✅ Implemented | Shutdown, Restart, Suspend, Lock, Log Out |
| Night light (Super+N) | ✅ Implemented | `wlsunset` 3500K/6500K |
| Clipboard history (Super+V) | ✅ Implemented | `cliphist` + `wofi` dmenu |
| Idle lock (5 min) + DPMS off (10 min) | ✅ Implemented | `swayidle` |
| Audio (PipeWire + WirePlumber) | ✅ Implemented | |
| Bluetooth | ✅ Implemented | |
| WiFi | ✅ Implemented | NetworkManager |

---

## Appearance

| Feature | Status | Notes |
|---|---|---|
| Dark navy theme | ✅ Implemented | `#0c0c1a` background throughout |
| Papirus-Dark icon theme | ✅ Implemented | |
| Noto Sans + Hack Nerd Font | ✅ Implemented | |
| Window fade animations | ✅ Implemented | 120ms ease-out open/close |
| Chromium navy theme | ✅ Implemented | `--load-extension` with manifest theme |
| Accent color (customizable) | ✅ Implemented | `blazzcore-accent` updates themerc live |
| Corner radius 0 (sharp corners) | ✅ Implemented | rc.xml + CSS |
| Start menu button icon | ✅ Implemented | Nerd Font 󰈸 fire icon, orange |

---

## App Visibility

| Feature | Status | Notes |
|---|---|---|
| Hide technical/clutter apps | ✅ Implemented | `NoDisplay=true` injected via `customize_airootfs.sh` |
| Hidden: vim, btop, htop, python, xterm, mpv, etc. | ✅ Implemented | Full list in `customize_airootfs.sh` |

---

## First Boot & Install

| Feature | Status | Notes |
|---|---|---|
| First boot wizard (timezone, locale, keyboard, hostname, password) | ✅ Implemented | `blazzcore-firstboot` + systemd service |
| Graphical disk installer | ✅ Implemented | `blazzcore-install` zenity-based |
| Plymouth boot splash | ✅ Implemented | Custom `blazzcore` theme |

---

## Known Runtime Issues (Not Code Bugs)

| Issue | Root Cause | Fix Status |
|---|---|---|
| "No displays detected" in Settings → Display | QEMU `virtio-vga` is not a KMS output; `wlr-randr` can't enumerate it | Not a bug — works on real hardware |
| Start menu not appearing | Under investigation — check `/tmp/blazzcore-startmenu.log` after clicking | ⚠️ Pending verification |

---

## Legend

- ✅ **Implemented** — code is in place and expected to work
- ⚠️ **Needs verification** — implemented but has had runtime issues; needs confirmation
- ❌ **Broken / Missing** — not working or not yet built
