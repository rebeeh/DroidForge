#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -lt 1 ]; then
    echo "Usage: $0 <path-to-ca-cert.cer|crt|pem> [--install]"
    exit 1
fi

CERT_FILE="$1"
INSTALL_FLAG="${2:-}"

if [ ! -f "$CERT_FILE" ]; then
    echo "[-] Error: Certificate file not found: $CERT_FILE" >&2
    exit 1
fi

HASH=$(openssl x509 -inform PEM -subject_hash_old -in "$CERT_FILE" 2>/dev/null | head -n 1)

if [ -z "$HASH" ]; then
    echo "[-] Error: Failed to extract subject hash. Ensure valid PEM format." >&2
    exit 1
fi

TARGET_NAME="${HASH}.0"
cp "$CERT_FILE" "$TARGET_NAME"
chmod 644 "$TARGET_NAME"

echo "[+] Generated Android CA file: ${TARGET_NAME}"

if [ "$INSTALL_FLAG" = "--install" ]; then
    OVERLAY_DIR="/var/lib/waydroid/overlay/system/etc/security/cacerts"
    echo "[*] Installing to ${OVERLAY_DIR}..."
    sudo mkdir -p "$OVERLAY_DIR"
    sudo cp "$TARGET_NAME" "$OVERLAY_DIR/"
    sudo chmod 644 "$OVERLAY_DIR/$TARGET_NAME"
    echo "[+] Certificate successfully installed to Waydroid overlay."
    echo "[*] Restart container: sudo systemctl restart waydroid-container"
fi
