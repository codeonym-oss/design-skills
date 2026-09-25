#!/usr/bin/env bash
# Trace a black-and-white bitmap (scanned sketch, low-res logo) into an SVG.
# Usage: vectorize.sh sketch.png [threshold%=50]
set -euo pipefail
. "$(dirname "$(readlink -f "$0")")/../../../lib/env.sh"
[[ $# -ge 1 && -f $1 ]] || { echo "usage: $0 <bitmap> [threshold%]" >&2; exit 2; }

src=$1; th=${2:-50}
stem=${src%.*}
tmp=$(mktemp --suffix=.pbm)
trap 'rm -f "$tmp"' EXIT

# Upscale small inputs first: potrace traces much smoother curves from more pixels.
magick "$src" -colorspace Gray -resize '2000x2000<' -threshold "${th}%" "$tmp"
potrace "$tmp" --svg --turdsize 4 --alphamax 1.0 --opttolerance 0.2 -o "$stem.traced.svg"
echo "✔ $stem.traced.svg  (open in Inkscape to recolor: Edit → Select Same → Fill Color)"
