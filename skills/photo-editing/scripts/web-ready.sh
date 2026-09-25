#!/usr/bin/env bash
# Prepare photos for the web: resize, light sharpen, strip metadata, optional watermark.
# Usage: web-ready.sh photos... [--max 2048] [--watermark "© Your Name"] [--quality 85]
set -euo pipefail
. "$(dirname "$(readlink -f "$0")")/../../../lib/env.sh"
max=2048; wm=; q=85; files=()
while (($#)); do
  case $1 in
    --max) max=$2; shift ;;
    --watermark) wm=$2; shift ;;
    --quality) q=$2; shift ;;
    *) files+=("$1") ;;
  esac
  shift
done
((${#files[@]})) || { echo "usage: $0 <photos...> [--max N] [--watermark TEXT] [--quality Q]" >&2; exit 2; }

for f in "${files[@]}"; do
  [[ -f $f ]] || { echo "skip $f"; continue; }
  out="$(dirname "$f")/web"; mkdir -p "$out"
  dst="$out/$(basename "${f%.*}").jpg"

  cmd=(magick "$f" -auto-orient -resize "${max}x${max}>" -unsharp 0x0.75+0.6+0.008 -strip)
  if [[ -n $wm ]]; then
    h=$(magick "$f" -auto-orient -resize "${max}x${max}>" -format '%h' info:)
    pt=$((h / 40 > 18 ? h / 40 : 18))
    cmd+=(-gravity southeast -fill 'rgba(255,255,255,0.55)' -pointsize "$pt" -annotate +24+20 "$wm")
  fi
  cmd+=(-sampling-factor 4:2:0 -interlace JPEG -quality "$q" "$dst")

  "${cmd[@]}"
  echo "✔ $dst"
done
