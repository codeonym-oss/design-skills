#!/usr/bin/env bash
# High-quality GIF (and a WebM alternative) from a video clip — for READMEs, docs, social.
# Usage: gif.sh <input> [--start 00:00:05] [--dur 4] [--width 800] [--fps 15]
set -euo pipefail
. "$(dirname "$(readlink -f "$0")")/../../../lib/env.sh"
in=${1:-}; [[ -f $in ]] || { sed -n '2,3p' "$0"; exit 2; }
shift
start=0; dur=; width=800; fps=15
while (($#)); do
  case $1 in --start) start=$2; shift ;; --dur) dur=$2; shift ;; --width) width=$2; shift ;; --fps) fps=$2; shift ;; esac
  shift
done
stem=${in%.*}
cut=(-ss "$start"); [[ -n $dur ]] && cut+=(-t "$dur")
f="fps=$fps,scale=$width:-1:flags=lanczos"

ffmpeg -hide_banner -loglevel error -y "${cut[@]}" -i "$in" \
  -vf "$f,split[a][b];[a]palettegen=stats_mode=diff[p];[b][p]paletteuse=dither=bayer:bayer_scale=4:diff_mode=rectangle" \
  "$stem.gif"
# WebM is 5–10× smaller than GIF and plays in <video autoplay loop muted> and GitHub READMEs.
ffmpeg -hide_banner -loglevel error -y "${cut[@]}" -i "$in" -an -vf "$f" -c:v libvpx-vp9 -crf 36 -b:v 0 "$stem.webm"
echo "✔ $stem.gif ($(numfmt --to=iec --suffix=B "$(stat -c %s "$stem.gif")"))  ✔ $stem.webm ($(numfmt --to=iec --suffix=B "$(stat -c %s "$stem.webm")"))"
