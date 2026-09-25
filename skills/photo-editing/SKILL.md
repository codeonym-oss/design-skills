---
name: photo-editing
description: Photo development and retouching with darktable 5 (RAW/JPEG development, color grading, batch styles), GIMP 3.2 (retouching, compositing), ImageMagick and exiftool (metadata), with headless batch processing in a reproducible container. Use when the user wants to edit, color-grade, batch-process, resize for web, watermark, or strip location/metadata from photos, or wants a consistent look across a photo set (portfolio, product shots, headshots).
---

# Photo editing (darktable · GIMP · exiftool)

Scripts run inside the design-skills container automatically (`bash <skill-dir>/scripts/<name>.sh …`, see
`design-sandbox`). `batch-develop.sh` needs the **full** image; everything else runs in **core**.

## Toolkit

| Tool | Use it for | CLI (in the container) |
|---|---|---|
| **darktable 5** *(full image)* | Non-destructive RAW/JPEG development: exposure, color, grading, lens fixes, batch looks | desktop app · `darktable-cli in.raw [edits.xmp] out.jpg --style NAME` |
| **GIMP 3.2** *(full image)* | Pixel retouching: object removal, healing, compositing | desktop app |
| **exiftool** | Read/strip metadata (GPS!), rename by date | `exiftool` |
| **ImageMagick 7** | Resize, sharpen, watermark, contact sheets | `magick` |
| **AI upscaling** (optional, desktop) | 2×/4× upscaling of small or old photos | Upscayl (Windows/macOS/Linux) |

## Scripts

| Script | What it does |
|---|---|
| `check.sh` | Verifies darktable-cli, GIMP, exiftool, ImageMagick; lists `.dtstyle` files in the folder |
| `batch-develop.sh <style.dtstyle\|name\|-> <photos…>` | Headless darktable export, optionally applying a style, into `export/` (`FORMAT=jpg\|tif\|png\|webp`, `WIDTH=0`) |
| `web-ready.sh <photos…> [--max 2048] [--watermark "© You"] [--quality 85]` | Resize, light sharpen, strip metadata, optional watermark → `web/` |
| `strip-metadata.sh [--no-backup] <photos…>` | Removes GPS, camera serial, software tags; keeps orientation + color profile; backups as `*_original` |
| `contact-sheet.sh <photos…> [-o sheet.jpg] [--cols 5]` | One JPEG grid of thumbnails to review/share a set |

## Guides

- `references/darktable-workflow.md` — scene-referred workflow in darktable 5, module order, styles for consistent sets.
- `references/retouching.md` — GIMP retouch recipes (object removal, headshot cleanup, sky replacement).

## Rules of thumb

1. Develop in darktable first (global look), then GIMP only for local pixel fixes — round-trip via 16-bit TIFF.
2. Never edit originals: darktable keeps edits in `.xmp` sidecars (`batch-develop.sh` reuses them); exports go to `export/`.
3. Strip metadata before publishing anything online (`strip-metadata.sh` or `web-ready.sh`).
4. For a consistent set: grade one hero photo, save it as a style, *export* the `.dtstyle` next to the photos, apply to the rest with `batch-develop.sh look.dtstyle *.raw`.
