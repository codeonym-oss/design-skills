# GIMP 3.2 essentials

## Non-destructive by default
GIMP 3 has **non-destructive filters**: filters applied from the *Filters* menu stay editable in the layer's *Fx* column. Click the Fx icon in the Layers dock to toggle, reorder or re-edit them. Keep it that way until final export.

- Use **layer masks** (right-click layer → *Add Layer Mask*) instead of erasing.
- Use **layer groups** to organize (Shift+Ctrl+N creates a new layer; *Layer → New Layer Group*).
- Save work as `.xcf`; *File → Export As* (Shift+Ctrl+E) for PNG/JPEG/WebP/AVIF.

## Most-used tools
| Task | Tool / shortcut |
|---|---|
| Cut out a subject | *Foreground Select* (in Free Select group), or *Paths* (B) for hard edges |
| Remove an object | Select it loosely → *Filters → Enhance → Heal selection* (Resynthesizer) |
| Spot fix | Heal tool (H), Clone (C) |
| Color correct | *Colors → Curves*, *Colors → Levels*, *Colors → Hue-Saturation* |
| Sharpen for web | *Filters → Enhance → Sharpen (Unsharp Mask)*, radius 0.5–1, amount 0.5 |
| Text | Text tool (T); text layers stay editable in `.xcf` |
| Perspective mockup | *Unified Transform* (Shift+T) or *Perspective* (Shift+P) to place a design on a screen/poster photo |

## G'MIC-Qt
*Filters → G'MIC-Qt*. Useful starting points:
- *Repair → Smooth [Bilateral]* — clean noise while keeping edges.
- *Details → Sharpen [Richardson-Lucy]* — strong but clean sharpening.
- *Artistic → Cartoon / Engrave / Pencil portrait* — stylized looks.
- *Colors → Color Presets* — hundreds of film-like LUTs.
Use the preview split-view (top of the dialog) to compare.

## Export settings
| Format | Settings |
|---|---|
| PNG | compression 9, uncheck *Save color profile* for web if colors look right, then `optimize.sh` |
| JPEG | quality 85–90, *Progressive*, subsampling 4:2:0 for photos |
| WebP | quality 80–85 |
| AVIF | quality 70–80 — smallest files, check banding in gradients |

## Batch from the terminal
GIMP runs headless for scripting:
```bash
gimp-console-3.2 -i --batch-interpreter=python-fu-eval -b 'print("hello from GIMP")' --quit
```
For simple batch resizes/conversions prefer ImageMagick (`magick in.png -resize 50% out.png`); use GIMP batch only when you need G'MIC or GIMP-specific filters.
