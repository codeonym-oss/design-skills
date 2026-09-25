#!/usr/bin/env bash
# Check font tools and the bundled font families.
. "$(dirname "$(readlink -f "$0")")/../../../lib/check.sh"

section "Font tools"
tool fc-list "fontconfig (fc-list / fc-match)"
tool fontforge "FontForge (edit, convert)"
tool woff2_compress "woff2_compress"
tool magick "ImageMagick (specimens)"

section "Font families"
for fam in "Inter" "IBM Plex Sans" "IBM Plex Serif" "IBM Plex Mono" "Source Sans 3" "Roboto" "Open Sans"            "JetBrains Mono" "Fira Code" "Noto Sans" "Noto Serif" "Noto Sans Arabic" "Noto Color Emoji"            "Liberation Sans" "DejaVu Sans"; do
  if fc-list ":family=$fam" family | grep -q .; then info "$fam"; else warn "$fam not installed"; fi
done
if fc-list ":lang=ja" family | grep -q .; then info "CJK coverage (Noto Sans CJK)"; else info "no CJK fonts (the full image ships Noto CJK)"; fi

section "Library"
info "$(fc-list : family | sort -u | wc -l | tr -d ' ') families, $(fc-list | wc -l | tr -d ' ') font files"
[[ -d ./fonts ]] && info "project fonts in ./fonts: $(find ./fonts -type f \( -iname '*.ttf' -o -iname '*.otf' -o -iname '*.ttc' \) | wc -l | tr -d ' ') file(s) — visible to every tool"

summary
