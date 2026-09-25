#!/usr/bin/env bats
load helpers

@test "video-editing: check passes" {
  run ds video-editing/check
  echo "$output"
  [ "$status" -eq 0 ]
}

@test "encode: web → H.264 MP4; archive → HEVC" {
  fixture_video in.mp4 2
  run ds video-editing/encode in.mp4 web --sw
  [ "$status" -eq 0 ]
  [ "$(codec_of in-web.mp4)" = h264 ]
  run ds video-editing/encode in.mp4 archive out.mp4 --sw
  [ "$status" -eq 0 ]
  [ "$(codec_of out.mp4)" = hevc ]
}

@test "encode: vertical and square presets have exact frame sizes" {
  fixture_video in.mp4 1
  run ds video-editing/encode in.mp4 vertical v.mp4 --sw
  [ "$(dims v.mp4)" = 1080x1920 ]
  run ds video-editing/encode in.mp4 square s.mp4 --sw
  [ "$(dims s.mp4)" = 1080x1080 ]
}

@test "encode: unknown preset is rejected" {
  fixture_video in.mp4 1
  run ds video-editing/encode in.mp4 nope
  [ "$status" -eq 2 ]
}

@test "loudnorm: integrated loudness lands near the target" {
  fixture_video quiet.mp4 4
  run ds video-editing/loudnorm quiet.mp4 --target -16
  [ "$status" -eq 0 ]
  I=$(ffmpeg -hide_banner -nostats -i quiet-norm.mp4 -af ebur128 -f null - 2>&1 | awk '/I:/ {v=$2} END {print v}')
  awk -v i="$I" 'BEGIN { exit !(i > -18 && i < -14) }'
}

@test "gif: palette GIF plus a smaller WebM" {
  fixture_video in.mp4 2
  run ds video-editing/gif in.mp4 --dur 1 --width 320 --fps 10
  [ "$status" -eq 0 ]
  [ "$(magick identify -format '%w\n' in.gif | head -1)" -eq 320 ]
  [ "$(codec_of in.webm)" = vp9 ]
}

@test "thumbs: N frames and a storyboard" {
  fixture_video in.mp4 3
  run ds video-editing/thumbs in.mp4 4
  [ "$status" -eq 0 ]
  [ "$(ls in-thumbs/*s.jpg | wc -l)" -eq 4 ]
  [ -s in-thumbs/storyboard.jpg ]
}

# bats test_tags=full
@test "render-project: an MLT/Kdenlive project renders to MP4 with melt" {
  fixture_video clip.mp4 2
  cat > project.kdenlive <<XML
<?xml version="1.0" encoding="utf-8"?>
<mlt LC_NUMERIC="C" version="7.0.0">
  <profile width="640" height="360" frame_rate_num="30" frame_rate_den="1" progressive="1"
           sample_aspect_num="1" sample_aspect_den="1" display_aspect_num="16" display_aspect_den="9" colorspace="709"/>
  <producer id="clip"><property name="resource">$PWD/clip.mp4</property></producer>
  <playlist id="main"><entry producer="clip" in="0" out="44"/></playlist>
  <tractor id="tractor0"><track producer="main"/></tractor>
</mlt>
XML
  run ds video-editing/render-project project.kdenlive out.mp4
  echo "$output"
  [ "$status" -eq 0 ]
  [ "$(codec_of out.mp4)" = h264 ]
}

@test "gif: unknown options are rejected" {
  fixture_video in.mp4 1
  run ds video-editing/gif in.mp4 --widht 300
  [ "$status" -eq 2 ]
}
