# Advanced Network Analysis & Troubleshooting

When intercepting network traffic from modern mobile applications on Waydroid, standard HTTP proxy configurations often fail to display readable requests. 

This guide details the network architecture hurdles that cause traffic to bypass or fail in [mitmproxy](https://mitmproxy.org/), and provides a systematic diagnostic workflow.

---

## 1. Why Standard Proxies Fail on Modern Apps

Unlike web browsers, complex mobile applications do not rely solely on Android's standard Java networking stack. Three primary barriers prevent standard proxy interception:

```text
+-------------------------------------------------------------------+
|                     Mobile Application Layer                     |
|                                                                   |
|   [ Browser / WebView ]              [ Native C++ Engine ]        |
|     (Java HttpUrlConn)                 (Cronet / Tigon / Custom)  |
|            |                                    |                 |
|   Respects http_proxy                 Bypasses http_proxy         |
|            |                                    |                 |
|   TCP / TLS (Port 443)                 QUIC / UDP (Port 443)      |
+------------|------------------------------------|-----------------+
             |                                    |
             v                                    v
     [ mitmproxy (TCP) ]                  [ Direct to Gateway ]
   (Handshake or Pinning Fail)            (Completely Invisible)
```

### Barrier A: Advisory Proxy Settings
Setting Android's global proxy via:
```bash
adb shell settings put global http_proxy 192.168.240.1:8080
```
is **advisory**. While standard WebViews and basic Java `HttpURLConnection` consumers adhere to it, native C/C++ networking runtimes (such as Chromium Cronet, Meta Tigon, or Flutter's Dart VM) create raw POSIX sockets directly to destination IPs, completely ignoring the Android proxy configuration.

### Barrier B: QUIC / HTTP/3 over UDP 443
Modern applications preferentially establish connections using QUIC (HTTP/3) over UDP port 443.
- Standard HTTP/HTTPS proxies only listen for TCP connections.
- UDP traffic completely bypasses the proxy and routes directly out of the `waydroid0` virtual bridge interface to the internet.

### Barrier C: Custom Certificate Pinning
Even with a CA certificate installed in the Android system trust store (`/system/etc/security/cacerts/`), production applications often validate server certificates against a hardcoded set of public key hashes (HPKP / certificate pinning). When mitmproxy intercepts the connection and presents its dynamically generated certificate, the application detects the mismatch and terminates the TLS handshake.

---

## 2. Step-by-Step Diagnostic Workflow

To identify exactly which barrier is affecting your environment, diagnose the layers from bottom to top:

### Step 1: Raw Packet Capture on Host (`waydroid0`)
Before looking at proxy logs, capture raw packets on the host bridge interface to confirm where traffic is flowing:

```bash
# Verify the interface name on Fedora host
ip -br addr show waydroid0

# Capture raw packets to a PCAP file
sudo tcpdump -i waydroid0 -nn -w waydroid_traffic.pcap
```

Open `waydroid_traffic.pcap` in [Wireshark](https://www.wireshark.org/) and apply the following display filters:

| Filter | Purpose | What to Look For |
| :--- | :--- | :--- |
| `udp.port == 443` | QUIC / HTTP/3 Traffic | If packets appear here, the app is using QUIC and bypassing your TCP proxy. |
| `tcp.port == 8080` | Proxy Traffic | Packets arriving at mitmproxy. If empty, the app is ignoring the proxy setting. |
| `tls.handshake.type == 1` | TLS Client Hello | Identifies destination SNIs (domain names) being contacted. |
| `tls.alert_message` | TLS Termination | Indicates certificate rejection (pinning failure). |

---

### Step 2: Forcing QUIC Fallback to TCP
If the application sends UDP port 443 packets, block outbound UDP 443 on the host so the application's networking stack falls back to standard TCP:

```bash
# Drop outbound UDP 443 on the Waydroid bridge
sudo iptables -I FORWARD -i waydroid0 -p udp --dport 443 -j DROP
```

With UDP blocked, RFC-compliant networking libraries fall back to TCP, allowing interception tools to see the connection.

---

### Step 3: Transparent Proxy Redirection (iptables)
If the application bypasses the advisory proxy setting and connects directly to external IP addresses over TCP 443, configure transparent redirection on the Fedora host:

```bash
# 1. Enable IP forwarding on host
sudo sysctl -w net.ipv4.ip_forward=1

# 2. Redirect outbound TCP 80 and 443 from waydroid0 to mitmproxy
sudo iptables -t nat -A PREROUTING -i waydroid0 -p tcp --dport 80 -j REDIRECT --to-port 8080
sudo iptables -t nat -A PREROUTING -i waydroid0 -p tcp --dport 443 -j REDIRECT --to-port 8080

# 3. Start mitmproxy in transparent mode
mitmweb --mode transparent --listen-port 8080 --listen-host 0.0.0.0
```

---

### Step 4: Distinguishing Pinning from Network Errors
Once traffic is reaching mitmproxy:

1. **Check mitmproxy Event Log**:
   - If you see `Client TLS handshake failed: Certificate verification failed`, traffic is being successfully routed to the proxy, but the application is enforcing **certificate pinning**.
   - If requests load with HTTP 200/300 responses, the system CA is accepted.

2. **Application Analysis**:
   - For applications with strict certificate pinning, standard proxy interception alone is insufficient. Observing application behavior requires either:
     - Application-layer network inspection via [PCAPdroid](https://github.com/emanuele-f/PCAPdroid).
     - Dynamic binary instrumentation (such as [Frida](https://frida.re/)) to observe unencrypted buffers or hook the TLS verification functions in a dedicated test environment.

---

## 3. Alternative Tooling Matrix

| Tool | Operating Level | Decrypts Pinning? | Primary Use Case |
| :--- | :--- | :--- | :--- |
| **tcpdump / Wireshark** | Network / Transport Layer | No | Packet-level flow analysis, discovering destination IPs, protocols (TCP/UDP), and SNIs. |
| **PCAPdroid** | Android VpnService Layer | No (unless integrated with unpinned mitm) | Per-application connection metadata, bandwidth measurement, and QUIC detection. |
| **mitmproxy** | Application / HTTP Layer | Requires CA trust (fails on pinned apps) | Full request/response body analysis and modification on unpinned traffic. |
| **Frida** | Process Memory / Runtime Layer | Yes (via function hooks) | Inspecting function arguments, tracing custom network engines, and security research. |
