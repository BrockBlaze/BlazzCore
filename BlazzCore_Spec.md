# BlazzCore 🚀

> "The high-performance core for the modern web."

**BlazzCore** is a minimalist Linux distribution designed to provide a rock-solid, stripped-back foundation that stays out of the way, allowing powerful applications like Chromium to utilize 100% of your system's potential.

## ### Key Features

- **Stripped-Back Base:** Minimal init system and kernel configuration designed to boot in seconds and use less than **500MB of RAM** at idle.
- **GPU Acceleration Out-of-the-Box:** Pre-configured VA-API and VDPAU drivers to ensure Chromium handles 4K video playback and hardware-accelerated rendering without spiking the CPU.
- **Sandbox-Ready:** Full support for Wayland by default to provide better security and smoother window scaling for modern browsers.
- **Media-First Stack:** Integrated PipeWire for low-latency audio and seamless screen sharing/mic support in browser-based meetings.
- **Zero Bloat:** No pre-installed office suites, email clients, or background telemetry—just the "Core" and the "Blaze."

## ### Technical Specifications

| Component           | Choice                  | Reason                                                                       |
| :------------------ | :---------------------- | :--------------------------------------------------------------------------- |
| **Window Manager**  | Sway or River (Wayland) | Ultra-lightweight, efficient, and great for multi-monitor browser setups.    |
| **Package Manager** | Pacman or xbps          | Fast, rolling-release updates to ensure the latest browser security patches. |
| **Audio**           | PipeWire                | Full compatibility with modern web-based communication tools.                |
| **Font Rendering**  | Freetype/HarfBuzz       | Optimized for crisp text rendering, essential for long reading sessions.     |

## ### "The BlazzCore Experience"

When you launch BlazzCore, you aren't greeted by a heavy desktop environment. You get a clean, high-speed gateway to the web. It’s the perfect distro for a "Web-First" workstation or a high-end kiosk.
