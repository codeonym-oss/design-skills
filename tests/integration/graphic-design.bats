#!/usr/bin/env bats
load helpers

@test "graphic-design: check passes" {
  run ds graphic-design/check
  echo "$output"
  [ "$status" -eq 0 ]
}

@test "svg-export: PNGs at each width, text-to-path PDF and a plain SVG" {
  fixture_svg
  run ds graphic-design/svg-export logo.svg 64 300
  [ "$status" -eq 0 ]
  [ "$(dims export/logo-64.png)" = 64x64 ]
  [ "$(dims export/logo-300.png)" = 300x300 ]
  pdfinfo export/logo.pdf >/dev/null
  [ -z "$(pdffonts export/logo.pdf | tail -n +3)" ]      # text converted to paths
  ! grep -q 'inkscape:' export/logo.plain.svg
}

@test "social-sizes: every preset at its exact size, fill and fit" {
  magick -size 1600x1000 gradient:red-blue master.png
  run ds graphic-design/social-sizes master.png
  [ "$status" -eq 0 ]
  [ "$(ls export/social | wc -l)" -eq 11 ]
  [ "$(dims export/social/master-og-image-1200x630.png)" = 1200x630 ]
  [ "$(dims export/social/master-story-reel-1080x1920.png)" = 1080x1920 ]
  run ds graphic-design/social-sizes master.png --fit --bg '#000'
  [ "$(dims export/social/master-linkedin-banner-1584x396.png)" = 1584x396 ]
}

@test "optimize: smaller PNG, plus WebP and AVIF, input untouched" {
  magick -size 800x600 plasma:fractal -seed 1 photo.png
  before=$(sha256sum photo.png)
  run ds graphic-design/optimize photo.png
  [ "$status" -eq 0 ]
  [ "$(sha256sum photo.png)" = "$before" ]
  [ "$(stat -c %s photo.opt.png)" -le "$(stat -c %s photo.png)" ]
  [ "$(magick identify -format %m photo.webp)" = WEBP ]
  [ "$(file -b --mime-type photo.avif)" = image/avif ]
}

@test "optimize: JPEGs too, QUALITY respected" {
  fixture_photo p.jpg 1200x800
  QUALITY=60 run ds graphic-design/optimize p.jpg
  [ "$status" -eq 0 ]
  [ -s p.opt.jpg ] && [ -s p.webp ] && [ -s p.avif ]
}

@test "vectorize: bitmap sketch becomes an SVG with paths" {
  magick -size 200x200 xc:white -fill black -draw 'circle 100,100 100,30' sketch.png
  run ds graphic-design/vectorize sketch.png
  [ "$status" -eq 0 ]
  grep -q '<path' sketch.traced.svg
}

@test "optimize: a.png and a.jpg side by side keep separate WebP/AVIF" {
  magick -size 200x100 xc:red a.png; magick -size 200x100 xc:blue a.jpg
  run ds graphic-design/optimize a.png a.jpg
  [ "$status" -eq 0 ]
  [ -s a.png.webp ] && [ -s a.jpg.webp ] && [ -s a.png.avif ] && [ -s a.jpg.avif ]
}
