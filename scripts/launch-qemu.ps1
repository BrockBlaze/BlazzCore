# ============================================
# BlazzCore QEMU Launcher (Windows)
# ============================================
# Run this from the repo root after downloading the ISO from GitHub Actions.
# Usage:
#   .\launch-qemu.ps1
#   .\launch-qemu.ps1 -Iso "C:\path\to\blazzcore.iso"
#   .\launch-qemu.ps1 -Ram 8192 -Cpus 4

param(
    [string]$Iso    = "",
    [int]   $Ram    = 4096,
    [int]   $Cpus   = 4,
    [switch]$Uefi
)

$QEMU = "C:\Program Files\qemu\qemu-system-x86_64.exe"

if (-not (Test-Path $QEMU)) {
    Write-Error "QEMU not found at: $QEMU"
    exit 1
}

# Auto-find ISO if not specified
if (-not $Iso) {
    $found = Get-ChildItem -Path $PSScriptRoot -Filter "blazzcore-*.iso" -Recurse -ErrorAction SilentlyContinue |
             Sort-Object LastWriteTime -Descending |
             Select-Object -First 1
    if ($found) {
        $Iso = $found.FullName
        Write-Host "Found ISO: $Iso"
    } else {
        Write-Host ""
        Write-Host "No ISO found. Download it from GitHub Actions:" -ForegroundColor Yellow
        Write-Host "  1. Go to https://github.com/BrockBlaze/BlazzCore/actions" -ForegroundColor Cyan
        Write-Host "  2. Click the latest successful build" -ForegroundColor Cyan
        Write-Host "  3. Scroll to Artifacts and download blazzcore-iso" -ForegroundColor Cyan
        Write-Host "  4. Extract the zip and place the .iso next to this script" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "Then run: .\launch-qemu.ps1" -ForegroundColor Green
        exit 1
    }
}

if (-not (Test-Path $Iso)) {
    Write-Error "ISO not found: $Iso"
    exit 1
}

# Create a persistent disk image if it doesn't exist (optional, for saving data)
$DiskImg = Join-Path $PSScriptRoot "blazzcore-disk.qcow2"
if (-not (Test-Path $DiskImg)) {
    Write-Host "Creating 32 GB virtual disk (for optional install)..." -ForegroundColor Cyan
    & "C:\Program Files\qemu\qemu-img.exe" create -f qcow2 "$DiskImg" 32G
}

# Try WHPX acceleration (Windows Hypervisor Platform), fall back to software
$Accel = "whpx,kernel-irqchip=off"
$TestAccel = & $QEMU -accel help 2>&1
if ($TestAccel -notmatch "whpx") {
    $Accel = "tcg,tb-size=512"
    Write-Host "WHPX not available — using software emulation (slower). Enable Hyper-V in Windows Features for better speed." -ForegroundColor Yellow
} else {
    Write-Host "Using WHPX hardware acceleration." -ForegroundColor Green
}

Write-Host ""
Write-Host "Starting BlazzCore..." -ForegroundColor Green
Write-Host "  RAM:  ${Ram} MB"
Write-Host "  CPUs: $Cpus"
Write-Host "  ISO:  $Iso"
Write-Host ""
Write-Host "Tips inside QEMU:" -ForegroundColor Cyan
Write-Host "  Ctrl+Alt+G    — release mouse from QEMU window"
Write-Host "  Ctrl+Alt+F    — toggle fullscreen"
Write-Host ""

$args = @(
    "-name", "BlazzCore",
    "-machine", "q35,accel=$Accel",
    "-cpu", "max",
    "-m", "$Ram",
    "-smp", "$Cpus",
    "-vga", "virtio",
    "-display", "sdl,gl=off",
    "-audiodev", "dsound,id=snd0",
    "-device", "ich9-intel-hda",
    "-device", "hda-output,audiodev=snd0",
    "-device", "virtio-net-pci,netdev=net0",
    "-netdev", "user,id=net0",
    "-drive", "file=$DiskImg,format=qcow2,if=virtio",
    "-cdrom", "$Iso",
    "-boot", "order=d,menu=on"
)

if ($Uefi) {
    # UEFI boot — requires OVMF (download separately from https://www.tianocore.org/)
    $OvmfPath = Join-Path (Split-Path $QEMU) "share\edk2-x86_64-code.fd"
    if (Test-Path $OvmfPath) {
        $args += @("-drive", "if=pflash,format=raw,readonly=on,file=$OvmfPath")
        Write-Host "UEFI boot enabled." -ForegroundColor Green
    } else {
        Write-Host "OVMF UEFI firmware not found at $OvmfPath — booting BIOS." -ForegroundColor Yellow
    }
}

& $QEMU @args
