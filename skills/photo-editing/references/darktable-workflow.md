# darktable 5.6 workflow

darktable has two main views: **lighttable** (organize, rate, export — key `L`) and **darkroom** (edit one photo — key `D`).

## Import
*lighttable → import → add to library*. Tick *Copy* only for memory cards; otherwise just reference the folder. Rate with keys `1`–`5`, reject with `R`, then filter the collection to ★★★ and above.

## Scene-referred editing order (the default in darktable 5)
Work top-down in this order; each module is found with the search box at the top of the module panel.

| Step | Module | What to do |
|---|---|---|
| 1 | **exposure** | Set mid-tones right. Use the *compensate camera exposure* default, then drag. |
| 2 | **color calibration** | White balance: pick a neutral area with the eyedropper (CAT tab). |
| 3 | **filmic rgb** or **sigmoid** | Tone mapping: sigmoid is simpler — adjust *contrast* and *skew*. |
| 4 | **tone equalizer** | Lift shadows / hold highlights locally (masking tab: auto-align). |
| 5 | **color balance rgb** | The look: *basic → vibrance, chroma, saturation*; *4 ways* for split-toning. Presets like *basic colorfulness: vibrant colors* are good starts. |
| 6 | **lens correction** | Auto-detected from EXIF. |
| 7 | **denoise (profiled)** | For high ISO. |
| 8 | **diffuse or sharpen** | Preset *sharpen demosaicing* or *local contrast: fine*. |
| 9 | **crop** / **rotate and perspective** | Straighten horizons (right-click-drag along a line). |

Masks: almost every module has a *blend → drawn & parametric mask* option for local edits (e.g. brighten a face with an ellipse mask + feather).

## Consistent sets with styles
1. Edit one hero photo fully.
2. *lighttable → history stack → compress history*.
3. *lighttable → styles → create* — tick only the look modules (color balance rgb, sigmoid, etc.), not crop/exposure. Name it e.g. `portfolio`, then *export* it as `portfolio.dtstyle` next to your photos.
4. Apply to others in the GUI (select → click the style), or headless:
   ```bash
   bash <skill-dir>/scripts/batch-develop.sh portfolio.dtstyle shoot/*.jpg
   ```
5. Fine-tune exposure per photo afterwards.

## Export
*lighttable → export*: JPEG quality 90 for delivery, 16-bit TIFF for handing to GIMP, long edge 2048 px for web (then `web-ready.sh` for metadata stripping/watermark).

## Round-trip to GIMP
Export TIFF 16-bit → retouch in GIMP → save `.xcf` → export JPEG. Keep darktable for global color, GIMP for pixel surgery.
