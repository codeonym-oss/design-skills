#!/usr/bin/env bats
# bin/ds: the user-facing CLI around the dispatcher.

load helpers

setup() { fake_runtime_setup; }

@test "ds with no arguments prints usage" {
  run "$REPO/bin/ds"
  [ "$status" -eq 2 ]
  [[ "$output" == *"usage: ds"* ]]
}

@test "ds <skill>/<script> runs that skill script (.sh optional)" {
  run "$REPO/bin/ds" graphic-design/optimize a.png
  [ "$output" = "FAKE-RUNTIME-RAN" ]
  [ "$(tail -3 "$RUNTIME_LOG" | tr '\n' ' ')" = "bash $REPO/skills/graphic-design/scripts/optimize.sh a.png " ]
}

@test "ds <unknown script> fails with a hint" {
  run "$REPO/bin/ds" graphic-design/nope
  [ "$status" -eq 2 ]
  [[ "$output" == *"ds list"* ]]
}

@test "ds list shows every skill script" {
  run "$REPO/bin/ds" list
  [ "$status" -eq 0 ]
  [[ "$output" == *"graphic-design/optimize"* ]]
  [[ "$output" == *"3d-modeling/render"* ]]
  [[ "$output" != *"check.sh"* ]]
}

@test "ds exec runs any tool in the container" {
  run "$REPO/bin/ds" exec inkscape --version
  [ "$(tail -3 "$RUNTIME_LOG" | tr '\n' ' ')" = "ghcr.io/codeonym-oss/design-skills:$VERSION-core inkscape --version " ]
}

@test "ds exec picks the full image for full-only tools" {
  run "$REPO/bin/ds" exec blender -b --version
  grep -qx "ghcr.io/codeonym-oss/design-skills:$VERSION-full" "$RUNTIME_LOG"
}

@test "ds shell opens an interactive shell" {
  run "$REPO/bin/ds" shell
  grep -qx -- '-it' "$RUNTIME_LOG"
  [ "$(tail -1 "$RUNTIME_LOG")" = bash ]
}

@test "ds image prints the image a variant resolves to" {
  run "$REPO/bin/ds" image full
  [ "$output" = "ghcr.io/codeonym-oss/design-skills:$VERSION-full" ]
}

@test "ds pull pulls the requested variant" {
  run "$REPO/bin/ds" pull full
  [ "$(cat "$RUNTIME_LOG" | tr '\n' ' ')" = "docker pull ghcr.io/codeonym-oss/design-skills:$VERSION-full " ]
}

@test "ds runs natively inside the container" {
  DS_IN_CONTAINER=1 run "$REPO/bin/ds" exec echo hi
  [ "$output" = hi ]
  [ ! -e "$RUNTIME_LOG" ]
}

@test "ds version prints the plugin version and runtime" {
  run "$REPO/bin/ds" version
  [[ "$output" == *"$VERSION"* ]]
  [[ "$output" == *"docker"* ]]
}
