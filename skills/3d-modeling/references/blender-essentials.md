# Blender 5.2 essentials

## Navigation (no numpad? enable *Preferences → Input → Emulate Numpad*)
| Action | Keys |
|---|---|
| Orbit / pan / zoom | Middle-drag / Shift+middle-drag / wheel |
| Frame selected | Numpad `.` (or View → Frame Selected) |
| Front / right / top view | Numpad 1 / 3 / 7 (Ctrl for opposite) |
| Camera view | Numpad 0 · Lock camera to view: N panel → View → *Camera to View* |
| Pie menus | `~` views · `Z` shading · `Shift+S` snap |
| Search any command | F3 |

## Object ↔ Edit mode
Tab toggles. In Edit mode: `1` vertex, `2` edge, `3` face select.

| Tool | Key | Notes |
|---|---|---|
| Grab / Rotate / Scale | G / R / S | then X/Y/Z to constrain, type a number for exact values |
| Extrude | E | faces or edges |
| Inset | I | faces |
| Loop cut | Ctrl+R | scroll for more cuts |
| Bevel | Ctrl+B | scroll for segments; Ctrl+Shift+B vertex bevel |
| Knife | K | |
| Merge by distance | M → By Distance | clean up duplicate vertices |
| Fill face | F | |
| Select linked | L (hover) / Ctrl+L | |
| Proportional editing | O | soft deformations |
| Apply transforms | Ctrl+A | always apply Scale before modifiers/export |
| Origin | Right-click → Set Origin | |
| Join / separate | Ctrl+J / P | |

## Modifier stack (Properties → wrench)
Order matters, top → bottom:
1. **Mirror** — model half, symmetry for free (enable *Clipping*).
2. **Solidify** — thickness for shells (screens, bottles, cloth).
3. **Bevel** — *Limit Method: Angle*, width 1–3 mm, segments 3 → catches light on edges (the #1 realism trick).
4. **Subdivision Surface** — level 2 render, 1 viewport; add support loops (Ctrl+R) near edges to keep them crisp.
5. **Weighted Normal** — clean shading on hard-surface models (turn on *Auto Smooth* / Shade Auto Smooth first).

## Hard-surface workflow
Blockout with primitives (Shift+A) → Boolean cutters (*Object → Boolean* modifier, cutter displayed as wire) → Bevel modifier → Weighted Normal → apply only when exporting.

## Organic / sculpting
Low-poly base in Edit mode → Sculpt mode (Ctrl+Tab pie) → *Remesh* voxel size 0.01–0.02 → brushes Draw (X), Clay Strips, Smooth (Shift), Grab (G), Crease. Dyntopo for adding detail where you paint.

## Geometry Nodes (procedural)
Workspace *Geometry Nodes* → *New*. Starters: *Distribute Points on Faces → Instance on Points* for scattering (rocks, grass, bolts); *Array/Curve to Mesh* for cables and pipes.

## Files & organization
- Collections (M to move) for `Model`, `Lights`, `Camera`, `Cutters`.
- *File → External Data → Pack Resources* before sharing a `.blend`.
- Incremental saves: Ctrl+Alt+S (file_v001 → v002).
