#!/usr/bin/env bash
# Auto-start labwc on TTY1 login
if [ -z "$WAYLAND_DISPLAY" ] && [ -z "$DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ]; then
    exec dbus-run-session labwc
fi
