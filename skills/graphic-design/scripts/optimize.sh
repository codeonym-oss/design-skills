#!/usr/bin/env bash
# Optimize images for the web. Never overwrites the input:
# writes <name>.opt.<ext> plus <name>.webp and <name>.avif next to it.
# Usage: optimize.sh img1.png img2.jpg ...   [QUALITY=82]
set -euo pipefail
. "$(dirname "$(readlink -f "$0")")/../../../lib/env.sh"
[[ $# -ge 1 ]] || { echo "usage: $0 <images...>" >&2; exit 2; }
q=${QUALITY:-82}

size() { stat -c %s "$1"; }
human() { numfmt --to=iec --suffix=B "$1"; }

for f in "$@"; do
  [[ -f $f ]] || { echo "skip $f (not a file)"; continue; }
  ext=${f##*.}; ext=${ext,,}; stem=${f%.*}
  before=$(size "$f")
  case $ext in
    png)
      pngquant --quality=70-95 --skip-if-larger --force --output "$stem.opt.png" -- "$f" \
        || cp "$f" "$stem.opt.png"
      oxipng -q -o 4 --strip safe "$stem.opt.png"
      ;;
    jpg|jpeg)
      cp "$f" "$stem.opt.$ext"
      jpegoptim -q --strip-all --all-progressive -m"$q" "$stem.opt.$ext"
      ;;
    *) echo "skip $f (only png/jpg)"; continue ;;
  esac
  magick "$f" -quality "$q" "$stem.webp"
  avifenc -q "$q" -s 6 "$f" "$stem.avif" >/dev/null
  printf '✔ %s  %s → opt %s · webp %s · avif %s\n' "$f" "$(human "$before")" \
    "$(human "$(size "$stem.opt.$ext")")" "$(human "$(size "$stem.webp")")" "$(human "$(size "$stem.avif")")"
done
