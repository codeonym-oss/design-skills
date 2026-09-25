---
name: design-doctor
description: Health check and map of the whole design toolkit (graphic design, illustration, photo, UI, typography, print, Blender 3D, video editing, screen recording) and its container images. Use when the user asks what design tools are available, whether everything works, which tool or skill fits a creative task, why a design tool misbehaves, or wants to know what to install or pull.
---

# Design doctor

## Run it
```bash
bash <skill-dir>/scripts/doctor.sh            # one-screen summary
bash <skill-dir>/scripts/doctor.sh --verbose  # every check in detail, with install commands
```
It reports the runtime (Docker / Podman / native), which images are pulled, then runs every skill's check script in the
right place. It never pulls an image by itself — checks whose image is missing say `skipped — ds pull core|full`.
In native mode it also flags **PATH shadowing** (e.g. Homebrew tools hiding the distro's ffmpeg/perl/python3).

## Which skill for which job

| I want to… | Skill | Main tools | Image |
|---|---|---|---|
| Logo, banner, social post, thumbnail, icon; batch resize/convert/compress images | `graphic-design` | Inkscape, ImageMagick, optimizers (GIMP, G'MIC) | core |
| Draw, paint, concept art, comics; Krita canvases and batch export | `illustration` | Krita | full |
| Develop / grade / batch photos, strip GPS, web-ready photos | `photo-editing` | darktable, exiftool, ImageMagick | core (+full for darktable) |
| Mockups, design system tokens, favicons & app icons, color palettes | `ui-design` | Penpot/Figma/Lunacy, Inkscape | core |
| Choose/pair fonts, specimens, project fonts, web fonts | `typography` | fontconfig, FontForge, woff2 | core |
| Flyer, poster, brochure, business card, print-ready PDF, preflight | `print-layout` | Scribus, Ghostscript, Poppler | core (+full for Scribus) |
| 3D models, design mockups, renders, turntables, GLB for the web, 3D print | `3d-modeling` | Blender | full |
| Edit/encode videos, loudness, GIFs, thumbnails, render Kdenlive projects | `video-editing` | ffmpeg, melt | core (+full for melt) |
| Record tutorials/demos, OBS setup, keystrokes, zoom effects | `screen-recording` | OBS (desktop), ffmpeg | host + core |
| Set up / understand / troubleshoot the container itself | `design-sandbox` | `ds`, Docker/Podman | — |

## Cross-skill pipelines
- **Brand kit**: `typography` (pick fonts) → `ui-design/palette.sh` (colors) → `graphic-design` (logo SVG, `graphic-design/svg-export.sh`) → `ui-design/icon-set.sh` (favicons) → `print-layout` (business card) → `3d-modeling/mockup.py` (presentation shots).
- **Tutorial video**: `screen-recording` (record, `screen-recording/finish-recording.sh`) → `video-editing` (edit, `video-editing/encode.sh`) → `video-editing/thumbs.sh` + `graphic-design` (thumbnail) → `video-editing/gif.sh` (README loop).
- **Portfolio piece**: `3d-modeling/turntable.py` or `3d-modeling/mockup.py` → `3d-modeling/render.sh --anim` → `video-editing/encode.sh web` → `graphic-design/optimize.sh` for stills.
