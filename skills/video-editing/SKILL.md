---
name: video-editing
description: Video editing and delivery with Kdenlive (desktop) and MLT/melt + ffmpeg 8 (x264/x265/SVT-AV1/VP9, VAAPI when a GPU is available) running headlessly in a reproducible container. Use when the user wants to edit a video (tutorial, demo, vlog, promo, reel), cut/trim/concatenate clips, add titles/subtitles/music, fix or normalize audio, export for YouTube/LinkedIn/Instagram/TikTok/web, make GIFs, pull thumbnails, or render a Kdenlive project from the terminal.
---

# Video editing (ffmpeg · melt · Kdenlive)

Scripts run inside the design-skills container automatically (`bash <skill-dir>/scripts/<name>.sh …`, see
`design-sandbox`). `render-project.sh` needs the **full** image (melt); the ffmpeg scripts run in **core**.

## Toolkit

| Tool | Use it for | CLI (in the container) |
|---|---|---|
| **ffmpeg 8** | Encode, convert, trim, loudness, GIFs; x264, x265, SVT-AV1, VP9 | `ffmpeg`, `ffprobe` |
| **melt 7** (MLT) *(full image)* | Kdenlive's render engine — renders `.kdenlive` projects headlessly | `melt` |
| **Kdenlive** | Multi-track editing: cuts, titles, transitions, color, audio, subtitles | desktop app (Windows/macOS/Linux) |
| **Blender VSE** *(full image)* | Backup editor; 3D/motion-graphic inserts | `3d-modeling` skill |
| **Inkscape / ImageMagick** | Thumbnails, lower-thirds, title cards as PNG with alpha | `graphic-design` skill |

**Hardware encoding:** on a Linux host with a GPU render node (`/dev/dri`), the container gets it automatically and
`encode.sh` uses VAAPI H.264/HEVC. Everywhere else it encodes in software — same result, slower. `--sw` forces software
(smaller files at equal quality). Disable GPU passthrough with `DS_GPU=0`.

## Scripts

| Script | What it does |
|---|---|
| `check.sh` | ffmpeg encoders, VAAPI availability, melt |
| `encode.sh <in> <preset> [out] [--sw]` | Presets: `web`, `youtube`, `vertical` (1080×1920 blurred fill), `square`, `archive` (HEVC), `preview` |
| `loudnorm.sh <in> [--target -14] [--denoise] [out]` | Two-pass EBU R128 loudness normalization (video copied untouched), optional noise reduction |
| `gif.sh <in> [--start S] [--dur D] [--width W] [--fps F]` | Palette-optimized GIF + a far smaller WebM for READMEs/docs |
| `thumbs.sh <in> [count]` | Evenly spaced frame grabs + a storyboard sheet for picking a thumbnail |
| `render-project.sh <project.kdenlive> [out.mp4] [--crf 20]` | Renders a Kdenlive/MLT project with melt, no GUI |

## Guides

- `references/kdenlive-workflow.md` — project setup, proxy clips, the edit (J/K/L, razor, ripple), titles, color, audio, subtitles, render.
- `references/delivery-specs.md` — per-platform specs, loudness targets, and the ffmpeg one-liners worth knowing.

## Rules of thumb

1. Project profile = your footage (usually 1080p 30 or 60 fps). Use **proxy clips** for 4K or long screen recordings.
2. Story first: rough cut → fine cut → B-roll/zooms → titles → color → audio → export.
3. Audio matters more than video: **−14 LUFS** for YouTube/social, **−16 LUFS** for voice/podcast.
4. Keep masters (`archive` preset or lossless), deliver platform versions from them.
5. Burn captions for social (most people watch muted); upload `.srt` separately for YouTube.
6. `render-project.sh` needs the media paths inside the project to be reachable — keep media next to the project (Kdenlive: *Project → Archive Project*).
