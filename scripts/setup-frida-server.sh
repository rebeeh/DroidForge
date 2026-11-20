#!/usr/bin/env bash
# ==============================================================================
# DroidForge frida-server Deployment Helper
# Detects target container ABI, checks/downloads frida-server, pushes to
# /data/local/tmp/frida-server, and launches the daemon in Waydroid.
# ==============================================================================
set -euo pipefail

echo "======================================================================"
echo "                   DroidForge frida-server Deployer                   "
echo "======================================================================"

# 1. Verify ADB connection
if ! command -v adb >/dev/null 2>&1; then
    echo "[-] Error: adb command not found. Install android-tools." >&2
    exit 1
fi

DEVICE_STATE=$(adb get-state 2>/dev/null || echo "offline")
if [ "$DEVICE_STATE" != "device" ]; then
    echo "[-] Error: No ADB device connected."
    echo "[*] Ensure Waydroid is running, then run: adb connect 192.168.240.112:5555"
    exit 1
fi

# 2. Detect container ABI
RAW_ABI=$(adb shell getprop ro.product.cpu.abi | tr -d '\r\n')
echo "[*] Detected Android primary ABI: $RAW_ABI"

case "$RAW_ABI" in
    arm64*|aarch64*)
        FRIDA_ARCH="arm64"
        ;;
    armeabi*|arm*)
        FRIDA_ARCH="arm"
        ;;
    x86_64*)
        FRIDA_ARCH="x86_64"
        ;;
    x86*)
        FRIDA_ARCH="x86"
        ;;
    *)
        echo "[-] Unknown ABI: $RAW_ABI. Defaulting to arm64."
        FRIDA_ARCH="arm64"
        ;;
esac

REMOTE_BIN="/data/local/tmp/frida-server"

# 3. Check if already installed
if adb shell "[ -f $REMOTE_BIN ]" 2>/dev/null; then
    echo "[+] Found existing frida-server at $REMOTE_BIN inside container."
else
    echo "[*] frida-server not found at $REMOTE_BIN."
    echo "[*] Fetching latest frida-server release for android-${FRIDA_ARCH}..."

    TAG=$(curl -s https://api.github.com/repos/frida/frida/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
    if [ -z "$TAG" ]; then
        TAG="16.5.9"
    fi

    FILE_NAME="frida-server-${TAG}-android-${FRIDA_ARCH}.xz"
    DOWNLOAD_URL="https://github.com/frida/frida/releases/download/${TAG}/${FILE_NAME}"

    TMP_DIR=$(mktemp -d)
    trap 'rm -rf "$TMP_DIR"' EXIT

    echo "[*] Downloading: $DOWNLOAD_URL"
    curl -L "$DOWNLOAD_URL" -o "$TMP_DIR/$FILE_NAME"

    echo "[*] Extracting..."
    unxz "$TMP_DIR/$FILE_NAME"
    EXTRACTED_BIN="$TMP_DIR/frida-server-${TAG}-android-${FRIDA_ARCH}"

    echo "[*] Pushing to container: $REMOTE_BIN"
    adb push "$EXTRACTED_BIN" "$REMOTE_BIN"
    adb shell chmod 755 "$REMOTE_BIN"
fi

# 4. Launch frida-server in background
echo "[*] Checking if frida-server process is already running..."
if adb shell pgrep -f "frida-server" >/dev/null 2>&1; then
    echo "[+] frida-server is already running inside container."
else
    echo "[*] Launching frida-server daemon in background..."
    adb shell "nohup $REMOTE_BIN >/dev/null 2>&1 &"
    sleep 2
    if adb shell pgrep -f "frida-server" >/dev/null 2>&1; then
        echo "[+] frida-server started successfully!"
    else
        echo "[!] Process started. Verify with: frida-ps -U"
    fi
fi

echo "======================================================================"
echo "[*] Test connection from your host with:"
echo "    frida-ps -U"
echo "======================================================================"
