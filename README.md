# DroidForge

A reproducible research and engineering environment for running, debugging, and testing Android applications on [Fedora Linux](https://fedoraproject.org/) with native Intel graphics acceleration, ARM binary translation, and HTTPS network inspection.

---

## Technical Stack

- **Host Operating System**: [Fedora Linux](https://fedoraproject.org/) (40+)
- **Wayland Compositor**: [Niri](https://github.com/YaLTeR/niri) (Scrollable-tiling Wayland compositor)
- **Container Virtualization**: [Waydroid](https://waydro.id/) (LXC-based LineageOS container)
- **Graphics Pipeline**: [Mesa 3D](https://www.mesa3d.org/) (`iris` driver for Intel Integrated GPUs)
- **ARM Translation**: Libhoudini (Translates ARM/ARM64 calls for x86_64 host execution)
- **Helper Utilities**: [Waydroid Helper](https://github.com/waydroid-helper) (`waydroid-helper` / `waydroid-cli`)
- **Traffic Interception**: [mitmproxy](https://mitmproxy.org/) with native system overlay CA certificates
- **Input Mapping**: Integrated Waydroid Helper keymapper & [Phantom](https://github.com/frostasm/phantom)

---

## Why Waydroid Helper?

Using [Waydroid Helper](https://github.com/waydroid-helper) is recommended over manual rootfs patching:

1. **Automated Overlay Management**: Libhoudini translation libraries are deployed into `/var/lib/waydroid/overlay/system` without modifying the base read-only system image.
2. **Persistence Across Updates**: Upstream OTA image updates do not overwrite your ARM translation or customized configurations.
3. **Integrated Controller Mapping**: Built-in support for mapping mouse aiming, WASD movement, and hotkeys directly to touchscreen coordinates.

---

## Clean Certificate Injection

DroidForge leverages Waydroid's native overlay architecture for trusted CA certificates:
- Placing the hashed certificate (`<hash>.0`) inside `/var/lib/waydroid/overlay/system/etc/security/cacerts/` mounts it directly into the system trust store on boot.
- This provides full system-level HTTPS interception without requiring third-party root frameworks.

---

## Documentation Index

- [01 - Host Installation & Setup](docs/01-installation.md)
- [02 - ARM Translation with Waydroid Helper](docs/02-arm-translation.md)
- [03 - Network Traffic Inspection & CA Certificates](docs/03-network-inspection.md)
- [04 - Input Mapping & Intel GPU Acceleration](docs/04-input-mapping.md)

---

## Included Helper Scripts

- `scripts/cert-convert.sh`: Converts standard PEM certificates to Android `<subject_hash_old>.0` format and optionally installs to the Waydroid overlay.
- `scripts/proxy-toggle.sh`: Controls Android global HTTP proxy settings via ADB.
- `scripts/verify-env.sh`: Diagnostic tool verifying GPU render nodes, Waydroid container status, and ADB connectivity.

---

## License

This project is licensed under the [MIT License](LICENSE).
