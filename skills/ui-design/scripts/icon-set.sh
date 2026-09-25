#!/usr/bin/env bash
# Generate a complete web/app icon set from one square SVG.
# Usage: icon-set.sh icon.svg [outdir=icons] [--bg '#0d1117'] [--name 'App Name']
#   --bg is used for the maskable PWA icon and apple-touch-icon (no transparency there).
set -euo pipefail
. "$(dirname "$(readlink -f "$0")")/../../../lib/env.sh"
src=${1:-}; [[ -f $src ]] || { echo "usage: $0 <icon.svg> [outdir] [--bg COLOR] [--name NAME]" >&2; exit 2; }
shift
out=icons; bg='#ffffff'; name='App'
while (($#)); do
  case $1 in --bg) bg=$2; shift ;; --name) name=$2; shift ;; *) out=$1 ;; esac
  shift
done
mkdir -p "$out"
tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT

render() { inkscape "$src" --export-type=png --export-width="$1" --export-filename="$2" 2>/dev/null; }

# Transparent icons
for s in 16 32 48 64 128 192 256 512 1024; do render "$s" "$tmp/$s.png"; done
cp "$tmp/192.png" "$out/icon-192.png"
cp "$tmp/512.png" "$out/icon-512.png"
cp "$tmp/1024.png" "$out/icon-1024.png"
magick "$tmp/16.png" "$tmp/32.png" "$tmp/48.png" "$out/favicon.ico"
inkscape "$src" --export-plain-svg --export-filename="$out/favicon.svg" 2>/dev/null

# Opaque icons: apple-touch (180, 10% padding) and maskable (512, 20% safe-zone padding)
magick "$tmp/1024.png" -resize 144x144 -background "$bg" -gravity center -extent 180x180 -flatten "$out/apple-touch-icon.png"
magick "$tmp/1024.png" -resize 308x308 -background "$bg" -gravity center -extent 512x512 -flatten "$out/icon-maskable-512.png"

oxipng -q -o 3 --strip safe "$out"/*.png

cat >"$out/site.webmanifest" <<EOF
{
  "name": "$name",
  "short_name": "$name",
  "icons": [
    { "src": "/icon-192.png", "sizes": "192x192", "type": "image/png" },
    { "src": "/icon-512.png", "sizes": "512x512", "type": "image/png" },
    { "src": "/icon-maskable-512.png", "sizes": "512x512", "type": "image/png", "purpose": "maskable" }
  ],
  "theme_color": "$bg",
  "background_color": "$bg",
  "display": "standalone"
}
EOF

cat >"$out/head-snippet.html" <<'EOF'
<link rel="icon" href="/favicon.ico" sizes="48x48">
<link rel="icon" href="/favicon.svg" type="image/svg+xml">
<link rel="apple-touch-icon" href="/apple-touch-icon.png">
<link rel="manifest" href="/site.webmanifest">
EOF

echo "✔ icon set in $out/:"; ls -1 "$out" | sed 's/^/   /'
echo "Next.js app router: copy favicon.ico, icon-512.png (as icon.png) and apple-touch-icon.png (as apple-icon.png) into app/."
