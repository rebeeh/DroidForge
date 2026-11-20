# DroidForge

A reproducible research project documenting a rooted, hardware-accelerated Android environment on Fedora Linux with ARM translation, Magisk, mitmproxy, and Waydroid Helper.

## Overview

DroidForge provides practical guides, scripts, and documentation for setting up and debugging Android applications on Fedora Linux using container virtualization (Waydroid) under Wayland compositors (such as Niri).

### Key Features
- **Container Architecture**: Native Waydroid container execution on Linux kernel without emulator overhead.
- **Hardware Acceleration**: Intel Integrated GPU acceleration via Mesa drivers.
- **ARM Translation**: Libhoudini integration for executing ARM and ARM64 binaries on x86_64 hardware.
- **Root Management**: Magisk integration for root control and module support.
- **Helper Integration**: Streamlined deployment using Waydroid Helper (`waydroid_script`).
- **Network Inspection**: System-level CA certificate injection for HTTPS inspection with mitmproxy.

## Documentation

- [Installation Guide](docs/01-installation.md)
- [Waydroid Helper & Root Setup](docs/02-waydroid-helper.md)
- [Network Inspection & Certificates](docs/03-network-mitm.md)
- [Troubleshooting](docs/04-troubleshooting.md)

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
