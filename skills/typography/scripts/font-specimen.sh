#!/usr/bin/env bash
# Render a specimen sheet comparing font families.
# Usage: font-specimen.sh "Inter" "IBM Plex Serif" "JetBrains Mono" [-t "text"] [-o specimen.png]
# Uses Pango (via ImageMagick), so font collections (.ttc) and variable fonts resolve correctly.
set -euo pipefail
. "$(dirname "$(readlink -f "$0")")/../../../lib/env.sh"
text="Sphinx of black quartz, judge my vow"
out=specimen.png; fams=()
while (($#)); do
  case $1 in -t) text=$2; shift ;; -o) out=$2; shift ;; *) fams+=("$1") ;; esac
  shift
done
((${#fams[@]})) || { echo "usage: $0 \"Family\"... [-t text] [-o out.png]" >&2; exit 2; }

esc() { sed -e 's/&/\&amp;/g' -e 's/</\&lt;/g' -e 's/>/\&gt;/g' <<<"$1"; }

tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT
i=0
for fam in "${fams[@]}"; do
  matched=$(fc-match -f '%{family[0]}' "$fam")
  note=""
  if [[ ${matched,,} != "${fam,,}"* ]]; then
    echo "! '$fam' not installed — fontconfig substituted '$matched'" >&2
    note="  (not installed → shown in $matched)"
  fi
  f=$(esc "$fam"); t=$(esc "$text")
  # shellcheck disable=SC1111  # typographic quotes are sample glyphs
  markup="<span font='Inter Medium 15' foreground='#6b7280'>$f$(esc "$note")</span>
<span font='$f Bold 52' foreground='#111827'>Design Systems 2026</span>
<span font='$f 28' foreground='#111827'>$t</span>
<span font='$f 18' foreground='#374151'>ABCDEFGHIJKLMNOPQRSTUVWXYZ abcdefghijklmnopqrstuvwxyz</span>
<span font='$f Italic 18' foreground='#374151'>0123456789  (){}[] → ≠ ≤ ≥ ‘quotes’ “quotes” — éàçñ ffi fl</span>"
  # Markup inline, not pango:@file — many ImageMagick security policies forbid @file reads.
  magick -background white -define pango:wrap=none "pango:$markup" \
    -bordercolor white -border 40x28 -gravity northwest -extent 1400x \
    -fill '#e5e7eb' -draw 'rectangle 0,%[fx:h-1] 1400,%[fx:h]' \
    "$tmp/$(printf %02d $i).png"
  i=$((i + 1))
done
magick "$tmp"/[0-9]*.png -append "$out"
echo "✔ $out (${#fams[@]} families)"
