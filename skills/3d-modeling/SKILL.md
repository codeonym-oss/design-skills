---
name: 3d-modeling
description: 3D modeling, materials, lighting, rendering and animation with Blender 5 — headless renders (EEVEE and Cycles), product/packaging/poster mockups of 2D designs, turntables, glTF/GLB for the web (three.js / React Three Fiber, Draco), format conversion and STL for 3D printing — in a reproducible container. Use when the user wants to model something in 3D, make mockups of their designs, render stills or turntables, create 3D assets for the web, convert between 3D formats, prepare STL for printing, or script Blender with Python.
---

# 3D modeling (Blender 5)

Everything here needs the **full** image and runs in it automatically (`bash <skill-dir>/scripts/<name>.sh …`,
see `design-sandbox`). For hands-on modeling, use Blender on the desktop — the scripts work on the same `.blend` files.

## Toolkit

| Tool | Use it for | CLI (in the container) |
|---|---|---|
| **Blender 5** | Modeling, materials, lighting, rendering, animation, Python scripting | `scripts/blender.sh -b …` |
| **EEVEE** | Fast renders — mockups, previews, stylized work (software GL in the container) | engine `BLENDER_EEVEE` |
| **Cycles** | Photoreal renders on CPU in the container — use denoising + low samples | engine `CYCLES` |
| Bundled add-ons | glTF 2.0 (with **Draco**), FBX, OBJ/STL/PLY, Node Wrangler, Rigify | `check.sh` lists them |
| **ffmpeg** | Frames → MP4 | used by `render.sh --anim` |

## Scripts

| Script | What it does |
|---|---|
| `check.sh` | Blender version, Cycles devices, engines, add-ons (glTF!) |
| `blender.sh [args]` | Blender in the design environment — use instead of `blender` |
| `render.sh scene.blend [--engine eevee\|cycles] [--samples N] [--res WxH] [--frame N \| --anim] [--out dir]` | Headless still or animation; animations are encoded to MP4 automatically |
| `mockup.py` | A 2D design (poster, cover, card, screenshot) as a lit 3D studio mockup: `blender.sh -b --factory-startup -P <skill-dir>/scripts/mockup.py -- --image design.png --out mockup.png [--style tilt\|flat\|lean] [--bg '#f4f4f5'] [--res 1920x1080] [--save mockup.blend]` |
| `turntable.py` | 360° turntable of any model (glb/gltf/obj/fbx/stl/ply/blend): `blender.sh -b --factory-startup -P <skill-dir>/scripts/turntable.py -- --model chair.glb --save chair-tt.blend`, then `render.sh chair-tt.blend --anim` |
| `convert-model.sh in.X out.Y [--draco]` | Converts between blend/glb/gltf/obj/fbx/stl/ply; `--draco` shrinks GLB for the web |

## Guides

- `references/blender-essentials.md` — navigation, modeling toolkit, modifiers, shortcuts that matter.
- `references/materials-lighting-render.md` — Principled BSDF, studio/HDRI lighting, EEVEE vs Cycles settings.
- `references/project-recipes.md` — product mockup, low-poly scene, logo in 3D, web asset for React Three Fiber, 3D print prep.

## Rules of thumb

1. Real-world scale (1 unit = 1 m); apply scale (Ctrl+A → Scale) before modifiers/export.
2. Keep modifiers live (Subdivision, Bevel, Mirror, Solidify) until export — non-destructive.
3. Preview small (`--res 640x360 --samples 8`), final big. Use Cycles only for true glass/caustics/GI; 64–256 samples + denoising.
4. Animations render as PNG frames (crash-safe), then MP4 (`render.sh --anim` does both).
5. Web: GLB + Draco, textures ≤ 2K, < 50k triangles per hero model.
6. Always look at a rendered still before committing to a long animation render.
