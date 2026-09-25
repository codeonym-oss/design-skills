# Retouching recipes (GIMP 3.2)

## Remove an object / person / power line
1. *Free Select* (F) loosely around the object, with ~10 px margin.
2. *Filters → Enhance → Heal selection* (Resynthesizer). Context sampling width 50, *Random* order.
3. Fix leftovers with the Heal tool (H): Ctrl+click a clean source, paint over.

## Headshot cleanup (natural)
1. Duplicate the layer, name it `retouch`.
2. Heal tool (H), small brush, hardness 50 %: blemishes only — keep freckles and texture.
3. Skin smoothing (subtle): duplicate again → *G'MIC-Qt → Repair → Smooth [Bilateral]* spatial 10, value 7 → add a **black** layer mask → paint white at 30 % opacity only on skin (not eyes, lips, hair, edges).
4. Eyes: *Dodge/Burn* tool (Shift+D), dodge the iris at 10 % exposure.
5. Keep the result believable: set the `retouch` layer opacity to 70–80 %.

## Replace a sky
1. *Select → By Color* (Shift+O) on the sky, *Select → Grow* 2 px, *Select → Feather* 3 px.
2. Paste the new sky as a new layer (*Edit → Paste as → New Layer*), move it under the original, add a layer mask to the original from the inverted selection.
3. Match colors: on the foreground, *Colors → Color Balance* toward the sky's tint; add a 10 % overlay of the sky color on top.

## Product shot on a clean background
1. *Foreground Select* the product → *Select → Feather* 1 px → *Edit → Copy* → *Paste as New Image*.
2. New layer below: fill `#f4f4f5` or a soft radial gradient (Gradient tool, shape Radial).
3. Contact shadow: new layer, black soft brush under the product, opacity 30 %, *Filters → Blur → Gaussian* 20 px.
4. Batch many products? Do the cutouts in GIMP, then lay out consistently with ImageMagick:
   ```bash
   magick product.png -trim -resize 1600x1600 -background '#f4f4f5' -gravity center -extent 2000x2000 out.jpg
   ```

## Upscale an old or tiny photo
Open **Upscayl** → choose model *Real-ESRGAN* (photos) or *Ultrasharp* (graphics) → 4× → then downscale to the size you need in GIMP. Upscayl uses the GPU through Vulkan; on integrated graphics large images take a while.
