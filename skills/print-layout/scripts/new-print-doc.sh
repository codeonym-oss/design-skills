#!/usr/bin/env bash
# ds-image: full
# Create a print-ready Scribus template with bleed, margins, CMYK brand colors and placeholder frames.
# Usage: new-print-doc.sh <preset> <name> [--pages N] [--title "Text"] [--font "IBM Plex Sans"] [--brand "#2563EB"] [--proof]
#   presets: a4 · a5 · a3 · letter · business-card · dl-flyer · square-210 · poster-50x70
#   --proof also exports <name>-proof.pdf with crop marks and bleed.
set -euo pipefail
. "$(dirname "$(readlink -f "$0")")/../../../lib/env.sh"
preset=${1:-}; name=${2:-}
[[ -n $preset && -n $name ]] || { sed -n '3,7p' "$0"; exit 2; }
shift 2
pages=1; title="Headline goes here"; font=""; brand="#2563EB"; proof=0
while (($#)); do
  case $1 in
    --pages) pages=$2; shift ;;
    --title) title=$2; shift ;;
    --font) font=$2; shift ;;
    --brand) brand=$2; shift ;;
    --proof) proof=1 ;;
    *) echo "unknown option $1" >&2; exit 2 ;;
  esac
  shift
done

bleed=3; margin=12
case $preset in
  a4) w=210; h=297 ;;
  a5) w=148; h=210 ;;
  a3) w=297; h=420 ;;
  letter) w=215.9; h=279.4 ;;
  business-card) w=85; h=55; margin=4 ;;
  dl-flyer) w=99; h=210; margin=8 ;;
  square-210) w=210; h=210 ;;
  poster-50x70) w=500; h=700; bleed=5; margin=25 ;;
  *) echo "unknown preset '$preset'" >&2; exit 2 ;;
esac

sla="$(readlink -f .)/${name%.sla}.sla"
[[ -e $sla ]] && { echo "$sla exists — not overwriting" >&2; exit 1; }
pdf=""; ((proof)) && pdf="${sla%.sla}-proof.pdf"

# Scribus needs a display even with -g; without one, give it a virtual X server.
run=(scribus -g -ns -py "$(dirname "$(readlink -f "$0")")/scribus_new_doc.py")
if [[ -z ${DISPLAY:-} && -z ${WAYLAND_DISPLAY:-} ]] && command -v xvfb-run >/dev/null; then
  run=(env QT_QPA_PLATFORM=xcb xvfb-run -a "${run[@]}")
fi
DOC_W=$w DOC_H=$h DOC_PAGES=$pages DOC_BLEED=$bleed DOC_MARGIN=$margin \
DOC_OUT=$sla DOC_PDF=$pdf DOC_TITLE=$title DOC_FONT=$font DOC_BRAND=$brand \
  timeout 180 "${run[@]}" >/dev/null 2>&1 || true

[[ -f $sla ]] || { echo "✘ Scribus did not create $sla" >&2; exit 1; }
echo "✔ $sla  (${w}×${h} mm, ${bleed} mm bleed, ${margin} mm margins, $pages page(s))"
[[ -n $pdf && -f $pdf ]] && echo "✔ $pdf (proof with crop marks)"
echo "Open with: scribus '$sla'"
