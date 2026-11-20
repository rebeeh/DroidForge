#!/usr/bin/env bash
# ==============================================================================
# DroidForge QUIC / UDP 443 Toggle
# Drops outbound UDP 443 on the Waydroid bridge to force applications
# to fall back to standard TCP/TLS for proxy inspection.
# ==============================================================================
set -euo pipefail

ACTION="${1:-}"
INTERFACE="${2:-waydroid0}"

case "$ACTION" in
    enable)
        echo "[*] Blocking UDP port 443 on interface '$INTERFACE'..."
        sudo iptables -I FORWARD -i "$INTERFACE" -p udp --dport 443 -j DROP
        echo "[+] Rule added. Outbound QUIC is now blocked (forcing TCP fallback)."
        ;;
    disable)
        echo "[*] Removing UDP port 443 block on interface '$INTERFACE'..."
        while sudo iptables -D FORWARD -i "$INTERFACE" -p udp --dport 443 -j DROP 2>/dev/null; do :; done
        echo "[+] Rule removed. QUIC / UDP traffic restored."
        ;;
    status)
        echo "[*] Checking iptables FORWARD rules for '$INTERFACE':"
        sudo iptables -L FORWARD -v -n | grep -E "$INTERFACE.*dpt:443" || echo "No QUIC block active."
        ;;
    *)
        echo "Usage: $0 {enable|disable|status} [interface]"
        echo ""
        echo "Examples:"
        echo "  $0 enable              # Force apps to fall back from QUIC to TCP"
        echo "  $0 disable             # Restore normal UDP 443 traffic"
        echo "  $0 status              # Check if block rule is active"
        exit 1
        ;;
esac
