# OBS setup

OBS stores everything in its config folder — Linux `~/.config/obs-studio/` (Flatpak: `~/.var/app/com.obsproject.Studio/config/obs-studio/`), macOS `~/Library/Application Support/obs-studio/`, Windows `%APPDATA%\obs-studio\`:
- `basic/profiles/<Profile>/basic.ini` — output/video/audio settings
- `basic/scenes/<Collection>.json` — scenes, sources, filters
- `global.ini` — which profile/collection is active

**Close OBS before editing these files by hand or by script** — it rewrites them on exit.
Create new ones (*Profile → New*, *Scene Collection → New*) instead of editing `Untitled`, so there's always a fallback.

## Profile "Pro Recording"
| Setting | Value |
|---|---|
| Settings → Video | Base & output 1920×1080, **60 fps** for screen demos with motion (30 fine for talking) |
| Output mode | **Advanced** |
| Recording → Type / format | Standard · **MKV** · a dedicated folder, e.g. `~/Videos/OBS` |
| Recording → Encoder | Hardware H.264/HEVC: **NVENC** (NVIDIA) · **AMF** (AMD, Windows) · **QSV** (Intel) · **FFmpeg VAAPI** (AMD/Intel on Linux) · **Apple VT** (macOS); x264 if none |
| Rate control | **CQP/CRF**, 18 (screen text stays sharp) · keyframe interval 2 s · profile High |
| Audio tracks | Track 1 = mic, Track 2 = desktop, (Track 3 = mix) |
| Settings → Advanced → Recording | ✔ **Automatically remux to MP4** · filename `%CCYY-%MM-%DD_%hh-%mm-%ss` |
| Settings → Audio | 48 kHz, stereo |
| Replay buffer | on, 30 s — "save that moment" hotkey |

## Scene collection "Pro Studio"
| Scene | Sources (top → bottom) |
|---|---|
| **Screen** | Display/Screen Capture (Linux Wayland: *Screen Capture (PipeWire)*, cursor embedded) |
| **Screen + Cam** | Webcam (Video Capture Device) with *Advanced Mask* rounded rect + *Stroke Glow Shadow*, bottom-right 360×360 · Screen Capture |
| **Cam** | Webcam full frame with *Background Removal* (off by default) · background image |
| **Starting Soon / BRB / Ending** | Title text (Inter Bold) · background image or gradient |
| *Nested* "Screen (zoomable)" | reuse the screen source via *Source Clone* so zoom filters don't affect other scenes |

Extras:
- **Privacy blur**: a *Composite Blur* filter on the screen source with a rectangle mask, hidden by default; toggle via hotkey (source filter visibility hotkeys come with Move Transition / Advanced Scene Switcher).
- **Keystrokes**: run a keystroke overlay (showmethekey on Linux, KeyCastr on macOS, Carnac on Windows), add a *Window Capture* of its overlay, place bottom-center.

## Mic filter chain (in order)
1. **Noise Suppression** — RNNoise
2. **Noise Gate** — close −45 dB, open −38 dB
3. **Compressor** — ratio 4:1, threshold −18 dB, output gain to taste
4. **Limiter** — −1 dB
Speak normally and aim for the mic meter to peak in the yellow (−10 to −6 dB).

## Hotkeys (Settings → Hotkeys; on Linux Wayland global hotkeys need obs-wayland-hotkeys)
| Action | Suggested |
|---|---|
| Start / stop recording | Ctrl+Alt+R |
| Pause recording | Ctrl+Alt+P |
| Scene: Screen / Screen + Cam / Cam | Ctrl+Alt+1 / 2 / 3 |
| Zoom in / out (Move Transition) | Ctrl+Alt+Z / Ctrl+Alt+X |
| Toggle privacy blur | Ctrl+Alt+B |
| Save replay | Ctrl+Alt+S |
On Wayland the desktop may ask once to allow OBS to register global shortcuts — accept.
