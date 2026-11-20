# Input Mapping & Graphics Acceleration

This document covers GPU hardware acceleration and keyboard/mouse input mapping for Android applications running on Linux.

---

## 1. Graphics Acceleration with Mesa

Waydroid shares the host Linux graphics pipeline directly through the Direct Rendering Infrastructure (DRI) nodes:

1. **Verify Render Node**:
   Ensure `/dev/dri/renderD128` is present and accessible:
   ```bash
   ls -l /dev/dri/renderD*
   ```

2. **Verify Driver in Container**:
   Confirm that hardware rendering is active within the Android environment:
   ```bash
   waydroid shell getprop ro.hardware.gralloc
   waydroid shell getprop ro.hardware.egl
   ```
   On systems with Intel, AMD, or other modern GPUs, Mesa supplies accelerated Gallium drivers (`iris`, `crocus`, `radeonsi`, etc.) directly into the container.

---

## 2. Desktop Input Mapping

Because mobile games and touch applications expect touchscreen coordinates rather than mouse pointers, an input mapper converts desktop peripheral events into virtual touch events.

### Integrated Keymapping with Waydroid Helper
[Waydroid Helper](https://github.com/waydroid-helper) includes an integrated input mapping subsystem:
- **Directional Controls**: Maps WASD or arrow keys to on-screen virtual analog sticks.
- **Mouse Aiming**: Locks the cursor to translate mouse movement into camera perspective pans.
- **Custom Hotkeys**: Maps arbitrary keyboard keys to fixed tap coordinates.
- **Multi-action Macros**: Sequences multiple touches from a single keystroke.

Launch `waydroid-helper`, navigate to **Key Mapping**, and customize key binds per application window.

### Universal Input Emulation
For lower-level Linux virtual device creation across different desktop environments, virtual uinput mappers such as [Phantom](https://github.com/frostasm/phantom) can be used to generate synthetic gamepad or touch device events.
