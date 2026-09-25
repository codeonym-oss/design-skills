#!/usr/bin/env bash
# List installed font families with style counts.
# Usage: font-inventory.sh [filter]   e.g. font-inventory.sh mono
set -euo pipefail
. "$(dirname "$(readlink -f "$0")")/../../../lib/env.sh"
filter=${1:-}

fc-list --format '%{family[0]}\t%{style[0]}\t%{file}\n' |
  { if [[ -n $filter ]]; then grep -i -- "$filter"; else cat; fi; } |
  awk -F'\t' '
    { fam=$1; n[fam]++; dir=$3; sub(/\/[^\/]*$/, "", dir); d[fam]=dir }
    END { for (f in n) printf "%-38s %3d styles  %s\n", f, n[f], d[f] }' |
  sort -f
