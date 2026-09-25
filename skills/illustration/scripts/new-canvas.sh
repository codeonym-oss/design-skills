#!/usr/bin/env bash
# ds-image: full
# Create a blank Krita document from a preset.
# Usage: new-canvas.sh <preset> <name> [background-color]
#   presets: a4-300 · square-4k · wallpaper-4k · thumbnail · comic-page
set -euo pipefail
. "$(dirname "$(readlink -f "$0")")/../../../lib/env.sh"
preset=${1:-}; name=${2:-}; bg=${3:-white}

case $preset in
  a4-300)       dim=2480x3508 ;;   # A4 portrait at 300 DPI
  square-4k)    dim=4096x4096 ;;
  wallpaper-4k) dim=3840x2160 ;;
  thumbnail)    dim=2560x1440 ;;   # 2x YouTube thumbnail
  comic-page)   dim=3300x5100 ;;   # US comic page at 300 DPI (11x17 in art board)
  *) echo "usage: $0 {a4-300|square-4k|wallpaper-4k|thumbnail|comic-page} <name> [bg]" >&2; exit 2 ;;
esac
[[ -n $name ]] || { echo "missing <name>" >&2; exit 2; }

out="${name%.kra}.kra"
[[ -e $out ]] && { echo "$out already exists — not overwriting" >&2; exit 1; }

tmp=$(mktemp --suffix=.png)
trap 'rm -f "$tmp"' EXIT
magick -size "$dim" "xc:$bg" -density 300 -units PixelsPerInch "$tmp"
# Krita converts on export; this gives a real .kra with one background layer.
krita "$tmp" --export --export-filename "$out" >/dev/null 2>&1
echo "✔ $out ($dim, bg $bg) — open with: krita '$out'"
