#!/usr/bin/env bash
# BlazzCore right-click desktop menu

choice=$(printf \
    "  Files\n  Browser\n  Terminal\n󰒓  Settings\n  Display\n  Wallpaper\n  Reload Desktop\n  Exit" \
    | wofi --dmenu --prompt "" --width 220 --height 320 --style ~/.config/wofi/menu.css 2>/dev/null \
    | sed 's/^[[:space:]]*//' | awk '{print $2}')

case "$choice" in
    Files)     thunar ;;
    Browser)   blazzcore-browser ;;
    Terminal)  foot ;;
    Settings)  blazzcore-settings ;;
    Display)   wdisplays ;;
    Wallpaper) blazzcore-wallpaper ;;
    "Reload Desktop") swaymsg reload ;;
    Exit)      swaymsg exit ;;
esac
