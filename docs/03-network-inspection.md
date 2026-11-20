# Network Traffic Inspection

Intercept and debug HTTPS traffic using [mitmproxy](https://mitmproxy.org/) with native overlay CA certificates.

## Android CA Certificate Storage
Android requires system CA certificates in `/system/etc/security/cacerts/` named after their legacy OpenSSL subject hash (`<hash>.0`).

## Native Waydroid Overlay Installation
Waydroid provides an overlayfs layer where files placed in the host directory:
`/var/lib/waydroid/overlay/system/etc/security/cacerts/`
are mounted directly into the container trust store on boot without requiring third-party root managers.

### Automated Setup
1. Start `mitmweb` on your host machine:
   ```bash
   mitmweb --listen-host 0.0.0.0 --listen-port 8080
   ```
2. Convert and install your CA certificate:
   ```bash
   ./scripts/cert-convert.sh ~/.mitmproxy/mitmproxy-ca-cert.cer --install
   ```
3. Restart the container service:
   ```bash
   sudo systemctl restart waydroid-container
   ```
4. Configure Android global proxy:
   ```bash
   ./scripts/proxy-toggle.sh set 192.168.240.1 8080
   ```
