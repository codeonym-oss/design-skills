# Drawing tablet setup

Tablets are configured on your desktop (the container never sees them). Pressure behaviour you tune inside Krita
travels with your Krita settings on any OS.

## Linux
- **GNOME** (X11 or Wayland): *Settings → Wacom Tablet* (visible while a tablet is connected). Drivers: `libwacom` + libinput — no `xf86-input-wacom` needed on Wayland.
- **KDE Plasma**: *System Settings → Drawing Tablet*.
- Check recognition: `libwacom-list-local-devices` (or run this skill's `check.sh` on the desktop).
- Unsupported models (some Huion / XP-Pen / Gaomon): **OpenTabletDriver** (https://opentabletdriver.net) adds full configuration.

## Windows
Install the vendor driver (Wacom, Huion, XP-Pen). In Krita: *Settings → Configure Krita → Tablet Settings* → try
**Windows Ink** first; switch to **WinTab** if pressure is missing or laggy.

## macOS
Install the vendor driver and allow it in *System Settings → Privacy & Security → Accessibility / Input Monitoring*.

## Settings worth making (any OS)
- **Map to monitor**: the monitor you draw on; *Keep aspect ratio* so circles stay circles.
- **Tip feel**: toward *Soft* if you press lightly.
- **Pen buttons**: lower → *Right click* (Krita's pop-up palette), upper → *Middle click* (pan).
- **Krita pressure curve**: *Settings → Configure Krita → Tablet Settings → Input pressure global curve* — an S-curve if strokes jump from thin to thick.

## Test
Krita → brush *Basic-5 Size Opacity* → one stroke light → hard → light. It should taper smoothly at both ends.
