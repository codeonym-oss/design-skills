#!/usr/bin/env bash
# Render one master image into common social / banner sizes.
# Usage: social-sizes.sh master.png [--fill|--fit] [--bg '#0d1117']
#   --fill (default) crops to cover the target; --fit letterboxes on --bg.
set -euo pipefail
. "$(dirname "$(readlink -f "$0")")/../../../lib/env.sh"
[[ $# -ge 1 && -f $1 ]] || { echo "usage: $0 <image> [--fill|--fit] [--bg COLOR]" >&2; exit 2; }

src=$1; shift
mode=fill; bg='#0d1117'
while (($#)); do
  case $1 in
    --fit) mode=fit ;;
    --fill) mode=fill ;;
    --bg) bg=$2; shift ;;
    *) echo "unknown option $1" >&2; exit 2 ;;
  esac
  shift
done

base=$(basename "${src%.*}")
out="$(dirname "$src")/export/social"
mkdir -p "$out"

# name WxH
sizes=(
  "instagram-square 1080x1080"
  "instagram-portrait 1080x1350"
  "story-reel 1080x1920"
  "linkedin-post 1200x1200"
  "linkedin-banner 1584x396"
  "x-post 1600x900"
  "x-header 1500x500"
  "youtube-thumbnail 1280x720"
  "youtube-banner 2560x1440"
  "og-image 1200x630"
  "github-social 1280x640"
)

for entry in "${sizes[@]}"; do
  name=${entry% *}; dim=${entry#* }
  dst="$out/${base}-${name}-${dim}.png"
  if [[ $mode == fill ]]; then
    magick "$src" -resize "${dim}^" -gravity center -extent "$dim" "$dst"
  else
    magick "$src" -resize "$dim" -background "$bg" -gravity center -extent "$dim" "$dst"
  fi
  echo "✔ $dst"
done
