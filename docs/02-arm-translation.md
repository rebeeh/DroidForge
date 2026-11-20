# ARM Translation with Libhoudini & Waydroid Helper

To execute Android applications compiled for ARM (`arm64-v8a` and `armeabi-v7a`) on x86_64 hardware, a binary translation layer is required.

---

## 1. Why Waydroid Helper?

Manually unpacking vendor system images and editing container partitions can lead to instability and update failures. [Waydroid Helper](https://github.com/waydroid-helper) automates this setup cleanly:

- Automatically downloads verified Libhoudini builds.
- Mounts files within the Waydroid overlay system (`/var/lib/waydroid/overlay/system`), keeping base images unmodified.
- Retains configuration across container image updates.
- Registers dynamic `binfmt_misc` kernel handlers seamlessly.

---

## 2. Universal Setup via CLI

You can install and run the helper script on any Linux distribution using Python:

```bash
# Clone the automation toolkit
git clone https://github.com/casualsnek/waydroid_script.git
cd waydroid_script

# Create isolated Python virtual environment
python3 -m venv venv
venv/bin/pip install -r requirements.txt

# Stop any active Waydroid processes
waydroid session stop
sudo waydroid container stop

# Install Libhoudini translation layer
sudo venv/bin/python3 main.py install libhoudini
```

If your distribution provides an official package (such as `waydroid-helper` on Fedora or AUR on Arch Linux), you can alternatively install and use the native GUI.

---

## 3. Verification

Restart your Waydroid session:

```bash
waydroid session start
```

Verify that ARM ABI architectures are reported by the Android environment:

```bash
adb shell getprop ro.product.cpu.abilist
```

Expected output includes both x86 and ARM architectures:
```text
x86_64,x86,arm64-v8a,armeabi-v7a,armeabi
```
