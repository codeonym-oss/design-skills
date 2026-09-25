#!/usr/bin/env bats
load helpers

@test "doctor: every check available in this image passes" {
  run ds design-doctor/doctor
  echo "$output"
  [ "$status" -eq 0 ]
  [[ "$output" == *"graphic-design"*"ok"* ]]
  if [[ $DS_VARIANT == core ]]; then [[ "$output" == *"3d-modeling"*"skipped"* ]]; fi
}
