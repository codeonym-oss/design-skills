#!/usr/bin/env bash
# Check the video-editing toolkit.
. "$(dirname "$(readlink -f "$0")")/../../../lib/check.sh"

section "ffmpeg"
tool ffmpeg "ffmpeg" --version
tool ffprobe "ffprobe"
enc=$(ffmpeg -hide_banner -encoders 2>/dev/null | grep -oE 'lib(x264|x265|svtav1|vpx-vp9)|(h264|hevc|av1)_(vaapi|nvenc|qsv|videotoolbox)' | sort -u | tr '\n' ' ')
info "encoders: ${enc:-none}"
if sh=$(shadowed ffmpeg); then warn "plain 'ffmpeg' in your shell is $sh — scripts here use /usr/bin/ffmpeg"; fi

section "Hardware encoding (VAAPI)"
if [[ -e /dev/dri/renderD128 ]]; then
  if command -v vainfo >/dev/null && [[ $(vainfo 2>/dev/null) == *VAEntrypointEncSlice* ]]; then
    vainfo 2>/dev/null | grep -oE 'VAProfile(H264High|HEVCMain|AV1Profile0) *: *VAEntrypointEncSlice' | awk '{print $1}' | sed 's/VAProfile/encode: /' | while read -r l; do info "$l"; done
  else info "GPU render node present but no VAAPI encode profiles — encoding falls back to software x264/x265"; fi
else
  info "no GPU passed through — encoding uses software x264/x265 (same result, slower)"
fi

section "Editors"
full_tool melt "melt (MLT — renders Kdenlive projects)"
info "Kdenlive itself is a desktop app — edit there, render here with render-project.sh"

section "Helpers"
tool magick "ImageMagick (storyboards)"

summary
