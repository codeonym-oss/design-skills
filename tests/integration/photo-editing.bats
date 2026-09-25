#!/usr/bin/env bats
load helpers

@test "photo-editing: check passes" {
  run ds photo-editing/check
  echo "$output"
  [ "$status" -eq 0 ]
}

@test "strip-metadata: GPS and camera info gone, backup kept" {
  fixture_photo p.jpg 600x400
  [ -n "$(exiftool -s3 -GPSLatitude p.jpg)" ]
  run ds photo-editing/strip-metadata p.jpg
  [ "$status" -eq 0 ]
  [ -z "$(exiftool -s3 -GPSLatitude p.jpg)" ]
  [ -z "$(exiftool -s3 -Make p.jpg)" ]
  [ -f p.jpg_original ]
}

@test "strip-metadata --no-backup leaves no *_original" {
  fixture_photo p.jpg 300x200
  run ds photo-editing/strip-metadata --no-backup p.jpg
  [ ! -e p.jpg_original ]
}

@test "web-ready: resized to --max, metadata stripped, watermark variant" {
  fixture_photo big.jpg 3000x2000
  run ds photo-editing/web-ready big.jpg --max 1200 --watermark "© Test"
  [ "$status" -eq 0 ]
  [ "$(dims web/big.jpg)" = 1200x800 ]
  [ -z "$(exiftool -s3 -GPSLatitude web/big.jpg)" ]
}

@test "contact-sheet: one grid image" {
  fixture_photo a.jpg 400x300; fixture_photo b.jpg 300x400
  run ds photo-editing/contact-sheet a.jpg b.jpg -o sheet.jpg --cols 2
  [ "$status" -eq 0 ]
  [ -s sheet.jpg ]
}

# bats test_tags=full
@test "batch-develop: darktable exports JPEGs headlessly (no style)" {
  fixture_photo a.jpg 800x600
  WIDTH=400 run ds photo-editing/batch-develop - a.jpg
  echo "$output"
  [ "$status" -eq 0 ]
  [ "$(magick identify -format %w export/a.jpg)" -eq 400 ]
}

# bats test_tags=full
@test "batch-develop: a missing style is a clear error" {
  fixture_photo a.jpg 200x100
  run ds photo-editing/batch-develop nope.dtstyle a.jpg
  [ "$status" -eq 1 ]
  [[ "$output" == *"style not found"* ]]
}
