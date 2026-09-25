#!/usr/bin/env bash
# Check the UI design toolkit (asset generation side; design apps run on your desktop/browser).
. "$(dirname "$(readlink -f "$0")")/../../../lib/check.sh"

section "Asset tools"
tool inkscape "Inkscape (icons, SVG → PNG)"
tool magick "ImageMagick (ico, padding)"
tool oxipng "oxipng"
tool python3 "python3 (palette generator)"

section "UI fonts"
for fam in "Inter" "IBM Plex Sans" "Roboto" "Source Sans 3" "JetBrains Mono"; do
  if fc-list ":family=$fam" family | grep -q .; then info "$fam"; else warn "$fam missing"; fi
done

section "Design apps (outside the container)"
info "Penpot — https://design.penpot.app (open source, self-hostable) · Figma — https://figma.com"
info "Lunacy (Windows/macOS/Linux desktop, opens .fig/.sketch) — https://icons8.com/lunacy"

summary
