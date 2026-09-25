#!/usr/bin/env bash
# Pull candidate thumbnail frames + a storyboard sheet from a video.
# Usage: thumbs.sh <input> [count=12]
set -euo pipefail
. "$(dirname "$(readlink -f "$0")")/../../../lib/env.sh"
in=${1:-}; [[ -f $in ]] || { echo "usage: $0 <video> [count]" >&2; exit 2; }
n=${2:-12}
out="${in%.*}-thumbs"; mkdir -p "$out"
dur=$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$in")

for i in $(seq 1 "$n"); do
  t=$(awk -v d="$dur" -v i="$i" -v n="$n" 'BEGIN{printf "%.2f", d*i/(n+1)}')
  ffmpeg -hide_banner -loglevel error -y -ss "$t" -i "$in" -frames:v 1 -q:v 2 "$out/$(printf %02d "$i")_${t}s.jpg"
done
magick montage "$out"/[0-9]*.jpg -thumbnail 480x -tile 4x -geometry +6+6 -background '#111' "$out/storyboard.jpg"
echo "✔ $n frames in $out/  ✔ $out/storyboard.jpg"
echo "  Pick one, then finish it as a YouTube thumbnail in GIMP (graphic-design → social-graphics.md)."
