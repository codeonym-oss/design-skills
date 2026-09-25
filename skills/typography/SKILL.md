---
name: typography
description: Fonts and typography — a curated open-source font library (Inter, IBM Plex, Source Sans 3, Roboto, Open Sans, JetBrains Mono, Fira Code, Noto incl. Arabic/CJK/emoji, Liberation, DejaVu), project fonts, FontForge and fontconfig, all in a reproducible container. Use when the user wants to choose or pair fonts, see what fonts are available, add fonts to a project, compare fonts in a specimen, convert fonts to web formats (WOFF2 + @font-face), or edit/create a font.
---

# Typography (fonts · FontForge · fontconfig)

Scripts run inside the design-skills container automatically (`bash <skill-dir>/scripts/<name>.sh …`, see `design-sandbox`).

## Fonts available to every tool

| Role | Families |
|---|---|
| UI / product sans | **Inter**, **IBM Plex Sans**, Roboto, Open Sans, Source Sans 3 |
| Serif | **IBM Plex Serif**, Noto Serif, Liberation Serif, DejaVu Serif |
| Monospace / code | **JetBrains Mono**, Fira Code, IBM Plex Mono |
| Global coverage | Noto Sans/Serif (Latin, Greek, Cyrillic, **Arabic**, Hebrew, Devanagari, Thai…), Noto Color Emoji; Noto CJK in the full image |
| Metric-compatible | Liberation (Arial/Times/Courier), Carlito (Calibri) |

**Project fonts:** put `.ttf`/`.otf` files in `./fonts` (or point `DS_FONTS` at a folder) and every tool in the
container sees them — Inkscape exports, ImageMagick text, specimens, Scribus. Google Fonts: download the family
from fonts.google.com (or github.com/google/fonts) into `./fonts`.

## Tools

| Tool | Use it for | CLI (in the container) |
|---|---|---|
| **fontconfig** | List and match fonts | `fc-list`, `fc-match "Inter:bold"` |
| **FontForge** | Edit glyphs, create fonts, convert formats | `fontforge -lang=py -script …` |
| **woff2** | Compress to WOFF2 | `woff2_compress` |
| Desktop font managers | Browse/compare visually | GNOME Fonts / Font Manager (Linux), Font Book (macOS), Settings → Fonts (Windows) |

## Scripts

| Script | What it does |
|---|---|
| `check.sh` | Font tools, the key families, counts, and project fonts in `./fonts` |
| `font-inventory.sh [filter]` | Families with style counts and location |
| `font-specimen.sh "Family A" "Family B" … [-t "sample text"] [-o out.png]` | Side-by-side specimen PNG to compare/pair fonts; flags families that aren't installed; any script (Arabic, CJK…) via `-t` |
| `webfont.sh <font.ttf\|otf…> [outdir]` | WOFF2 + WOFF + an `@font-face` CSS file with the real family/weight/style |

## Guides

- `references/pairing-and-hierarchy.md` — proven pairings from the bundled set, type scale, readability rules.
- `references/installing-fonts.md` — project fonts, installing on Linux/macOS/Windows, licensing.

## Rules of thumb

1. Two families max per project (one sans + one serif **or** mono). Use weights for hierarchy.
2. Body text 16 px+ on screen, line-height 1.5, 60–75 characters per line.
3. Check the license before shipping a font (SIL OFL / Apache = free to embed and self-host).
4. For the web, self-host WOFF2 (`webfont.sh`) or use `next/font` — don't hotlink random font CDNs.
5. Designing for Arabic, Hebrew, CJK or Indic scripts? Check the specimen with real text (`-t`) — Latin-only fonts silently fall back.
