# DroidForge

<p align="center">
  <strong>A reproducible research and engineering environment for running, debugging, and testing Android applications on Linux with native GPU acceleration, ARM binary translation, and HTTPS network inspection.</strong>
</p>

<p align="center">
  <a href="#-technical-stack"><img src="https://img.shields.io/badge/Platform-Linux-blue?logo=linux" alt="Platform"></a>
  <a href="#-technical-stack"><img src="https://img.shields.io/badge/Container-Waydroid-success?logo=android" alt="Waydroid"></a>
  <a href="#-technical-stack"><img src="https://img.shields.io/badge/Graphics-Mesa%20DRI-orange" alt="Mesa DRI"></a>
  <a href="#-technical-stack"><img src="https://img.shields.io/badge/ARM%20Translation-Libhoudini-brightgreen" alt="Libhoudini"></a>
  <a href="#-technical-stack"><img src="https://img.shields.io/badge/Inspection-mitmproxy%20%7C%20Frida-red" alt="Inspection"></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/License-MIT-purple" alt="License"></a>
</p>

---

## 📑 Quick Navigation
- [🔬 Technical Stack](#-technical-stack)
- [🚀 Why Waydroid Helper?](#-why-waydroid-helper)
- [🔒 Native Certificate Injection](#-native-system-certificate-injection)
- [📚 Documentation Index](#-documentation-index)
- [🧰 Included Helper Scripts](#-included-helper-scripts)
- [🏷️ Repository Metadata & Tags](#️-repository-metadata--tags)
- [📄 License](#-license)

---

## 🔬 Technical Stack

| Layer | Component | Details / Responsibility |
| :--- | :--- | :--- |
| **Host OS** | Modern Linux | Ubuntu, Debian, Fedora, Arch Linux, openSUSE |
| **Container Virtualization** | [Waydroid](https://waydro.id/) | Native Linux container (LXC) architecture running LineageOS |
| **Graphics Pipeline** | [Mesa 3D](https://www.mesa3d.org/) | Direct Rendering Infrastructure (`/dev/dri/renderD128`) hardware acceleration |
| **ARM Translation** | [Libhoudini](https://github.com/waydroid-helper) | Dynamic ARM (`arm64-v8a` / `armeabi-v7a`) to x86_64 binary translation |
| **Helper Tooling** | [Waydroid Helper](https://github.com/waydroid-helper) | Automated lifecycle management for extensions, translation, and keymaps |
| **Network Interception** | [mitmproxy](https://mitmproxy.org/) | System CA certificate overlay injection for HTTPS interception |
| **Runtime Tracing** | [Frida](https://frida.re/) | Dynamic instrumentation for inspecting in-memory network calls |
| **Input Mapping** | Integrated Helper / [Phantom](https://github.com/frostasm/phantom) | Touchscreen to mouse/keyboard event translation |

---

## 🚀 Why Waydroid Helper?

Modifying container root partitions manually can lead to filesystem corruption and broken OTA updates. Using [Waydroid Helper](https://github.com/waydroid-helper) (`waydroid_script`) is strongly recommended:

1. **Overlay Architecture**: Libhoudini translation libraries and configurations reside in `/var/lib/waydroid/overlay/system`, keeping the base container image pristine.
2. **Persistence Across Updates**: Upstream container updates do not overwrite your ARM translation libraries or configuration files.
3. **Integrated Controller Mapping**: Built-in support for mapping mouse aiming, WASD movement, and hotkeys directly to touchscreen coordinates.

---

## 🔒 Native System Certificate Injection

DroidForge leverages Waydroid's native overlay architecture for trusted CA certificates:
* Placing the hashed certificate (`<hash>.0`) inside `/var/lib/waydroid/overlay/system/etc/security/cacerts/` mounts it directly into the system trust store on container boot.
* **No root modules (such as Magisk) are required.** The host kernel manages the overlay cleanly.

---

## 📚 Documentation Index

| Guide | Description |
| :--- | :--- |
| [**01 - Host Installation & Setup**](docs/01-installation.md) | Package installation across Linux distributions and container initialization. |
| [**02 - ARM Translation with Waydroid Helper**](docs/02-arm-translation.md) | Deploying Libhoudini for running ARM and ARM64 applications on x86_64. |
| [**03 - Network Traffic Inspection & CA Certificates**](docs/03-network-inspection.md) | Converting CA certificates, overlay staging, and global proxy configuration. |
| [**04 - Input Mapping & Graphics Acceleration**](docs/04-input-mapping.md) | Mesa DRI hardware rendering verification and desktop keymapping controls. |
| [**05 - Advanced Network Analysis & Troubleshooting**](docs/05-advanced-network-analysis.md) | Diagnosing proxy bypass, QUIC / HTTP/3 blocking, and transparent NAT redirection. |
| [**06 - Runtime Traffic Analysis with Frida**](docs/06-runtime-traffic-analysis-frida.md) | In-process network call tracing for pinned or custom native network engines. |

---

## 🧰 Included Helper Scripts

All scripts are located in the [`scripts/`](scripts/) directory and are pre-configured with executable permissions:

| Script | Purpose |
| :--- | :--- |
| [`scripts/cert-convert.sh`](scripts/cert-convert.sh) | Converts PEM certificates to `<hash>.0` and installs to the Waydroid overlay |
| [`scripts/proxy-toggle.sh`](scripts/proxy-toggle.sh) | Sets, checks, or clears the Android global HTTP proxy via ADB |
| [`scripts/verify-env.sh`](scripts/verify-env.sh) | Diagnostic verifier for Linux host session, render nodes, and ADB connectivity |
| [`scripts/capture-traffic.sh`](scripts/capture-traffic.sh) | Captures raw `.pcap` packets on the `waydroid0` virtual bridge for Wireshark |
| [`scripts/block-quic.sh`](scripts/block-quic.sh) | Blocks outbound UDP 443 to force apps from QUIC/HTTP/3 to fall back to TCP |
| [`scripts/transparent-proxy.sh`](scripts/transparent-proxy.sh) | Configures host `iptables` PREROUTING rules for apps bypassing system proxy |
| [`scripts/setup-frida-server.sh`](scripts/setup-frida-server.sh) | Auto-detects container ABI, downloads, pushes, and launches `frida-server` |

---

## 🏷️ Repository Metadata & Tags

For configuring the GitHub repository settings (About section):

* **Description**: Reproducible research environment for running, debugging, and testing Android apps on Linux with GPU acceleration, ARM translation, and network inspection.
* **Website**: `https://github.com/rebeeh/DroidForge#readme`
* **Suggested Topics / Tags**:
  ```text
  waydroid, android, linux, libhoudini, arm-translation, mitmproxy, frida, network-analysis, mesa-dri, lxc
  ```

---

## 📄 License

This project is licensed under the [MIT License](LICENSE).
