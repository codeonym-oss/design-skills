#!/usr/bin/env bash
# Check the photo-editing toolkit.
. "$(dirname "$(readlink -f "$0")")/../../../lib/check.sh"

section "Development & retouching"
full_tool darktable-cli "darktable-cli (headless RAW/JPEG)"
full_tool gimp "GIMP 3"

section "Utilities"
tool exiftool "exiftool (metadata)"
tool magick "ImageMagick 7"
if command -v exiftool >/dev/null && ! exiftool -ver >/dev/null 2>&1; then
  warn "exiftool is on PATH but fails to run — often a second perl earlier on PATH (e.g. Homebrew's)"
fi

section "darktable styles"
if compgen -G "*.dtstyle" >/dev/null; then
  for s in *.dtstyle; do info "style in this folder: $s"; done
else
  info "no .dtstyle here — export one from darktable (lighttable → styles → export) to batch-apply a look"
fi

summary
