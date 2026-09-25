#!/usr/bin/env bash
# Shrink a PDF with Ghostscript.
# Usage: pdf-compress.sh in.pdf [screen|ebook|printer|prepress] [out.pdf]
#   screen 72 ppi (tiny) · ebook 150 ppi (email/web, default) · printer 300 ppi · prepress 300 ppi, keeps color profiles
set -euo pipefail
. "$(dirname "$(readlink -f "$0")")/../../../lib/env.sh"
in=${1:-}; [[ -f $in ]] || { echo "usage: $0 <in.pdf> [screen|ebook|printer|prepress] [out.pdf]" >&2; exit 2; }
level=${2:-ebook}; out=${3:-${in%.pdf}-$level.pdf}
case $level in screen|ebook|printer|prepress) ;; *) echo "bad level $level" >&2; exit 2 ;; esac

gs -q -dNOPAUSE -dBATCH -dSAFER -sDEVICE=pdfwrite -dCompatibilityLevel=1.7 \
   -dPDFSETTINGS=/"$level" -dDetectDuplicateImages=true -dSubsetFonts=true -dEmbedAllFonts=true \
   -sOutputFile="$out" "$in"

b=$(stat -c %s "$in"); a=$(stat -c %s "$out")
printf '✔ %s  %s → %s (%d%%)\n' "$out" "$(numfmt --to=iec "$b")" "$(numfmt --to=iec "$a")" $((a * 100 / b))
