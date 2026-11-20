#!/usr/bin/env bash
# ==============================================================================
# DroidForge Network Packet Capture Utility
# Captures raw traffic on the Waydroid network bridge for analysis in Wireshark.
# ==============================================================================
set -euo pipefail

INTERFACE="${1:-waydroid0}"
OUTPUT_FILE="${2:-waydroid_capture_$(date +%Y%m%d_%H%M%S).pcap}"

# Verify interface exists
if ! ip link show "$INTERFACE" >/dev/null 2>&1; then
    echo "[-] Error: Interface '$INTERFACE' not found."
    echo "[*] Available interfaces:"
    ip -br addr
    exit 1
fi

echo "======================================================================"
echo "                   DroidForge Packet Capture Tool                     "
echo "======================================================================"
echo "[*] Interface:  $INTERFACE"
echo "[*] Output file: $OUTPUT_FILE"
echo "[*] Press Ctrl+C at any time to stop the capture."
echo "======================================================================"

# Run tcpdump
sudo tcpdump -i "$INTERFACE" -nn -w "$OUTPUT_FILE"

echo ""
echo "[+] Capture saved to: $OUTPUT_FILE"
echo "[*] Recommended Wireshark display filters:"
echo "    - DNS Queries:     dns"
echo "    - QUIC / HTTP/3:   udp.port == 443"
echo "    - TLS Handshakes:  tls.handshake.type == 1"
echo "    - HTTP Traffic:    http"
