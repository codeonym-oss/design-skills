---
name: illustration
description: Digital painting and illustration with Krita 6 — concept art, character/scene illustration, hand-drawn icons and textures, logo sketches, comics and storyboards — plus headless Krita canvas creation and batch export in a reproducible container. Use when the user wants to draw or paint, set up brushes or a drawing tablet, build a Krita canvas/template, animate frame-by-frame, or batch-export .kra files.
---

# Illustration (Krita)

Painting happens in Krita on the desktop (any OS). The scripts — canvas presets and batch export — run headlessly
in the design-skills **full** image automatically (`bash <skill-dir>/scripts/<name>.sh …`; see `design-sandbox`).

## Toolkit

| Tool | Use it for | Where |
|---|---|---|
| **Krita 6** | Painting, sketching, inking, comics, 2D frame animation | desktop app · headless `krita in.kra --export --export-filename out.png` *(full image)* |
| **G'MIC** | Filters, colorize line art, artistic looks | Krita → *Filter → Start G'MIC-Qt* (desktop plugin) · `gmic` CLI *(full image)* |
| **Inkscape + potrace** | Turning finished line art into clean vectors | `graphic-design/vectorize.sh` |
| **Tablet driver** | Pressure, mapping, buttons | your OS — see `references/tablet-setup.md` |

## Scripts

| Script | What it does |
|---|---|
| `check.sh` | Verifies Krita and the vectorizing tools; lists tablets when run on a Linux desktop |
| `new-canvas.sh <preset> <name> [bg]` | Ready-to-paint `.kra` from a preset: `a4-300`, `square-4k`, `wallpaper-4k`, `thumbnail`, `comic-page`; never overwrites |
| `kra-export.sh <file.kra…> [png\|jpg\|webp]` | Batch-exports Krita files headlessly into `export/` |

## Guides

- `references/krita-workflow.md` — setup, brushes, layer structure, sketch → line → flats → shading → finish.
- `references/tablet-setup.md` — pressure curves and button mapping on Linux (GNOME/KDE), Windows and macOS.

## Quick defaults

- Canvas: work at 2× the final size; 300 DPI for print; sRGB (`sRGB-elle-V2-srgbtrc`) for screen.
- Save `.kra` often; set autosave to 5 min (*Settings → Configure Krita → General → File Handling*).
- Keep reference images in the *Reference Images* tool, not on canvas layers.
- Export for web via `kra-export.sh`, then `graphic-design/optimize.sh`.
