#!/usr/bin/env bash
# Convert a PDF's colors to CMYK with Ghostscript (for printers that require CMYK-only files).
# Prefer asking your printer for their ICC profile and exporting CMYK straight from Scribus
# (File → Export → PDF → Color: Printer, PDF/X-4). Use this as a fallback.
# Usage: pdf-cmyk.sh in.pdf [out.pdf]
set -euo pipefail
. "$(dirname "$(readlink -f "$0")")/../../../lib/env.sh"
in=${1:-}; [[ -f $in ]] || { echo "usage: $0 <in.pdf> [out.pdf]" >&2; exit 2; }
out=${2:-${in%.pdf}-cmyk.pdf}

gs -q -dNOPAUSE -dBATCH -dSAFER -sDEVICE=pdfwrite -dCompatibilityLevel=1.7 \
   -sColorConversionStrategy=CMYK -sProcessColorModel=DeviceCMYK \
   -dOverrideICC=true -dPDFSETTINGS=/prepress \
   -sOutputFile="$out" "$in"

echo "✔ $out"
echo "  image color spaces now: $(pdfimages -list "$out" | awk 'NR>2 && $3=="image" {print $6}' | sort | uniq -c | awk '{printf "%s×%s ", $1, $2}')"
echo "  Check it visually: bash $(dirname "$0")/pdf-proof.sh '$out'"
