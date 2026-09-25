#!/usr/bin/env bats
# lib/check.sh: distro-agnostic tool checks used by every skill's check.sh.

load helpers

setup() {
  fake_runtime_setup
  export DS_RUNTIME=native
  mkdir -p "$BATS_TEST_TMPDIR/tools"
  for t in present-tool other-tool; do
    printf '#!/bin/sh\necho "%s 1.2.3"\n' "$t" >"$BATS_TEST_TMPDIR/tools/$t"
    chmod +x "$BATS_TEST_TMPDIR/tools/$t"
  done
  export PATH="$BATS_TEST_TMPDIR/tools:$PATH"
  # A tiny package map instead of the real one.
  export DS_PACKAGES="$BATS_TEST_TMPDIR/packages.tsv"
  printf '%s\n' \
    '# cmd	apt	pacman	dnf	brew' \
    'zz-pdfinfo	poppler-utils	poppler	poppler-utils	poppler' \
    'zz-pdffonts	poppler-utils	poppler	poppler-utils	poppler' \
    'zz-gimp	zz-gimp	zz-gimp	zz-gimp	cask:gimp' \
    'zz-lunacy	-	lunacy-bin@aur	-	cask:lunacy' \
    | tr -s ' ' >"$DS_PACKAGES"
}

# check <snippet>: runs a check script body in a fresh shell, like a skill's check.sh would.
check() {
  printf '#!/usr/bin/env bash\n. "%s/lib/check.sh"\n%s\n' "$REPO" "$1" >"$BATS_TEST_TMPDIR/check.sh"
  run bash "$BATS_TEST_TMPDIR/check.sh"
}

@test "a present tool is reported with its path and the check passes" {
  check 'section Tools; tool present-tool "Present tool"; summary'
  [ "$status" -eq 0 ]
  [[ "$output" == *"== Tools =="* ]]
  [[ "$output" == *"✔ Present tool"*"$BATS_TEST_TMPDIR/tools/present-tool"* ]]
  [[ "$output" == *"All checks passed."* ]]
}

@test "a missing tool fails the check and gets an install command for this package manager" {
  DS_PKG_MANAGER=apt check 'tool zz-pdfinfo; tool zz-pdffonts; tool zz-gimp; summary'
  [ "$status" -eq 1 ]
  [[ "$output" == *"✘ zz-pdfinfo"* ]]
  [[ "$output" == *"3 item(s) missing"* ]]
  # one package for both poppler commands
  [[ "$output" == *"sudo apt-get install -y poppler-utils zz-gimp"* ]]
}

@test "pacman gets pacman names; AUR packages are listed separately" {
  DS_PKG_MANAGER=pacman check 'tool zz-pdfinfo; tool zz-lunacy; summary'
  [[ "$output" == *"sudo pacman -S --needed poppler"* ]]
  [[ "$output" == *"yay -S --needed lunacy-bin"* ]]
}

@test "brew formulae and casks are split" {
  DS_PKG_MANAGER=brew check 'tool zz-pdfinfo; tool zz-gimp; summary'
  [[ "$output" == *"brew install poppler"* ]]
  [[ "$output" == *"brew install --cask gimp"* ]]
}

@test "a tool with no package for this manager is named, not guessed" {
  DS_PKG_MANAGER=apt check 'tool zz-lunacy; tool mystery-tool; summary'
  [[ "$output" == *"no apt package known for: zz-lunacy mystery-tool"* ]]
}

@test "the container is offered as the no-install alternative on a host" {
  DS_PKG_MANAGER=apt check 'tool zz-pdfinfo; summary'
  [[ "$output" == *"ds pull"* ]]
}

@test "inside the container a missing tool is an image bug, not an install hint" {
  DS_IN_CONTAINER=1 DS_PKG_MANAGER=apt check 'tool zz-pdfinfo; summary'
  [ "$status" -eq 1 ]
  [[ "$output" == *"should ship with the image"* ]]
  [[ "$output" != *"apt-get install"* ]]
}

@test "optional tools warn but never fail the check" {
  check 'optional nope-tool "Nope (desktop app)" "install it on your desktop"; tool present-tool; summary'
  [ "$status" -eq 0 ]
  [[ "$output" == *"! Nope (desktop app)"*"install it on your desktop"* ]]
}

@test "version shows the first line a tool prints" {
  check 'tool present-tool "Present" --version; summary'
  [[ "$output" == *"present-tool 1.2.3"* ]]
}

@test "full_tool is required in the full image and natively, a note in the core image" {
  DS_IN_CONTAINER=1 DS_VARIANT=core check 'full_tool zz-gimp "GIMP"; summary'
  [ "$status" -eq 0 ]
  [[ "$output" == *"GIMP"*"full image"* ]]
  DS_IN_CONTAINER=1 DS_VARIANT=full check 'full_tool zz-gimp "GIMP"; summary'
  [ "$status" -eq 1 ]
  check 'full_tool zz-gimp "GIMP"; summary'
  [ "$status" -eq 1 ]
}
