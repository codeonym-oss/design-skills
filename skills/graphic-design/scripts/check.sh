#!/usr/bin/env bash
# Check the graphic-design toolkit (vector, raster, tracing, web-image optimizers).
. "$(dirname "$(readlink -f "$0")")/../../../lib/check.sh"

section "Vector"
tool inkscape "Inkscape" --version
tool scour "scour (SVG optimizer)"
tool resvg "resvg (fast, exact SVG renderer)"
tool rsvg-convert "rsvg-convert"
tool potrace "potrace (bitmap → SVG)"

section "Raster"
tool magick "ImageMagick 7" --version
full_tool gimp "GIMP 3" --version
full_tool gmic "G'MIC (filters, CLI)"

section "Web formats & optimizers"
tool cwebp "cwebp (WebP)"
tool avifenc "avifenc (AVIF)"
tool cjxl "cjxl (JPEG XL)"
tool pngquant "pngquant (lossy PNG)"
tool oxipng "oxipng (lossless PNG)"
tool optipng "optipng"
tool jpegoptim "jpegoptim"

summary
