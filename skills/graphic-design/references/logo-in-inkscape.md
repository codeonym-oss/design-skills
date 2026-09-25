# Designing a logo in Inkscape 1.4

## 1. Brief (before opening any tool)
Write down: name, what the brand does, 3 adjectives (e.g. *precise, calm, technical*), where it will appear (favicon 16 px → billboard), and 2–3 reference logos you like and why.

## 2. Sketch
20+ thumbnails on paper or in Krita (`illustration` skill). Pick 3. A logo that doesn't work as a 1-color silhouette at 32 px won't be saved by color.

## 3. Set up the document
- `inkscape` → *File → Document Properties* (Ctrl+Shift+D): units **px**, size **1024 × 1024**, *Display → checkerboard* on.
- Grid: *Document Properties → Grids → Rectangular*, spacing 8 px. Toggle snapping with `%`.
- Guides: drag from the rulers; add a centered guide pair for symmetry.

## 4. Build the mark
| Task | How |
|---|---|
| Geometric construction | Circles/rects (`E`, `R`) then *Path → Union / Difference / Intersection* (Ctrl++, Ctrl+-, Ctrl+*) |
| Custom curves | Bezier tool (`B`), then node tool (`N`); keep nodes few and at extrema |
| Symmetry | *Path Effects* (Ctrl+&) → **Mirror Symmetry** — edit one half, the other follows |
| Even strokes | Design with strokes, then *Path → Stroke to Path* (Ctrl+Alt+C) before final export |
| Align | Ctrl+Shift+A — align to *Page* or *Last selected* |

## 5. Wordmark
- Try 5–10 typefaces from the bundled set (Inter, IBM Plex, Source Sans 3, Roboto, Fira) or your own in `./fonts` via the `typography` skill's `font-specimen.sh`.
- Tune letter-spacing and kerning with the text tool: Alt+← / Alt+→ between letters.
- Convert to paths (*Path → Object to Path*, Shift+Ctrl+C) once final, then adjust letter shapes if needed.

## 6. Color
- Start in black only. Add color last.
- Define 1 primary + 1 dark + 1 light. Pick them with `eyedropper` or build in *Fill & Stroke* (Ctrl+Shift+F) using HSL.
- Check contrast of the logo on both light and dark backgrounds.

## 7. Variants to produce
`logo-full` (mark + wordmark, horizontal), `logo-stacked`, `mark` alone, `wordmark` alone — each in color, black, white. Put each variant on its own page (*Document Properties → Pages*, Inkscape 1.4 multi-page) so one file holds the whole kit.

## 8. Export the brand kit
```bash
bash <skill-dir>/scripts/svg-export.sh brand/logo-full.svg 256 512 1024 2048
bash <skill-dir>/scripts/optimize.sh brand/export/*.png
```
Favicons and app icons: `ui-design` skill → `icon-set.sh`.

## Checklist
- [ ] Recognizable at 16 px and in one color
- [ ] No stray nodes or unjoined paths (*Edit → Select All*, check node count in status bar)
- [ ] Text converted to paths in delivery files
- [ ] Master `.svg` kept with live text in a `source/` folder
