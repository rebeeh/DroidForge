# Installation & Setup

Guide for deploying Waydroid on Fedora Linux with Intel GPU hardware acceleration under Wayland.

## Prerequisites
- [Fedora Linux](https://fedoraproject.org/) Workstation 40+
- [Waydroid](https://waydro.id/) and LXC container runtime
- [Mesa](https://www.mesa3d.org/) DRI drivers for Intel Integrated Graphics
- [Niri](https://github.com/YaLTeR/niri) or any Wayland compositor

## Package Installation
```bash
sudo dnf upgrade --refresh
sudo dnf install waydroid waydroid-selinux lxc
sudo waydroid init -s GAPPS
sudo systemctl enable --now waydroid-container
```
