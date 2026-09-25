#!/usr/bin/env bash
# Post-process an OBS recording: remux MKV→MP4 (no quality loss), normalize loudness,
# optionally trim the start/end, and make a small review copy.
# Usage: finish-recording.sh <recording.mkv|mp4> [--trim-start 3] [--trim-end 2] [--target -14] [--denoise]
set -euo pipefail
. "$(dirname "$(readlink -f "$0")")/../../../lib/env.sh"
in=${1:-}; [[ -f $in ]] || { sed -n '2,5p' "$0"; exit 2; }
shift
ts=0; te=0; target=-14; dn=()
while (($#)); do
  case $1 in
    --trim-start) ts=$2; shift ;;
    --trim-end) te=$2; shift ;;
    --target) target=$2; shift ;;
    --denoise) dn=(--denoise) ;;
    *) echo "unknown option $1" >&2; exit 2 ;;
  esac
  shift
done
video_skill="$(dirname "$(readlink -f "$0")")/../../video-editing/scripts"
stem=${in%.*}
dur=$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$in")
end=$(awk -v d="$dur" -v e="$te" 'BEGIN{printf "%.3f", d-e}')

# 1. Remux (+ trim on keyframes) into MP4 — instant, lossless.
ffmpeg -hide_banner -loglevel error -y -ss "$ts" -to "$end" -i "$in" -map 0 -c copy -movflags +faststart "$stem.remux.mp4"
echo "✔ remuxed → $stem.remux.mp4"

# 2. Loudness (video stream untouched).
bash "$video_skill/loudnorm.sh" "$stem.remux.mp4" --target "$target" "${dn[@]}" "$stem.final.mp4" | sed 's/^/  /'
rm -f "$stem.remux.mp4"

# 3. Small review copy for feedback.
bash "$video_skill/encode.sh" "$stem.final.mp4" preview "$stem.review.mp4" | tail -1
echo "Done: $stem.final.mp4 (master)  ·  $stem.review.mp4 (to share for feedback)"
