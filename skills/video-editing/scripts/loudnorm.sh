#!/usr/bin/env bash
# Normalize loudness (two-pass EBU R128), optionally denoise, video stream copied untouched.
# Usage: loudnorm.sh <input> [--target -14] [--denoise] [output]
#   targets: -14 LUFS YouTube/social · -16 podcasts/voice · -23 broadcast
set -euo pipefail
. "$(dirname "$(readlink -f "$0")")/../../../lib/env.sh"
in=${1:-}; [[ -f $in ]] || { sed -n '2,5p' "$0"; exit 2; }
shift
target=-14; denoise=0; out=
while (($#)); do
  case $1 in --target) target=$2; shift ;; --denoise) denoise=1 ;; *) out=$1 ;; esac
  shift
done
ext=${in##*.}; [[ -n $out ]] || out="${in%.*}-norm.$ext"

pre="highpass=f=80"
((denoise)) && pre="$pre,afftdn=nf=-25"

# Pass 1: measure
stats=$(ffmpeg -hide_banner -nostats -i "$in" -af "$pre,loudnorm=I=$target:TP=-1.5:LRA=11:print_format=json" -f null - 2>&1 |
        sed -n '/^{/,/^}/p')
get() { grep "\"$1\"" <<<"$stats" | sed -E 's/.*: "([^"]+)".*/\1/'; }
echo "measured: $(get input_i) LUFS, true peak $(get input_tp) dBTP → target $target LUFS"

# Pass 2: apply with measured values (linear mode = no pumping)
ffmpeg -hide_banner -loglevel error -y -i "$in" -map 0 -c:v copy \
  -af "$pre,loudnorm=I=$target:TP=-1.5:LRA=11:measured_I=$(get input_i):measured_TP=$(get input_tp):measured_LRA=$(get input_lra):measured_thresh=$(get input_thresh):offset=$(get target_offset):linear=true" \
  -c:a aac -b:a 256k -ar 48000 "$out"
echo "✔ $out"
