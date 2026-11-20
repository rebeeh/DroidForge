# Installation & Environment Setup

This guide details setting up [Waydroid](https://waydro.id/) across modern Linux distributions.

---

## 1. System Requirements

- **Operating System**: Any modern Linux distribution (Ubuntu, Debian, Fedora, Arch Linux, openSUSE)
- **Kernel Subsystems**: Linux kernel with `binder` and `ashmem` (standard in Linux 5.15+)
- **Display Server**: Wayland-compatible session (or a nested compositor like Weston/Cage on X11)
- **Graphics**: [Mesa 3D](https://www.mesa3d.org/) drivers with Direct Rendering Infrastructure (DRI) support

---

## 2. Package Installation

### Fedora / RHEL
```bash
sudo dnf install waydroid waydroid-selinux lxc
```

### Ubuntu / Debian
```bash
sudo apt update
sudo apt install waydroid lxc
```

### Arch Linux
```bash
sudo pacman -S waydroid lxc
```

---

## 3. Container Initialization

Initialize the Waydroid Android container image. You can choose between a clean LineageOS image or one with Google Mobile Services (GAPPS):

```bash
# Standard LineageOS image (vanilla)
sudo waydroid init

# Or with Google Play services pre-installed
sudo waydroid init -s GAPPS
```

---

## 4. Service Management

Control the container background daemon using systemd:

```bash
# Start and enable the container service
sudo systemctl enable --now waydroid-container

# Launch a user session
waydroid session start
```

To display Android applications within your existing desktop windows:
```bash
waydroid show-full-ui
```
