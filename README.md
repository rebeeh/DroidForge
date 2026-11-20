# DroidForge

A reproducible research and engineering environment for running, debugging, and testing Android applications on Linux with native GPU hardware acceleration, ARM binary translation, and HTTPS network inspection.

---

## Technical Stack

- **Host Operating System**: Modern Linux distributions (Ubuntu, Debian, Fedora, Arch Linux, openSUSE)
- **Container Virtualization**: [Waydroid](https://waydro.id/) (LXC-based LineageOS container architecture)
- **Graphics Pipeline**: [Mesa 3D](https://www.mesa3d.org/) drivers with Direct Rendering Infrastructure (DRI)
- **ARM Translation**: Libhoudini (x86_64 to ARM / ARM64 execution layer)
- **Helper Utilities**: [Waydroid Helper](https://github.com/waydroid-helper) (`waydroid-helper` / `waydroid-cli` / `waydroid_script`)
- **Traffic Interception**: [mitmproxy](https://mitmproxy.org/) with native system overlay CA certificates
- **Input Mapping**: Integrated Waydroid Helper keymapper & [Phantom](https://github.com/frostasm/phantom)

---

## Why Waydroid Helper?

Using [Waydroid Helper](https://github.com/waydroid-helper) is recommended over manual root filesystem modification:

1. **Overlay Architecture**: Libhoudini translation libraries and customizations reside in `/var/lib/waydroid/overlay/system`, keeping the base container image clean.
2. **Persistence Across Updates**: Upstream container updates do not overwrite your ARM translation libraries or configuration files.
3. **Integrated Controller Mapping**: Built-in support for mapping mouse aiming, WASD movement, and hotkeys directly to touchscreen coordinates.

---

## Native Certificate Injection

DroidForge leverages Waydroid's native overlay architecture for trusted CA certificates:
- Placing the hashed certificate (`<hash>.0`) inside `/var/lib/waydroid/overlay/system/etc/security/cacerts/` mounts it directly into the system trust store on container boot.
- This provides full system-level HTTPS interception without requiring third-party root frameworks.

---

## Documentation Index

- [01 - Host Installation & Setup](docs/01-installation.md)
- [02 - ARM Translation with Waydroid Helper](docs/02-arm-translation.md)
- [03 - Network Traffic Inspection & CA Certificates](docs/03-network-inspection.md)
- [04 - Input Mapping & Graphics Acceleration](docs/04-input-mapping.md)
- [05 - Advanced Network Analysis & Troubleshooting](docs/05-advanced-network-analysis.md)

---

## Included Helper Scripts

- `scripts/cert-convert.sh`: Converts standard PEM certificates to Android `<subject_hash_old>.0` format and optionally installs to the Waydroid overlay.
- `scripts/proxy-toggle.sh`: Controls Android global HTTP proxy settings via ADB.
- `scripts/verify-env.sh`: Diagnostic tool verifying GPU render nodes, Waydroid container status, and ADB connectivity.

---

## License

This project is licensed under the [MIT License](LICENSE).
