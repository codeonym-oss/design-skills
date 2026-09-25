#!/usr/bin/env bash
# ds-image: full
# Headless darktable export, optionally applying a saved style.
# Usage: batch-develop.sh <style.dtstyle|style-name|-> photo1.raf photo2.jpg ...
#   style: a .dtstyle file (export it from darktable: lighttable → styles → export),
#          the name of a style in ~/.config/darktable/styles, or '-' for none.
# Env: FORMAT=jpg|tif|png|webp (default jpg), WIDTH=0 (0 = full size)
set -euo pipefail
. "$(dirname "$(readlink -f "$0")")/../../../lib/env.sh"
[[ $# -ge 2 ]] || { echo "usage: $0 <style.dtstyle|style-name|-> <photos...>" >&2; exit 2; }

style=$1; shift
fmt=${FORMAT:-jpg}; width=${WIDTH:-0}

# Separate config dir so a running darktable GUI doesn't lock the library.
cfg=$(mktemp -d)
trap 'rm -rf "$cfg"' EXIT
style_name=
if [[ $style != - ]]; then
  if [[ -f $style ]]; then src_style=$style
  else src_style="$HOME/.config/darktable/styles/$style.dtstyle"; fi
  [[ -f $src_style ]] || { echo "style not found: $style (give a .dtstyle file path)" >&2; exit 1; }
  mkdir -p "$cfg/styles"; cp "$src_style" "$cfg/styles/"
  # darktable applies styles by the name stored inside the file.
  style_name=$(sed -n 's:.*<name>\(.*\)</name>.*:\1:p' "$src_style" | head -1)
  style_name=${style_name:-$(basename "$src_style" .dtstyle)}
fi

fails=0
for f in "$@"; do
  [[ -f $f ]] || { echo "skip $f"; continue; }
  out="$(dirname "$f")/export"
  mkdir -p "$out"
  dst="$out/$(basename "${f%.*}").$fmt"
  args=("$f")
  [[ -f $f.xmp ]] && args+=("$f.xmp")     # reuse edits already made in the GUI
  args+=("$dst" --width "$width" --height 0 --hq true --upscale false)
  [[ -n $style_name ]] && args+=(--style "$style_name")
  if darktable-cli "${args[@]}" --core --configdir "$cfg" --library :memory: >/dev/null 2>&1 && [[ -f $dst ]]; then
    echo "✔ $dst"
  else
    echo "✘ $f failed"; fails=$((fails + 1))
  fi
done
((fails == 0))
