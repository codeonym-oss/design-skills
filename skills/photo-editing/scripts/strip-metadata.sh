#!/usr/bin/env bash
# Remove all metadata (GPS, camera serial, software) but keep orientation and color profile.
# Usage: strip-metadata.sh [--no-backup] photos...
set -euo pipefail
. "$(dirname "$(readlink -f "$0")")/../../../lib/env.sh"
backup=(); files=()
for a in "$@"; do [[ $a == --no-backup ]] && backup=(-overwrite_original) || files+=("$a"); done
((${#files[@]})) || { echo "usage: $0 [--no-backup] <photos...>" >&2; exit 2; }

echo "GPS before:"; exiftool -q -gps:all -s "${files[@]}" || true
exiftool -q -q -m "${backup[@]}" -all= -tagsfromfile @ -Orientation -ICC_Profile "${files[@]}"
echo "✔ stripped ${#files[@]} file(s)$([[ ${#backup[@]} -eq 0 ]] && echo ' (originals kept as *_original)')"
