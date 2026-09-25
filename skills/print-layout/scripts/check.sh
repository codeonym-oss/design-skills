#!/usr/bin/env bash
# Check the print-layout toolkit.
. "$(dirname "$(readlink -f "$0")")/../../../lib/check.sh"

section "Layout"
full_tool scribus "Scribus 1.6"

section "PDF tools"
tool gs "Ghostscript" --version
tool pdfinfo "pdfinfo (Poppler)"
tool pdffonts "pdffonts"
tool pdfimages "pdfimages"
tool pdftoppm "pdftoppm"
tool magick "ImageMagick (proof sheets)"

section "Color management"
icc_dirs=(/usr/share/color/icc "$HOME/.local/share/icc" "$HOME/Library/ColorSync/Profiles" ./icc)
n=$(find "${icc_dirs[@]}" -iname '*.ic[cm]' 2>/dev/null | wc -l | tr -d ' ')
info "$n ICC profile(s) found"
press=$(find "${icc_dirs[@]}" \( -iname '*fogra39*' -o -iname '*isocoated*' -o -iname '*swop*' -o -iname '*gracol*' \) -iname '*.ic[cm]' 2>/dev/null | head -3)
if [[ -n $press ]]; then while read -r p; do info "press profile: $p"; done <<<"$press"
else warn "no CMYK press profile (FOGRA39 / ISO Coated v2 / SWOP / GRACoL) — ask your printer, put it in ./icc"; fi

summary
