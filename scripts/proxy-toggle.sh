#!/usr/bin/env bash
set -euo pipefail

ACTION="${1:-}"

case "$ACTION" in
    set)
        HOST="${2:-192.168.240.1}"
        PORT="${3:-8080}"
        echo "[*] Setting Android global proxy to ${HOST}:${PORT}..."
        adb shell settings put global http_proxy "${HOST}:${PORT}"
        echo "[+] Proxy active: $(adb shell settings get global http_proxy)"
        ;;
    clear)
        echo "[*] Clearing Android global proxy..."
        adb shell settings put global http_proxy :0
        echo "[+] Proxy cleared."
        ;;
    status)
        echo "[*] Current Android global proxy: $(adb shell settings get global http_proxy 2>/dev/null || echo 'not set')"
        ;;
    *)
        echo "Usage: $0 {set [host] [port] | clear | status}"
        exit 1
        ;;
esac
