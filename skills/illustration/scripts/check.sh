#!/usr/bin/env bash
# ds-image: full
# Check the illustration toolkit (Krita for painting, headless export).
. "$(dirname "$(readlink -f "$0")")/../../../lib/check.sh"

section "Krita"
tool krita "Krita" --version
tool magick "ImageMagick (canvas presets)"

section "Vectorizing line art"
tool inkscape "Inkscape"
tool potrace "potrace"

section "Drawing tablet (desktop only)"
if command -v libwacom-list-local-devices >/dev/null 2>&1; then
  tablets=$(libwacom-list-local-devices 2>/dev/null | sed -n 's/^ *name: *//p')
  if [[ -n $tablets ]]; then while read -r t; do info "detected tablet: $t"; done <<<"$tablets"
  else info "no drawing tablet detected (plug it in and rerun on your desktop)"; fi
else
  info "tablets are configured on your desktop, not in the container — see references/tablet-setup.md"
fi

summary
