#!/usr/bin/env bats
load helpers

@test "finish-recording: trimmed, normalized master plus a review copy" {
  fixture_video rec.mkv 6
  run ds screen-recording/finish-recording rec.mkv --trim-start 1 --trim-end 1
  echo "$output"
  [ "$status" -eq 0 ]
  [ -s rec.final.mp4 ] && [ -s rec.review.mp4 ]
  [ ! -e rec.remux.mp4 ]
  awk -v d="$(duration_of rec.final.mp4)" 'BEGIN { exit !(d > 3 && d < 5.5) }'
}

@test "presenter-mode explains itself when GNOME is not there" {
  run ds screen-recording/presenter-mode status
  [[ "$output" == *"GNOME"* ]]
}
