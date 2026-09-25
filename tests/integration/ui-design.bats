#!/usr/bin/env bats
load helpers

@test "ui-design: check passes" {
  run ds ui-design/check
  echo "$output"
  [ "$status" -eq 0 ]
}

@test "icon-set: favicons, touch + maskable icons, manifest, head snippet" {
  fixture_svg icon.svg
  run ds ui-design/icon-set icon.svg public --bg '#0d1117' --name 'Demo App'
  [ "$status" -eq 0 ]
  [ "$(magick identify public/favicon.ico | wc -l)" -eq 3 ]          # 16, 32, 48
  [ "$(dims public/apple-touch-icon.png)" = 180x180 ]
  [ "$(dims public/icon-maskable-512.png)" = 512x512 ]
  [ "$(magick identify -format '%[opaque]' public/icon-maskable-512.png)" = True ]
  python3 -c 'import json,sys; m=json.load(open(sys.argv[1])); assert m["name"]=="Demo App" and len(m["icons"])==3' public/site.webmanifest
  grep -q 'rel="manifest"' public/head-snippet.html
}

@test "palette: 11-step scale as CSS vars + Tailwind v4 theme + swatch PNG" {
  run ds ui-design/palette '#2563EB' brand tokens
  [ "$status" -eq 0 ]
  [ "$(grep -c -- '--brand-' tokens/brand-palette.css)" -eq 11 ]
  [ "$(grep -c -- '--color-brand-' tokens/brand-palette.css)" -eq 11 ]
  [ "$(dims tokens/brand-palette.png)" = 1320x120 ]
}

@test "palette: rejects a malformed color" {
  run ds ui-design/palette 'blue'
  [ "$status" -eq 2 ]
}
