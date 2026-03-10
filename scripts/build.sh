#!/usr/bin/env bash
# ============================================
# BlazzCore ISO Build Script
# ============================================
# Prerequisites:
#   - Arch Linux host (or any system with archiso installed)
#   - sudo pacman -S archiso
#
# Usage:
#   sudo ./scripts/build.sh
# ============================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
PROFILE_DIR="$PROJECT_DIR/archiso"
WORK_DIR="/tmp/blazzcore-build"
OUT_DIR="$PROJECT_DIR/out"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m'

log() { echo -e "${CYAN}[BlazzCore]${NC} $1"; }
ok()  { echo -e "${GREEN}[✓]${NC} $1"; }
err() { echo -e "${RED}[✗]${NC} $1" >&2; }

# Check root
if [[ $EUID -ne 0 ]]; then
    err "This script must be run as root (sudo)."
    exit 1
fi

# Check archiso is installed
if ! command -v mkarchiso &>/dev/null; then
    err "archiso is not installed. Run: sudo pacman -S archiso"
    exit 1
fi

# Clean previous build
if [[ -d "$WORK_DIR" ]]; then
    log "Cleaning previous build artifacts..."
    rm -rf "$WORK_DIR"
fi

mkdir -p "$WORK_DIR" "$OUT_DIR"

log "Starting BlazzCore ISO build..."
log "Profile: $PROFILE_DIR"
log "Work dir: $WORK_DIR"
log "Output:   $OUT_DIR"

mkarchiso -v \
    -w "$WORK_DIR" \
    -o "$OUT_DIR" \
    "$PROFILE_DIR"

ok "Build complete!"
ok "ISO location: $OUT_DIR/"
ls -lh "$OUT_DIR"/*.iso 2>/dev/null || err "No ISO found in output directory."
