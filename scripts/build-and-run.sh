#!/bin/bash
# BlazzCore — local build + run
# Builds the ISO directly on this server using Docker (no GitHub download needed).
# Usage: ~/build-and-run.sh

set -e
REPO_URL="https://github.com/BrockBlaze/BlazzCore.git"
REPO_DIR=~/blazzcore-src
OUT_DIR=~/blazzcore-out
BUILD_LOG=/tmp/blazzcore-build.log

echo "=== BlazzCore local build $(date) ==="

# Clone or pull latest code
if [[ -d "$REPO_DIR/.git" ]]; then
    echo "[1/4] Pulling latest code..."
    git -C "$REPO_DIR" pull --ff-only
else
    echo "[1/4] Cloning repo..."
    git clone "$REPO_URL" "$REPO_DIR"
fi

mkdir -p "$OUT_DIR"
mkdir -p /tmp/blazzcore-pkg-cache

# Build ISO in privileged archlinux container
# Mounts pkg cache so subsequent builds don't re-download all packages
echo "[2/4] Building ISO in Docker (~10-15 min)..."
docker run --rm --privileged \
    -v "$REPO_DIR:/build:ro" \
    -v "$OUT_DIR:/out" \
    -v /tmp/blazzcore-pkg-cache:/var/cache/pacman/pkg \
    archlinux:latest \
    bash -c '
        set -e
        echo "Installing archiso..."
        pacman -Sy --noconfirm archiso squashfs-tools 2>&1 | grep -E "^(installing|error|warning)" || true
        echo "Building ISO..."
        mkarchiso -v -w /tmp/blazzcore-work -o /out /build/archiso/ 2>&1
        rm -rf /tmp/blazzcore-work
    ' 2>&1 | tee "$BUILD_LOG"

ISO=$(ls -t "$OUT_DIR"/blazzcore-*.iso 2>/dev/null | head -1)
if [[ -z "$ISO" ]]; then
    echo "ERROR: No ISO found in $OUT_DIR after build"
    exit 1
fi

echo "[3/4] Built: $(basename "$ISO")"

# Kill old QEMU and restart with new ISO
echo "[4/4] Restarting QEMU with new ISO..."
pkill -f qemu-system 2>/dev/null || true
sleep 2
nohup bash ~/run-blazzcore.sh > /tmp/qemu.log 2>&1 &
sleep 4
if pgrep -x qemu-system-x86_64 > /dev/null; then
    echo "QEMU started. VNC: localhost:5900"
    echo "  Tunnel: ssh -L 5900:localhost:5900 addy@192.168.70.2"
else
    echo "ERROR: QEMU failed to start. Check /tmp/qemu.log"
    tail -20 /tmp/qemu.log
    exit 1
fi

echo "=== Done! ==="
