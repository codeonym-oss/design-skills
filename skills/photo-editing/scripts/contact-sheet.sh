#!/usr/bin/env bash
# Build a contact sheet (thumbnail grid with filenames).
# Usage: contact-sheet.sh photos... [-o sheet.jpg] [--cols 5]
set -euo pipefail
. "$(dirname "$(readlink -f "$0")")/../../../lib/env.sh"
out=contact-sheet.jpg; cols=5; files=()
while (($#)); do
  case $1 in -o) out=$2; shift ;; --cols) cols=$2; shift ;; *) files+=("$1") ;; esac
  shift
done
((${#files[@]})) || { echo "usage: $0 <photos...> [-o out.jpg] [--cols N]" >&2; exit 2; }

magick montage "${files[@]}" -auto-orient -thumbnail 400x400 -label '%t' \
  -tile "${cols}x" -geometry +8+8 -background '#111' -fill '#ddd' -pointsize 14 "$out"
echo "✔ $out (${#files[@]} photos)"
