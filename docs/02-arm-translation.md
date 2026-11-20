# ARM Translation with Waydroid Helper

Guide for installing Libhoudini ARM translation using Waydroid Helper on x86_64 systems.

## Why Waydroid Helper?
[Waydroid Helper](https://github.com/waydroid-helper) manages binary translation safely:
- Downloads verified Libhoudini builds for Android 11 / 13.
- Writes files to `/var/lib/waydroid/overlay/system`, keeping the base image intact.
- Preserves configuration across system image upgrades.

## Graphical Installation
Install the helper package:
```bash
sudo dnf install waydroid-helper
```
Open `waydroid-helper`, navigate to **Extensions**, select **Libhoudini**, and click install.

## CLI Alternative
```bash
git clone https://github.com/casualsnek/waydroid_script.git
cd waydroid_script
python3 -m venv venv
venv/bin/pip install -r requirements.txt
waydroid session stop
sudo waydroid container stop
sudo venv/bin/python3 main.py install libhoudini
```
