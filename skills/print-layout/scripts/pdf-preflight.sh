#!/usr/bin/env bash
# Preflight a PDF before sending it to print.
# Checks: page count & size, trim/bleed boxes, font embedding, image resolution, color spaces.
# Usage: pdf-preflight.sh file.pdf [--min-dpi 300]
set -euo pipefail
. "$(dirname "$(readlink -f "$0")")/../../../lib/env.sh"
pdf=${1:-}; [[ -f $pdf ]] || { echo "usage: $0 <file.pdf> [--min-dpi N]" >&2; exit 2; }
min_dpi=300; [[ ${2:-} == --min-dpi ]] && min_dpi=${3:-300}
problems=0
if [[ -t 1 ]]; then G=$'\e[32m' R=$'\e[31m' N=$'\e[0m'; else G='' R='' N=''; fi
ok()  { printf '  %s✔%s %s\n' "$G" "$N" "$*"; }
bad() { printf '  %s✘%s %s\n' "$R" "$N" "$*"; problems=$((problems + 1)); }
note(){ printf '  • %s\n' "$*"; }
pt2mm() { awk -v p="$1" 'BEGIN{printf "%.1f", p/72*25.4}'; }

echo "== Pages & boxes"
info=$(pdfinfo -box "$pdf")
note "$(grep -E '^Pages:' <<<"$info" | tr -s ' ')"
read -r _ mx0 my0 mx1 my1 < <(grep -E '^MediaBox:' <<<"$info")
note "MediaBox $(pt2mm "$(awk -v a="$mx1" -v b="$mx0" 'BEGIN{print a-b}')") × $(pt2mm "$(awk -v a="$my1" -v b="$my0" 'BEGIN{print a-b}')") mm"
if read -r _ tx0 ty0 tx1 ty1 < <(grep -E '^TrimBox:' <<<"$info") && [[ $tx0 != "$mx0" || $tx1 != "$mx1" ]]; then
  ok "TrimBox $(pt2mm "$(awk -v a="$tx1" -v b="$tx0" 'BEGIN{print a-b}')") × $(pt2mm "$(awk -v a="$ty1" -v b="$ty0" 'BEGIN{print a-b}')") mm (final trimmed size)"
  read -r _ bx0 _ _ _ < <(grep -E '^BleedBox:' <<<"$info")
  b=$(pt2mm "$(awk -v a="$tx0" -v b="$bx0" 'BEGIN{print a-b}')")
  if awk -v b="$b" 'BEGIN{exit !(b>=2.9)}'; then ok "bleed ${b} mm"; else bad "bleed only ${b} mm (printers usually want 3 mm)"; fi
else
  bad "no TrimBox/bleed — export from Scribus with 'Use document bleeds' and crop marks"
fi

echo "== Fonts"
fonts=$(pdffonts "$pdf" | tail -n +3)
if [[ -z $fonts ]]; then
  note "no fonts (all text outlined or no text)"
elif awk '{ if ($(NF-4) != "yes") exit 1 }' <<<"$fonts"; then
  ok "all $(wc -l <<<"$fonts") font(s) embedded"
else
  bad "fonts not embedded:"; awk '$(NF-4) != "yes" {print "      " $1}' <<<"$fonts"
fi

echo "== Images (minimum ${min_dpi} ppi)"
imgs=$(pdfimages -list "$pdf" | tail -n +3)
if [[ -z $imgs ]]; then
  note "no raster images"
else
  low=$(awk -v m="$min_dpi" '$3=="image" && ($13+0 < m || $14+0 < m) {printf "      page %s: %sx%s px at %s ppi (%s)\n", $1, $4, $5, $13, $6}' <<<"$imgs")
  n=$(awk '$3=="image"' <<<"$imgs" | wc -l)
  if [[ -n $low ]]; then bad "low-resolution images:"; echo "$low"; else ok "$n image(s) ≥ ${min_dpi} ppi"; fi
  spaces=$(awk '$3=="image" {print $6}' <<<"$imgs" | sort | uniq -c | awk '{printf "%s×%s ", $1, $2}')
  note "image color spaces: $spaces"
  grep -qw rgb <<<"$(awk '$3=="image" {print $6}' <<<"$imgs")" && note "RGB images present — fine for digital print; for offset use pdf-cmyk.sh or ask the printer"
fi

echo
((problems == 0)) && echo "Preflight passed." || { echo "$problems problem(s) found."; exit 1; }
