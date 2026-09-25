#!/usr/bin/env bash
# ds-image: full
# Render a Kdenlive project headlessly with MLT's melt (no GUI needed).
# Usage: render-project.sh project.kdenlive [out.mp4] [--crf 20]
# Tip: for the exact render profile you picked in Kdenlive, use the Render dialog's
#      "Generate Script" button instead; this is the quick, sensible-defaults path.
set -euo pipefail
. "$(dirname "$(readlink -f "$0")")/../../../lib/env.sh"
proj=${1:-}; [[ -f $proj ]] || { sed -n '3,6p' "$0"; exit 2; }
out=${2:-${proj%.kdenlive}.mp4}; crf=20
[[ ${3:-} == --crf ]] && crf=${4:-20}

start=$(date +%s)
melt -quiet "$proj" -consumer "avformat:$out" \
  vcodec=libx264 crf="$crf" preset=medium pix_fmt=yuv420p movflags=+faststart \
  acodec=aac ab=256k ar=48000 real_time=-"$(nproc)" 2>&1 | grep -viE 'deprecated|^$' || true
[[ -f $out ]] || { echo "✘ render failed" >&2; exit 1; }
echo "✔ $out ($(numfmt --to=iec --suffix=B "$(stat -c %s "$out")")) in $(( $(date +%s) - start ))s"
