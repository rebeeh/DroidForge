#!/usr/bin/env bash
# ==============================================================================
# DroidForge Transparent Proxy Redirection Tool
# Redirects all outbound TCP ports 80 & 443 from Waydroid to a local mitmproxy
# instance, capturing traffic from apps that ignore the system HTTP proxy.
# ==============================================================================
set -euo pipefail

ACTION="${1:-}"
PROXY_PORT="${2:-8080}"
INTERFACE="${3:-waydroid0}"

case "$ACTION" in
    enable)
        echo "[*] Enabling IPv4 forwarding on host..."
        sudo sysctl -w net.ipv4.ip_forward=1 >/dev/null

        echo "[*] Adding PREROUTING redirect rules on interface '$INTERFACE' to port $PROXY_PORT..."
        sudo iptables -t nat -A PREROUTING -i "$INTERFACE" -p tcp --dport 80 -j REDIRECT --to-port "$PROXY_PORT"
        sudo iptables -t nat -A PREROUTING -i "$INTERFACE" -p tcp --dport 443 -j REDIRECT --to-port "$PROXY_PORT"

        echo "[+] Transparent redirection active."
        echo "[*] Run mitmproxy in transparent mode:"
        echo "    mitmweb --mode transparent --listen-port $PROXY_PORT --listen-host 0.0.0.0"
        ;;
    disable)
        echo "[*] Removing PREROUTING redirect rules for '$INTERFACE'..."
        while sudo iptables -t nat -D PREROUTING -i "$INTERFACE" -p tcp --dport 80 -j REDIRECT --to-port "$PROXY_PORT" 2>/dev/null; do :; done
        while sudo iptables -t nat -D PREROUTING -i "$INTERFACE" -p tcp --dport 443 -j REDIRECT --to-port "$PROXY_PORT" 2>/dev/null; do :; done
        echo "[+] Transparent redirection disabled."
        ;;
    status)
        echo "[*] Active PREROUTING rules in nat table for '$INTERFACE':"
        sudo iptables -t nat -L PREROUTING -v -n | grep -E "$INTERFACE.*dpt:(80|443)" || echo "No transparent redirect active."
        ;;
    *)
        echo "Usage: $0 {enable|disable|status} [proxy_port] [interface]"
        echo ""
        echo "Examples:"
        echo "  $0 enable 8080         # Redirect all port 80/443 traffic to port 8080"
        echo "  $0 disable 8080        # Tear down redirection rules"
        echo "  $0 status              # Check current NAT rules"
        exit 1
        ;;
esac
