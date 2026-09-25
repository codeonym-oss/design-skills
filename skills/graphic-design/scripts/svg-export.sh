#!/usr/bin/env bash
# Export an SVG to PNGs at several widths plus a vector PDF.
# Usage: svg-export.sh logo.svg [512 1024 2048]
set -euo pipefail
. "$(dirname "$(readlink -f "$0")")/../../../lib/env.sh"
[[ $# -ge 1 && -f $1 ]] || { echo "usage: $0 <file.svg> [widths...]" >&2; exit 2; }

src=$1; shift
widths=("${@:-}")
[[ -z ${widths[0]} ]] && widths=(512 1024 2048)

base=$(basename "${src%.*}")
out="$(dirname "$src")/export"
mkdir -p "$out"

for w in "${widths[@]}"; do
  inkscape "$src" --export-type=png --export-width="$w" \
    --export-filename="$out/${base}-${w}.png" 2>/dev/null
  echo "✔ $out/${base}-${w}.png"
done

inkscape "$src" --export-type=pdf --export-text-to-path \
  --export-filename="$out/${base}.pdf" 2>/dev/null
echo "✔ $out/${base}.pdf (text converted to paths)"

# Plain SVG: strips Inkscape metadata, safe for the web.
inkscape "$src" --export-plain-svg --export-text-to-path \
  --export-filename="$out/${base}.plain.svg" 2>/dev/null
echo "✔ $out/${base}.plain.svg"
