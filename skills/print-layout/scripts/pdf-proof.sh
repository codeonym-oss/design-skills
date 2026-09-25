#!/usr/bin/env bash
# Render PDF pages to PNG proofs (and a single overview sheet) for review.
# Usage: pdf-proof.sh file.pdf [dpi=100]
set -euo pipefail
. "$(dirname "$(readlink -f "$0")")/../../../lib/env.sh"
pdf=${1:-}; [[ -f $pdf ]] || { echo "usage: $0 <file.pdf> [dpi]" >&2; exit 2; }
dpi=${2:-100}
out="${pdf%.pdf}-proof"; mkdir -p "$out"

pdftoppm -r "$dpi" -png "$pdf" "$out/page"
n=$(ls "$out"/page*.png | wc -l)
magick montage "$out"/page*.png -tile "$(( n < 4 ? n : 4 ))x" -geometry +12+12 -background '#d4d4d8' -shadow "$out/overview.png"
echo "✔ $n page(s) in $out/  ✔ $out/overview.png"
