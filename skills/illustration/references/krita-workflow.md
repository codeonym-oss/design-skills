# Krita workflow: from sketch to finished illustration

## One-time setup
1. *Settings → Configure Krita → General → File Handling*: autosave every 5 min.
2. *Settings → Configure Krita → Canvas Input Settings*: keep defaults; learn Space (pan), Ctrl+Space (zoom), Shift+Space (rotate), `5` reset rotation, `M` mirror view.
3. *Settings → Workspace → Paint* for a clean layout. Add dockers: *Layers*, *Advanced Color Selector*, *Brush Presets*, *Reference Images*.
4. Brush packs: *Settings → Manage Resources → Import Bundle* (`.bundle` files). Good free starters: David Revoy's brush kit, Deevad's, and the built-in "Krita 5+" presets.

## Layer structure (top → bottom)
```
▸ FX            (glows, overlays — blending: Add / Screen / Overlay)
▸ Lighting      (Multiply for shadow, Add/Screen for light) — clipped to Flats
▸ Line art
▸ Flats         (one flat color per material, alpha-locked)
▸ Sketch        (opacity 30 %, hide when inking)
▸ Background
```
Clip shading layers to the flats with *Inherit Alpha* (the α icon on the layer).

## Stages
1. **Thumbnails** — 6–10 tiny compositions (canvas 1000 px, brush *Basic-5 Size*). Pick the strongest value pattern.
2. **Sketch** — enlarge the chosen thumbnail. Use *Assistant tool* (perspective/vanishing point) for backgrounds.
3. **Line art** — new layer, brush *Ink-2 Fineliner* or *Ink-7 Brush Rough*; stabilizer in *Tool Options → Brush Smoothing: Stabilizer*.
4. **Flats** — *Colorize Mask* (on the line-art layer: *Colorize Mask tool*) fills regions fast; or *Fill tool* with "Fill regions from a layer".
5. **Shading** — decide one light direction; Multiply layer for shadows in a cool purple-blue, Add layer for highlights.
6. **Finish** — *Filter → Adjust → Color Adjustment Curves*, a subtle *G'MIC → Details → Sharpen* and a texture overlay at 5–10 %.
7. **Export** — `bash <skill-dir>/scripts/kra-export.sh piece.kra png`, then optimize via the `graphic-design` skill.

## Speed shortcuts
| Key | Action |
|---|---|
| B / E | Brush / Eraser toggle |
| [ ] | Brush size |
| Ctrl (hold) | Color pick |
| Shift+drag | Resize brush on canvas |
| Ctrl+Shift+N | New layer |
| M | Mirror canvas (check proportions!) |
| Tab | Hide dockers — full canvas |

## Animation (optional)
*Settings → Workspace → Animation*. Timeline docker: right-click a frame → *Create Blank Frame*. Onion skin docker for previous/next frames. Export via *File → Render Animation* (uses ffmpeg). Then edit in the `video-editing` skill.
