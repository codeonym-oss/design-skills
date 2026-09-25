# OBS plugins: what each one is for

Get plugins from https://obsproject.com/forum/plugins/ (Windows/macOS installers) or your Linux distro / Flathub (`com.obsproject.Studio.Plugin.*`). Run `bash <skill-dir>/scripts/check.sh` to see the plugin folders OBS loads from. After an OBS major update, update plugins too — an outdated plugin silently fails to load.

**Building a plugin from source fails with `is deprecated [-Werror=deprecated-declarations]`**: the plugin treats
warnings as errors and OBS deprecated an API it uses. Configure with warnings allowed:
`cmake -DCMAKE_COMPILE_WARNING_AS_ERROR=OFF …` (on Arch/AUR, add that flag to the PKGBUILD's cmake call).

| Plugin | Where in OBS | Use it for |
|---|---|---|
| obs-move-transition | Transition *Move*; filters *Move Source / Move Value* | Animated zooms/pans, sliding webcams, smooth scene changes |
| obs-advanced-masks | Filter *Advanced Masks* | Rounded/circle webcam, spotlight, gradient fades |
| obs-composite-blur | Filter *Composite Blur* | Background blur, hiding secrets, frosted-glass panels |
| obs-shaderfilter-git | Filter *User-defined shader* | Vignette, glow, color looks, CRT, custom GLSL |
| obs-source-clone | Source *Source Clone* | Same source in many scenes with different filters |
| obs-source-record | Filter *Source Record* | Record webcam and screen as separate files for editing |
| obs-freeze-filter | Filter *Freeze* | Freeze the frame to annotate or explain |
| obs-3d-effect | Filter *3D Effect* | Tilted, perspective "floating screen" looks |
| obs-stroke-glow-shadow | Filters *Stroke / Glow / Shadow* | Outline + shadow on webcam frames and cut-outs |
| obs-backgroundremoval | Filter *Background Removal* | Remove the webcam background without a green screen (CPU-heavy without a GPU — keep at 15 fps / a small model) |
| obs-pipewire-audio-capture (Linux) | Source *Application Audio Capture (PipeWire)* | Record only the browser / one app, not chat or notifications (built into OBS on Windows) |
| obs-wayland-hotkeys (Linux) | automatic | Global hotkeys on Wayland via the GlobalShortcuts portal |
| obs-advanced-scene-switcher | *Tools → Advanced Scene Switcher* | Automations: switch scene when a window is focused, on a timer, toggle filters by hotkey |
| obs-studio-plugin-browser | Source *Browser* | HTML overlays, lower-thirds, live widgets |

## Recipes

### Manual zoom on a screen area (Move Transition)
1. Scene **Screen**: add a *Move Source* filter on the scene (filters on the scene, target = your Screen Capture).
2. Set the filter's transform: *Scale* 2.0 and *Position* so the area you want fills the frame; *Duration* 300 ms, *Easing* Cubic in-out. Name it `Zoom In`.
3. Add a second *Move Source* filter with scale 1.0, position 0,0 → `Zoom Out`.
4. Settings → Hotkeys: bind `Zoom In` / `Zoom Out` enable keys (Ctrl+Alt+Z / X).
Several zoom presets (e.g. "Zoom terminal", "Zoom browser URL bar") = several filters.

### Rounded webcam with outline and shadow
Webcam source → *Advanced Masks* (Shape: Rectangle, Corner radius 40, or Circle) → *Stroke* (4 px, your brand color) → *Shadow* (blur 20, offset 0,8, opacity 50 %). Position bottom-right with 32 px margin.

### Hide a password/API key while recording
Screen source → *Composite Blur* (Gaussian, radius 30) with *Effect mask: Rectangle* sized over the secret; bind a hotkey to toggle the filter. Always double-check in the edit too.

### Record camera and screen separately
Add *Source Record* filters to the webcam and the screen source (different output paths). One OBS recording → you get clean separate files to cut between in Kdenlive.

### App-only audio
Remove *Desktop Audio*; add *Application Audio Capture* (Windows, macOS 13+) or *Application Audio Capture (PipeWire)* (Linux) → pick the browser. Notification sounds and chat apps stay out of the recording.

### Freeze-and-explain
*Freeze* filter on the screen source, hotkey to toggle; while frozen, talk over it or draw with a screen annotation tool.
