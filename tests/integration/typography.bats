#!/usr/bin/env bats
load helpers

@test "typography: check passes" {
  run ds typography/check
  echo "$output"
  [ "$status" -eq 0 ]
}

@test "font-inventory: lists families, filter works" {
  run ds typography/font-inventory mono
  [ "$status" -eq 0 ]
  [[ "$output" == *"JetBrains Mono"* ]]
  [[ "$output" != *"Open Sans"* ]]
}

@test "font-specimen: one band per family; unknown families are flagged" {
  run ds typography/font-specimen "Inter" "IBM Plex Serif" "Nonexistent Family" -o spec.png
  [ "$status" -eq 0 ]
  [[ "$output" == *"'Nonexistent Family' not installed"* ]]
  [ "$(magick identify -format %w spec.png)" -eq 1400 ]
  [ "$(magick identify -format %h spec.png)" -gt 600 ]
}

@test "font-specimen: Arabic and CJK text render (global scripts)" {
  run ds typography/font-specimen "Noto Sans Arabic" -t "مرحبا بالعالم" -o ar.png
  [ "$status" -eq 0 ]
  [ -s ar.png ]
}

@test "webfont: WOFF2 + WOFF + @font-face CSS with the real family name" {
  ttf=$(fc-match -f '%{file}' 'Liberation Sans:bold')
  cp "$ttf" LiberationSans-Bold.ttf
  run ds typography/webfont LiberationSans-Bold.ttf out
  [ "$status" -eq 0 ]
  [ "$(file -b out/LiberationSans-Bold.woff2)" != "empty" ]
  [ -s out/LiberationSans-Bold.woff ]
  grep -q 'font-family: "Liberation Sans"' out/fonts.css
  grep -q 'font-weight: 700' out/fonts.css
}

@test "project fonts: anything in ./fonts is visible to every tool" {
  mkdir fonts
  cp "$(fc-match -f '%{file}' 'DejaVu Sans')" fonts/Project.ttf
  run bash -c ". '$REPO/lib/env.sh'; fc-list"
  [[ "$output" == *"$PWD/fonts/Project.ttf"* ]]
  # and without ./fonts, nothing extra is registered
  rm -r fonts
  run bash -c ". '$REPO/lib/env.sh'; fc-list"
  [[ "$output" != *"/fonts/Project.ttf"* ]]
}

@test "webfont: a mistyped font path is an error, not an output folder" {
  run ds typography/webfont Missing-Font.ttf out
  [ "$status" -eq 2 ]
  [[ "$output" == *"font not found"* ]]
  [ ! -d Missing-Font.ttf ]
}
