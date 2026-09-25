#!/usr/bin/env bats
# The dispatcher: every skill script sources lib/env.sh, which decides whether the
# script runs right here or re-runs itself inside the design-skills container.

load helpers

setup() { fake_runtime_setup; }

@test "inside the container, scripts run natively" {
  make_script "$WORK/s.sh"
  DS_IN_CONTAINER=1 run bash "$WORK/s.sh" a b
  [ "$status" -eq 0 ]
  [ "$output" = "NATIVE-RAN a b" ]
  [ ! -e "$RUNTIME_LOG" ]
}

@test "DS_RUNTIME=native runs on the host" {
  make_script "$WORK/s.sh"
  DS_RUNTIME=native run bash "$WORK/s.sh" x
  [ "$output" = "NATIVE-RAN x" ]
  [ ! -e "$RUNTIME_LOG" ]
}

@test "scripts marked ds-runtime: host never enter the container" {
  make_script "$WORK/s.sh" '# ds-runtime: host'
  run bash "$WORK/s.sh"
  [ "$output" = "NATIVE-RAN " ]
  [ ! -e "$RUNTIME_LOG" ]
}

@test "with docker available, the script re-runs in the core image with the same paths" {
  make_script "$WORK/s.sh"
  run bash "$WORK/s.sh" in.png --flag
  [ "$status" -eq 0 ]
  [ "$output" = "FAKE-RUNTIME-RAN" ]
  [ "$(head -2 "$RUNTIME_LOG" | tr '\n' ' ')" = "docker run " ]
  grep -qx -- '--rm' "$RUNTIME_LOG"
  has_arg_pair -v "$WORK:$WORK"
  has_arg_pair -w "$WORK"
  has_arg_pair -v "$REPO:$REPO:ro"
  has_arg_pair --user "$(id -u):$(id -g)"
  # image, then the command: bash <same script path> <same args>
  [ "$(tail -5 "$RUNTIME_LOG" | tr '\n' ' ')" = "ghcr.io/codeonym-oss/design-skills:$VERSION-core bash $WORK/s.sh in.png --flag " ]
}

@test "scripts marked ds-image: full use the full image" {
  make_script "$WORK/s.sh" '# ds-image: full'
  run bash "$WORK/s.sh"
  grep -qx "ghcr.io/codeonym-oss/design-skills:$VERSION-full" "$RUNTIME_LOG"
}

@test "the full image is preferred for everything once it is present locally" {
  make_script "$WORK/s.sh"
  FAKE_IMAGES="ghcr.io/codeonym-oss/design-skills:$VERSION-full" run bash "$WORK/s.sh"
  grep -qx "ghcr.io/codeonym-oss/design-skills:$VERSION-full" "$RUNTIME_LOG"
}

@test "DS_VARIANT, DS_IMAGE_REPO and DS_IMAGE_TAG override the image" {
  make_script "$WORK/s.sh" '# ds-image: full'
  DS_VARIANT=core DS_IMAGE_REPO=local/ds DS_IMAGE_TAG=dev run bash "$WORK/s.sh"
  grep -qx "local/ds:dev-core" "$RUNTIME_LOG"
}

@test "DS_IMAGE overrides the whole image reference" {
  make_script "$WORK/s.sh"
  DS_IMAGE=my/image:1 run bash "$WORK/s.sh"
  grep -qx "my/image:1" "$RUNTIME_LOG"
}

@test "an argument pointing outside the working dir gets its directory mounted" {
  make_script "$WORK/s.sh"
  mkdir -p "$BATS_TEST_TMPDIR/elsewhere"
  touch "$BATS_TEST_TMPDIR/elsewhere/photo.jpg"
  run bash "$WORK/s.sh" "$BATS_TEST_TMPDIR/elsewhere/photo.jpg" -o "$BATS_TEST_TMPDIR/out/new.png"
  has_arg_pair -v "$BATS_TEST_TMPDIR/elsewhere:$BATS_TEST_TMPDIR/elsewhere"
  # output path whose directory does not exist yet: nothing to mount, nothing breaks
  [ "$status" -eq 0 ]
}

@test "paths inside the working dir or the repo are not mounted twice" {
  make_script "$WORK/s.sh"
  touch "$WORK/a.png"
  run bash "$WORK/s.sh" "$WORK/a.png" "$REPO/VERSION"
  [ "$(grep -c -- '^-v$' "$RUNTIME_LOG")" -eq 2 ]
}

@test "the filesystem root is never mounted" {
  make_script "$WORK/s.sh"
  run bash "$WORK/s.sh" /etc
  ! grep -qx '/:/' "$RUNTIME_LOG"
  ! grep -qx '/etc:/etc' "$RUNTIME_LOG"
}

@test "DS_MOUNTS adds extra mounts" {
  make_script "$WORK/s.sh"
  mkdir -p "$BATS_TEST_TMPDIR/assets"
  DS_MOUNTS="$BATS_TEST_TMPDIR/assets" run bash "$WORK/s.sh"
  has_arg_pair -v "$BATS_TEST_TMPDIR/assets:$BATS_TEST_TMPDIR/assets"
}

@test "tuning variables pass through to the container" {
  make_script "$WORK/s.sh"
  QUALITY=70 FORMAT=webp run bash "$WORK/s.sh"
  has_arg_pair -e QUALITY=70
  has_arg_pair -e FORMAT=webp
  ! grep -q '^WIDTH=' "$RUNTIME_LOG"
}

@test "podman is used when docker is absent, with keep-id user mapping" {
  rm "$FAKEBIN/docker"
  make_script "$WORK/s.sh"
  run bash "$WORK/s.sh"
  [ "$(head -1 "$RUNTIME_LOG")" = podman ]
  grep -qx -- '--userns=keep-id' "$RUNTIME_LOG"
  ! grep -qx -- '--user' "$RUNTIME_LOG"
}

@test "with no container runtime at all, scripts fall back to native" {
  rm "$FAKEBIN/docker" "$FAKEBIN/podman"
  make_script "$WORK/s.sh"
  run bash "$WORK/s.sh" z
  [ "$output" = "NATIVE-RAN z" ]
}

@test "an explicit DS_RUNTIME that is missing is an error, not a silent fallback" {
  rm "$FAKEBIN/podman"
  make_script "$WORK/s.sh"
  DS_RUNTIME=podman run bash "$WORK/s.sh"
  [ "$status" -ne 0 ]
  [[ "$output" == *"podman"*"not found"* ]]
}

@test "DS_RUN_ARGS adds extra runtime flags before the image (e.g. SELinux, limits)" {
  make_script "$WORK/s.sh"
  DS_RUN_ARGS="--security-opt label=disable --memory 8g" run bash "$WORK/s.sh"
  has_arg_pair --security-opt label=disable
  has_arg_pair --memory 8g
  [ "$(tail -3 "$RUNTIME_LOG" | head -1)" = "ghcr.io/codeonym-oss/design-skills:$VERSION-core" ]
}
