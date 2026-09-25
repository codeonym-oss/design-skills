---
name: screen-recording
description: Professional screen and camera recording with OBS Studio (scenes, filters, plugins, hardware encoding) on Windows, macOS or Linux (incl. GNOME/KDE Wayland), keystroke overlays, auto-zoom demo recorders, presenter-mode cursor settings, and post-production of recordings (remux, trim, loudness) in a reproducible container. Use when the user wants to record a tutorial, demo, course, talk or stream, set up or configure OBS scenes/profiles/filters, needs zoom-on-click or cursor highlighting, keystroke display, or wants to clean up a finished recording.
---

# Screen recording (OBS · post-production)

Recording happens on the user's desktop — a container can't see the screen. `check.sh` and `presenter-mode.sh`
therefore run on the host; `finish-recording.sh` runs in the design-skills container automatically (see `design-sandbox`).

## Toolkit

| Tool | Use it for | Platforms |
|---|---|---|
| **OBS Studio** | Scenes (screen, cam, screen+cam), filters, recording, streaming | Windows · macOS · Linux — https://obsproject.com |
| OBS plugins | Move Transition, masks, blur, background removal, source record… — see `references/obs-plugins.md` | inside OBS |
| **Keystroke overlay** | Show shortcuts on screen — capture its window in OBS | showmethekey (Linux) · KeyCastr (macOS) · Carnac (Windows) |
| **Auto-zoom recorders** | Screen Studio–style zoom-on-click demos | Screen Studio (macOS) · OpenScreen / Cap (cross-platform) |
| **ffmpeg** (container) | Remux, trim, loudness, review copies | `finish-recording.sh` |
| **Kdenlive / ffmpeg** | Editing and delivery | `video-editing` skill |

## Platform notes

- **Linux Wayland (GNOME/KDE):** capture with the *Screen Capture (PipeWire)* source; the portal asks which screen/window.
  Live zoom-follow-mouse plugins need X11 cursor coordinates and don't work — use Move Transition hotkeys, an auto-zoom
  recorder, or zooms in post (keyframed *Transform* in Kdenlive). Global hotkeys need a GlobalShortcuts-portal plugin (e.g. obs-wayland-hotkeys).
- **macOS:** grant *Screen Recording* and *Microphone* permission to OBS (System Settings → Privacy & Security).
- **Windows:** *Display Capture* or *Window Capture*; NVENC/AMF/QSV hardware encoders are listed under Output.

## Scripts

| Script | What it does |
|---|---|
| `check.sh` | OBS + plugin folders, session type, keystroke-overlay tool, presenter settings — on this desktop |
| `presenter-mode.sh on [size] \| off \| status` | GNOME: bigger cursor + Ctrl ripple for recording; `off` restores your settings (tells you the equivalent elsewhere) |
| `finish-recording.sh <rec.mkv> [--trim-start S] [--trim-end S] [--target -14] [--denoise]` | Lossless remux to MP4, trim, loudness-normalize, plus a small review copy |

## Guides

- `references/obs-setup.md` — recommended profile (hardware encoder, CQP/CRF, MKV + auto-remux), scene layout, mic filter chain, hotkeys.
- `references/obs-plugins.md` — useful plugins: what each is for and a concrete recipe.
- `references/recording-workflow.md` — pre-flight checklist, recording technique, post-production pipeline.

## Rules of thumb

1. Record **MKV** (crash-safe) with *Automatically remux to MP4* on.
2. Use the hardware encoder (NVENC / AMF / QSV / VAAPI / Apple VT) at CQP/CRF 18–20 — the CPU stays free for the apps you demo.
3. Canvas 1920×1080; scale apps so text is readable at 1080p (editor font ≥ 16, browser zoom 125 %).
4. Mic on track 1, desktop audio on track 2 (Advanced Audio Properties) — fix the balance in the edit.
5. Presenter mode on, notifications off (Do Not Disturb / Focus), clean desktop.
