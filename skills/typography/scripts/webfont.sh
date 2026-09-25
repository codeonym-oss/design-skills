#!/usr/bin/env bash
# Convert TTF/OTF fonts to WOFF2 + WOFF and write @font-face CSS.
# Usage: webfont.sh MyFont-Regular.ttf MyFont-Bold.ttf ... [outdir=webfonts]
# Check the font license allows web embedding first (OFL/Apache: yes).
set -euo pipefail
. "$(dirname "$(readlink -f "$0")")/../../../lib/env.sh"
out=webfonts; files=()
for a in "$@"; do
  case ${a,,} in
    *.ttf|*.otf) [[ -f $a ]] || { echo "font not found: $a" >&2; exit 2; }; files+=("$a") ;;
    *) out=$a ;;
  esac
done
((${#files[@]})) || { echo "usage: $0 <fonts.ttf|otf...> [outdir]" >&2; exit 2; }
mkdir -p "$out"
css="$out/fonts.css"; : >"$css"

for f in "${files[@]}"; do
  stem=$(basename "${f%.*}")
  fontforge -quiet -lang=py -c '
import fontforge, sys
f = fontforge.open(sys.argv[1])
f.generate(sys.argv[2] + ".woff2")
f.generate(sys.argv[2] + ".woff")
print("\t".join([f.familyname, str(f.os2_weight), "italic" if f.italicangle else "normal"]))
' "$f" "$out/$stem" 2>/dev/null >"$out/.meta"
  IFS=$'\t' read -r family weight style <"$out/.meta"
  cat >>"$css" <<EOF
@font-face {
  font-family: "$family";
  src: url("./$stem.woff2") format("woff2"), url("./$stem.woff") format("woff");
  font-weight: $weight;
  font-style: $style;
  font-display: swap;
}
EOF
  printf '✔ %-32s %s %s → %s.woff2 (%s)\n' "$family" "$weight" "$style" "$stem" \
    "$(numfmt --to=iec --suffix=B "$(stat -c %s "$out/$stem.woff2")")"
done
rm -f "$out/.meta"
echo "✔ $css"
