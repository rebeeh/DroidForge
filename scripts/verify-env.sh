#!/usr/bin/env bash
set -euo pipefail

echo "=========================================================="
echo "          DroidForge Environment Diagnostic Verifier       "
echo "=========================================================="

echo -n "[*] Host OS: "
[ -f /etc/os-release ] && . /etc/os-release && echo "${PRETTY_NAME}" || echo "Unknown Linux Distribution"

echo -n "[*] Display Session: "
echo "${XDG_SESSION_TYPE:-unknown} (${WAYLAND_DISPLAY:-${DISPLAY:-none}})"

echo -n "[*] Graphics Render Node (/dev/dri/renderD128): "
[ -e "/dev/dri/renderD128" ] && echo "FOUND" || echo "MISSING"

echo -n "[*] Waydroid service: "
systemctl is-active --quiet waydroid-container 2>/dev/null && echo "ACTIVE" || echo "INACTIVE"

echo -n "[*] Waydroid session: "
command -v waydroid >/dev/null 2>&1 && (waydroid status 2>/dev/null | grep -i "Session:" || echo "Stopped") || echo "Not installed"

echo -n "[*] ADB connection: "
if command -v adb >/dev/null 2>&1; then
    DEVS=$(adb devices | grep -v "List of devices" | grep "device$" || true)
    [ -n "$DEVS" ] && echo "CONNECTED" || echo "DISCONNECTED"
else
    echo "adb not installed"
fi
echo "=========================================================="
