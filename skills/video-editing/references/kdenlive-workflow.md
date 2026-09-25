# Kdenlive workflow

## 1. Project setup
- *Project → Project Settings*: profile matching the footage (e.g. *HD 1080p 30 fps*). Mixed footage → pick the main camera/recording's profile.
- **Proxy clips**: *Project Settings → Proxy → Enable* (a hardware codec such as x264-vaapi / NVENC if offered, otherwise default). Toggle on the timeline with the proxy button. Essential for smooth 4K or long screen recordings on laptops.
- Folder layout per video:
  ```
  video-name/
    footage/  audio/  music/  graphics/  exports/
    video-name.kdenlive
  ```

## 2. Ingest
Drag files into the **Project Bin**. Create bin folders (right-click → *Create Folder*) for `A-roll`, `B-roll`, `Screen`, `Music`, `Graphics`. Rename clips meaningfully.

## 3. The edit
| Action | Key |
|---|---|
| Play back / pause / forward | J / K / L (tap L twice = 2×) |
| Set in / out in clip monitor | I / O, then drag to timeline or V (insert) / B (overwrite) |
| Razor cut at playhead | Shift+R |
| Select tool / razor tool / spacer | S / X / M |
| Delete + close gap (ripple) | select clip → Shift+Delete, or right-click gap → *Remove Space* |
| Snap toggle | Ctrl+Shift+? (magnet icon in the timeline toolbar) |
| Add marker | M (in timeline) — mark beats, mistakes, zoom points |
| Zoom timeline | Ctrl+wheel · fit project: Ctrl+0 |

**Rough cut → fine cut:** first remove everything unusable (long pauses, retakes), then tighten each cut to breathe ~0.2 s, then reorder for story.

**Screen-recording zooms** (tutorials): split the clip at the moment to highlight → apply *Transform* effect (Effects → Transform, Distort & Perspective → Transform) → keyframe scale 100 % → 150–200 % over 0.3 s with ease-in-out, hold, keyframe back. Save it as a custom effect preset to reuse.

## 4. Titles & graphics
- *Project → Add Title Clip*: text with background, drop shadow; save as template for a consistent series.
- Lower-thirds: design in Inkscape (1920×1080 canvas, transparent PNG), put on a track above video, add *Fade in / Fade out*.
- Logo watermark: PNG on the top track for the whole duration, opacity 60 %.

## 5. Color
Effects → *Color and Image Correction*: **Lift/Gamma/Gain**, **Curves**, **White Balance (LMS)**. Use scopes (*View → Waveform / Vectorscope / RGB Parade*). Grade one clip, copy effects (Ctrl+C, right-click others → *Paste Effects*). LUTs via the *Apply LUT* effect.

## 6. Audio
1. Voice track: *Effects → Audio*: **Noise suppressor for voice** (RNNoise, if listed) or *Equalizer* (low-cut 80 Hz) → **Compressor** → **Limiter** at −1 dB.
2. Music: duck under voice — keyframe volume −18 to −22 dB under speech, or use the *Audio Mixer* (View → Audio Mixer).
3. After export, measure/fix loudness: `bash <skill-dir>/scripts/loudnorm.sh exports/final.mp4 --target -14`.

## 7. Subtitles
*Project → Subtitles → Add Subtitle Track*. **Speech recognition** (Whisper or VOSK models) auto-generates timed text: *Project → Subtitles → Speech Recognition* → first run asks to install the model. Style the track (font Inter Bold, outline) for burn-in, or *Export Subtitle File* (.srt) for YouTube.

## 8. Render
*Project → Render* (Ctrl+Return):
- Preset **MP4-H264/AAC** (software, best size) or the **VAAPI** variant if listed (fast).
- Quality slider ~ high; *Rendering → Render using proxy* **off**.
- Or render from the terminal: `bash <skill-dir>/scripts/render-project.sh video-name.kdenlive exports/video-name.mp4`.
- Then platform versions: `bash <skill-dir>/scripts/encode.sh exports/video-name.mp4 vertical` etc.

## 9. Backup
*Project → Archive Project* collects all media next to the `.kdenlive` file — do this when a project is done.
