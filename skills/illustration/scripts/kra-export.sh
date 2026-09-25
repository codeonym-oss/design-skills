#!/usr/bin/env bash
# ds-image: full
# Batch-export Krita files headlessly.
# Usage: kra-export.sh art1.kra art2.kra ... [png|jpg|webp]
set -euo pipefail
. "$(dirname "$(readlink -f "$0")")/../../../lib/env.sh"
fmt=png
files=()
for a in "$@"; do
  case $a in png|jpg|webp) fmt=$a ;; *) files+=("$a") ;; esac
done
((${#files[@]})) || { echo "usage: $0 <files.kra...> [png|jpg|webp]" >&2; exit 2; }

for f in "${files[@]}"; do
  [[ -f $f ]] || { echo "skip $f"; continue; }
  out="$(dirname "$f")/export"
  mkdir -p "$out"
  dst="$out/$(basename "${f%.*}").$fmt"
  krita "$f" --export --export-filename "$dst" >/dev/null 2>&1
  echo "✔ $dst"
done
