#!/usr/bin/env bats
# bats file_tags=full
load helpers

@test "illustration: check passes" {
  run ds illustration/check
  echo "$output"
  [ "$status" -eq 0 ]
}

@test "new-canvas: a real .kra at the preset size; never overwrites" {
  run ds illustration/new-canvas thumbnail cover '#fef3c7'
  echo "$output"
  [ "$status" -eq 0 ]
  [ "$(python3 -c 'import sys, zipfile; print(zipfile.ZipFile(sys.argv[1]).read("mimetype").decode())' cover.kra)" = application/x-krita ]
  run ds illustration/new-canvas thumbnail cover
  [ "$status" -eq 1 ]
  [[ "$output" == *"not overwriting"* ]]
}

@test "kra-export: .kra files exported headlessly to export/" {
  ds illustration/new-canvas thumbnail art >/dev/null
  run ds illustration/kra-export art.kra webp
  echo "$output"
  [ "$status" -eq 0 ]
  [ "$(dims export/art.webp)" = 2560x1440 ]
}
