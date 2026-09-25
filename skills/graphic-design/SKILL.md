---
name: graphic-design
description: Raster and vector graphic design with Inkscape 1.4, ImageMagick 7, GIMP 3.2 (+ G'MIC), potrace, scour/resvg and the web-image optimizers (pngquant, oxipng, jpegoptim, cwebp, avifenc, cjxl), all running headlessly in a reproducible container. Use when the user wants to make or edit a logo, banner, social-media post, thumbnail, poster graphic or icon, or wants to batch-export, resize, convert, vectorize or compress images. Also use when they ask which graphic tool to use for a job.
---

# Graphic design (Inkscape · ImageMagick · GIMP)

Scripts run inside the design-skills container automatically — run them with
`bash <skill-dir>/scripts/<name>.sh …` from the folder that holds the files (see the `design-sandbox` skill).

## Toolkit

| Tool | Use it for | CLI (in the container) |
|---|---|---|
| **Inkscape 1.4** | Vector: logos, icons, banners, anything that must scale | `inkscape file.svg --export-type=png --export-width=1024` |
| **ImageMagick 7** | Scripted resize, crop, compose, convert, text | `magick` |
| **GIMP 3.2** *(full image)* | Raster compositing, retouching, textures | desktop app for hands-on work; `gimp-console` for batch |
| **G'MIC** *(full image)* | 500+ filters: stylize, denoise, sharpen, artistic looks | `gmic in.png -fx_… -o out.png` |
| **potrace** | Bitmap → SVG tracing (logos from scans) | `potrace` |
| **scour · resvg** | Optimize SVG markup · render SVG exactly and fast | `scour -i in.svg -o out.svg` · `resvg in.svg out.png` |
| **Optimizers** | Shrink exports for the web | `pngquant`, `oxipng`, `jpegoptim`, `cwebp`, `avifenc`, `cjxl` |

Fonts live in the `typography` skill (drop project fonts in `./fonts`); UI assets in `ui-design`; print PDFs in `print-layout`.

## Pick the right tool

- Must scale, or has few flat colors (logo, icon, badge, diagram) → **Inkscape / SVG**; keep the source as SVG.
- Built from photos, textures, painting or effects → **GIMP** (`.xcf` source) on the desktop, or ImageMagick when scriptable.
- Hand-drawn look or painting → the `illustration` skill (Krita).
- The same edit on many files → **ImageMagick / the scripts below**, never by hand.
- Writing SVG directly is often the fastest path for an agent: write the SVG, render it with `svg-export.sh`, look at the PNG, iterate.

## Scripts

| Script | What it does |
|---|---|
| `check.sh` | Verifies the toolkit; prints install commands for anything missing |
| `svg-export.sh <file.svg> [widths…]` | PNGs at several widths (default 512 1024 2048) + text-to-path PDF + plain SVG → `export/` |
| `social-sizes.sh <image> [--fill\|--fit] [--bg COLOR]` | One master image into 11 social/banner sizes → `export/social/` |
| `optimize.sh <images…>` | `*.opt.png/jpg` + WebP + AVIF next to each input, never overwrites (`QUALITY=82`) |
| `vectorize.sh <bitmap> [threshold%]` | Traces a black-and-white bitmap (scan, sketch logo) into `*.traced.svg` |

## Guides

- `references/logo-in-inkscape.md` — logo from concept to exported brand kit.
- `references/social-graphics.md` — templates, safe zones and the size table used by `social-sizes.sh`.
- `references/gimp-essentials.md` — GIMP 3 non-destructive workflow, G'MIC, export settings.

## Rules of thumb

1. Keep an editable master (`.svg` / `.xcf`) next to every export; exports go in `export/`.
2. Design at the largest size you need and export down — never scale raster up (AI upscalers exist, e.g. Upscayl, but they invent detail).
3. Web: PNG only for flat graphics/transparency, otherwise WebP/AVIF with a JPEG fallback. Always run `optimize.sh`.
4. sRGB for screens. CMYK/print is handled in `print-layout`.
5. Before delivering, look at the export at 100 % and at the real display size — read the PNG back and check it.
