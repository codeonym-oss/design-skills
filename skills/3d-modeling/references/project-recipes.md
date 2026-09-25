# Project recipes

## 1. Design mockup in 60 seconds (poster, book cover, card, app screenshot)
```bash
bash <skill-dir>/scripts/blender.sh -b --factory-startup -P <skill-dir>/scripts/mockup.py -- \
  --image cover.png --out cover-mockup.png --style tilt --bg '#f4f4f5' --save cover-mockup.blend
```
Then open `cover-mockup.blend` to tweak the camera/lights and re-render (F12). For a phone/laptop mockup: model the device (below) and put the screenshot on the screen face as an Emission material.

## 2. Simple device (phone) model
1. Add Cube → scale to 0.075 × 0.008 × 0.155 (m), apply scale.
2. Bevel modifier: width 0.01, segments 8 (rounded corners) → Ctrl+Shift+B on vertical edges for extra roundness.
3. Screen: select the front face → I (inset) 0.003 → separate as its own material with the screenshot as emission.
4. Materials: body brushed aluminium / glossy plastic, screen emissive, add a glass coat.
5. Light with the studio setup, camera 85 mm lens, render EEVEE.

## 3. 3D logo
1. Export the logo from Inkscape as **plain SVG**, paths only (`graphic-design` → `svg-export.sh`).
2. Blender: *File → Import → SVG* → select curves → Object Data → *Extrude* 0.02, *Bevel* depth 0.003, resolution 4.
3. Convert to mesh (right-click → Convert → Mesh) if you need modifiers; add a metallic or glossy material.
4. Turntable: `turntable.py --model logo.blend`, render with `render.sh --anim` → MP4 for social/intro videos.

## 4. Low-poly scene
Icosphere (subdivisions 1–2) rocks, Cone trees, a Grid plane with *Displace* modifier (Clouds texture) for terrain → flat shading (right-click → Shade Flat) → simple palette materials (use `ui-design` → `<skill-dir>/scripts/palette.sh` colors) → Sun + Sky → EEVEE with Bloom-like glare in the compositor.

## 5. Web 3D asset (Next.js + React Three Fiber)
1. Model under ~50k triangles; bake/limit textures to 1–2K; apply transforms; origin at the bottom center.
2. Export:
   ```bash
   bash <skill-dir>/scripts/convert-model.sh hero.blend public/models/hero.glb --draco
   ```
3. In the app:
   ```bash
   pnpm add three @react-three/fiber @react-three/drei
   npx gltfjsx public/models/hero.glb --types   # generates a typed React component
   ```
   `useGLTF` from drei loads Draco automatically.

## 6. 3D-print prep (STL)
1. Scale in millimeters (*Scene → Units → Unit Scale 0.001, Length mm*).
2. Enable the bundled **3D-Print Toolbox** extension (Preferences → Get Extensions) → *Check All*: non-manifold edges, thin walls (≥ 1.2 mm for FDM), overhangs.
3. Apply all modifiers, then `bash <skill-dir>/scripts/convert-model.sh part.blend part.stl`.

## 7. Portfolio turntable of any downloaded model
```bash
bash <skill-dir>/scripts/blender.sh -b --factory-startup -P <skill-dir>/scripts/turntable.py -- --model model.glb --frames 180 --res 1920x1080 --save model-tt.blend
bash <skill-dir>/scripts/render.sh model-tt.blend --anim --out renders
```
