#!/usr/bin/env bash
# Encode a video for a destination (software x264/x265, or VAAPI hardware encoding when a GPU is available).
# Usage: encode.sh <input> <preset> [output] [--sw]
#   presets:
#     web       1080p max, H.264, faststart — portfolio, landing pages, sharing
#     youtube   source resolution, H.264 high quality, AAC 320k
#     vertical  1080×1920 (Reels/Shorts/TikTok): blurred background fill, video centered
#     square    1080×1080 (LinkedIn/Instagram feed), blurred fill
#     archive   source resolution, HEVC high quality — smaller master copies
#     preview   720p, small file for review/feedback
#   --sw forces software x264/x265 (slower, slightly better quality per MB).
set -euo pipefail
. "$(dirname "$(readlink -f "$0")")/../../../lib/env.sh"
in=${1:-}; preset=${2:-}
[[ -f $in && -n $preset ]] || { sed -n '2,12p' "$0"; exit 2; }
out=${3:-}; sw=0
[[ ${3:-} == --sw ]] && { out=; sw=1; }
[[ ${4:-} == --sw ]] && sw=1
[[ -n $out ]] || out="${in%.*}-$preset.mp4"

dev=/dev/dri/renderD128
hw=0
if ((!sw)) && [[ -e $dev ]] && [[ $(ffmpeg -hide_banner -encoders 2>/dev/null) == *h264_vaapi* ]]; then hw=1; fi

codec=h264; quality=20; audio=(-c:a aac -b:a 192k -ar 48000)
case $preset in
  web)      vf="scale='min(1920,iw)':-2"; quality=23 ;;
  youtube)  vf="null"; quality=18; audio=(-c:a aac -b:a 320k -ar 48000) ;;
  vertical) fc="[0:v]split[a][b];[a]scale=1080:1920:force_original_aspect_ratio=increase,crop=1080:1920,boxblur=30:5,eq=brightness=-0.08[bg];[b]scale=1080:1920:force_original_aspect_ratio=decrease[fg];[bg][fg]overlay=(W-w)/2:(H-h)/2" ;;
  square)   fc="[0:v]split[a][b];[a]scale=1080:1080:force_original_aspect_ratio=increase,crop=1080:1080,boxblur=30:5,eq=brightness=-0.08[bg];[b]scale=1080:1080:force_original_aspect_ratio=decrease[fg];[bg][fg]overlay=(W-w)/2:(H-h)/2" ;;
  archive)  vf="null"; codec=hevc; quality=20 ;;
  preview)  vf="scale='min(1280,iw)':-2"; quality=28; audio=(-c:a aac -b:a 96k -ar 48000) ;;
  *) echo "unknown preset $preset" >&2; exit 2 ;;
esac

if ((hw)); then
  venc=(-c:v "${codec}_vaapi" -rc_mode CQP -qp "$quality")
  tail_filter="format=nv12,hwupload"
  pre=(-vaapi_device "$dev")
else
  if [[ $codec == hevc ]]; then venc=(-c:v libx265 -crf "$((quality + 2))" -preset medium -tag:v hvc1)
  else venc=(-c:v libx264 -crf "$quality" -preset slow); fi
  tail_filter="format=yuv420p"
  pre=()
fi

if [[ -n ${fc:-} ]]; then
  filt=(-filter_complex "${fc},${tail_filter}[v]" -map "[v]" -map "0:a?")
else
  filt=(-vf "${vf},${tail_filter}" -map 0:v:0 -map "0:a?")
fi

echo "→ $preset via $( ((hw)) && echo "VAAPI ${codec}" || echo "software ${codec}")"
ffmpeg -hide_banner -loglevel error "$([[ -t 2 ]] && echo -stats || echo -nostats)" -y "${pre[@]}" -i "$in" "${filt[@]}" "${venc[@]}" "${audio[@]}" \
  -movflags +faststart "$out"
echo "✔ $out ($(numfmt --to=iec --suffix=B "$(stat -c %s "$out")"))"
