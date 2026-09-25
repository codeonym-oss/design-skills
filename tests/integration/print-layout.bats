#!/usr/bin/env bats
load helpers

@test "print-layout: check passes" {
  run ds print-layout/check
  echo "$output"
  [ "$status" -eq 0 ]
  [[ "$output" == *"press profile"* ]]      # FOGRA/ISO Coated profiles ship in the image
}

@test "pdf-preflight: flags a PDF with no bleed" {
  fixture_pdf doc.pdf
  run ds print-layout/pdf-preflight doc.pdf
  [ "$status" -eq 1 ]
  [[ "$output" == *"no TrimBox/bleed"* ]]
  [[ "$output" == *"Pages: 2"* ]]
}

@test "pdf-preflight: passes a PDF with 3 mm bleed" {
  fixture_bleed_pdf ok.pdf 8.5
  run ds print-layout/pdf-preflight ok.pdf
  echo "$output"
  [ "$status" -eq 0 ]
  [[ "$output" == *"bleed 3.0 mm"* ]]
  [[ "$output" == *"TrimBox 148.0 × 210.0 mm"* ]]
}

@test "pdf-preflight: flags a bleed that is too small" {
  fixture_bleed_pdf thin.pdf 2.8
  run ds print-layout/pdf-preflight thin.pdf
  [ "$status" -eq 1 ]
  [[ "$output" == *"bleed only 1.0 mm"* ]]
}

@test "pdf-proof: one PNG per page plus an overview" {
  fixture_pdf doc.pdf
  run ds print-layout/pdf-proof doc.pdf 50
  [ "$status" -eq 0 ]
  [ "$(ls doc-proof/page*.png | wc -l)" -eq 2 ]
  [ -s doc-proof/overview.png ]
}

@test "pdf-compress and pdf-cmyk produce valid PDFs" {
  fixture_pdf doc.pdf
  run ds print-layout/pdf-compress doc.pdf screen
  [ "$status" -eq 0 ]
  pdfinfo doc-screen.pdf >/dev/null
  run ds print-layout/pdf-cmyk doc.pdf
  [ "$status" -eq 0 ]
  pdfinfo doc-cmyk.pdf >/dev/null
}

# bats test_tags=full
@test "new-print-doc: Scribus template + proof PDF that passes preflight" {
  run ds print-layout/new-print-doc a5 flyer --title "Hello print" --brand '#16a34a' --proof
  echo "$output"
  [ "$status" -eq 0 ]
  grep -q 'BleedTop="8.50' flyer.sla || grep -q 'BleedTop="8.5' flyer.sla
  run ds print-layout/pdf-preflight flyer-proof.pdf
  echo "$output"
  [ "$status" -eq 0 ]
  [[ "$output" == *"embedded"* ]]
}
