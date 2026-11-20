# Host Installation & System Setup

<p align="center">
  <a href="../README.md">📚 Documentation Index</a> •
  <a href="02-arm-translation.md">Next: ARM Translation →</a>
</p>

---

This guide walks through deploying [Waydroid](https://waydro.id/) on modern Linux distributions to establish an isolated Android container environment.

---

## 1. System Prerequisites

Before starting, ensure your system meets the fundamental Linux kernel and graphics requirements:

* **Kernel Subsystems**: Linux kernel with Android `binder` and `ashmem` IPC drivers (native in Linux kernel 5.15+).
* **Graphics Infrastructure**: [Mesa 3D](https://www.mesa3d.org/) DRI drivers supporting hardware-accelerated 3D rendering (`/dev/dri/renderD128`).
* **Display Session**: Any Wayland-compatible desktop session (GNOME, KDE Plasma, Sway, Hyprland, etc.) or a nested Wayland compositor (Weston / Cage) on X11.

> [!NOTE]
> Waydroid executes Android inside a native Linux LXC container. It shares the host kernel directly rather than emulating CPU instructions, providing near-bare-metal performance.

---

## 2. Package Installation

Install Waydroid and the container runtime dependencies using your distribution's native package manager:

### Fedora / RHEL
```bash
sudo dnf upgrade --refresh
sudo dnf install waydroid waydroid-selinux lxc
```

### Ubuntu / Debian
```bash
sudo apt update
sudo apt install waydroid lxc
```

### Arch Linux
```bash
sudo pacman -Syu waydroid lxc
```

### openSUSE
```bash
sudo zypper refresh
sudo zypper install waydroid lxc
```

---

## 3. Initializing the Android Image

Waydroid offers two official Android system image variants:
1. **Vanilla (AOSP/LineageOS)**: Minimal image without Google proprietary services.
2. **GAPPS**: Includes Google Mobile Services (Play Store, Play Services framework).

```bash
# Option A: Standard LineageOS image
sudo waydroid init

# Option B: Image with Google Play Services (Recommended for testing store apps)
sudo waydroid init -s GAPPS
```

> [!TIP]
> If you need to re-initialize or switch images later, stop the container and run `sudo waydroid init -f` with your desired flags.

---

## 4. Starting the Container Service

Waydroid relies on a system daemon managing container network namespaces and mounts, and a per-user session daemon rendering windows into your desktop.

1. **Enable and start the system service**:
   ```bash
   sudo systemctl enable --now waydroid-container
   ```

2. **Launch a user session**:
   ```bash
   waydroid session start
   ```

3. **Launch the full Android UI**:
   In another terminal, display the full Android window:
   ```bash
   waydroid show-full-ui
   ```

> [!IMPORTANT]
> To verify that the container service and graphics nodes are correctly detected, run the environment diagnostic tool:
> ```bash
> ./scripts/verify-env.sh
> ```

---

<p align="center">
  <a href="../README.md">← Documentation Index</a> •
  <a href="02-arm-translation.md">Next: 02 - ARM Translation with Waydroid Helper →</a>
</p>
