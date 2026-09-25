---
name: print-layout
description: Print and multi-page layout with Scribus 1.6 (flyers, posters, brochures, business cards, CVs, magazines), plus Ghostscript and Poppler for PDF preflight, compression, CMYK conversion and proofs — headless in a reproducible container that ships FOGRA/ISO Coated press profiles. Use when the user wants something printed or a print-quality PDF — bleed, crop marks, CMYK, PDF/X, paper sizes — or wants to check, shrink or proof a PDF before sending it to a printer or client.
---

# Print layout (Scribus · Ghostscript · Poppler)

Scripts run inside the design-skills container automatically (`bash <skill-dir>/scripts/<name>.sh …`, see
`design-sandbox`). `new-print-doc.sh` needs the **full** image (Scribus, run under a virtual display); the PDF tools run in **core**.

## Toolkit

| Tool | Use it for | CLI (in the container) |
|---|---|---|
| **Scribus 1.6** *(full image)* | Page layout with bleed, CMYK colors, master pages, PDF/X export | desktop app · scripted via `new-print-doc.sh` |
| **Inkscape / GIMP** | Artwork (vector / raster) that Scribus places | `graphic-design` skill |
| **Ghostscript 10** | Compress PDFs, convert to CMYK | `gs` |
| **Poppler** | Inspect PDFs: boxes, fonts, image resolution; render proofs | `pdfinfo -box`, `pdffonts`, `pdfimages -list`, `pdftoppm` |
| **ICC profiles** | FOGRA27/29/39/…, ISO Coated v2 (colord / icc-profiles-free) | `/usr/share/color/icc` in the image; your printer's own in `./icc` |

## Scripts

| Script | What it does |
|---|---|
| `check.sh` | Verifies Scribus, Ghostscript, Poppler, and that a CMYK press profile is available |
| `new-print-doc.sh <preset> <name> [--pages N] [--title T] [--font F] [--brand '#hex'] [--proof]` | Scribus `.sla` with the right size, bleed, margins, CMYK brand color and placeholder frames; `--proof` exports a PDF with crop marks. Presets: `a4 a5 a3 letter business-card dl-flyer square-210 poster-50x70` |
| `pdf-preflight.sh <file.pdf> [--min-dpi 300]` | Trim/bleed boxes, embedded fonts, image ppi, color spaces — exits non-zero on problems |
| `pdf-proof.sh <file.pdf> [dpi]` | Pages to PNG + one overview sheet, to review or send to a client |
| `pdf-compress.sh <in.pdf> [screen\|ebook\|printer\|prepress]` | Shrinks PDFs (ebook ≈ email-friendly) |
| `pdf-cmyk.sh <in.pdf>` | Fallback conversion of all colors to CMYK |
| `scribus_new_doc.py` | The Scribus Python script `new-print-doc.sh` drives — a starting point for your own scripted layouts (`scribus -g -ns -py`) |

## Guide

- `references/print-workflow.md` — brief to printer: sizes, bleed, safe zone, color, images, fonts, Scribus export settings, what to send.

## Rules of thumb

1. **Bleed 3 mm** on every side (US printers often want 0.125 in ≈ 3.2 mm); backgrounds extend to the bleed edge; text ≥ 5 mm inside the trim.
2. **Images ≥ 300 ppi** at placed size; vector art (Inkscape PDF/SVG) for logos.
3. **Fonts embedded** or outlined. **Rich black** (C60 M40 Y40 K100) for large dark areas, 100 % K for small text.
4. **CMYK is duller than RGB** — the `--brand` hex is converted naively; confirm CMYK values with the printer's profile or a swatch book, and show the client a proof.
5. Always run `pdf-preflight.sh` before sending, and ask the printer for their specs and ICC profile.
