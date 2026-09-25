# Integration tests run INSIDE the design-skills image (DS_IN_CONTAINER=1), against the
# checkout mounted at the same path:  make test-core / make test-full
REPO="$(cd "$(dirname "${BATS_TEST_FILENAME}")/../.." && pwd -P)"
SK="$REPO/skills"

setup() {
  [[ -n ${DS_IN_CONTAINER:-} ]] || skip "integration tests run inside the image (make test-core / test-full)"
  cd "$BATS_TEST_TMPDIR"
}

# ds <skill>/<script> [args] — run a skill script the way users do
ds() { local s=$1; shift; bash "$SK/${s%%/*}/scripts/${s#*/}.sh" "$@"; }

# dims <image> -> WxH
dims() { magick identify -format '%wx%h' "$1[0]"; }

fixture_svg() { # a square logo with text (text exercises fonts in exports)
  cat >"${1:-logo.svg}" <<'EOF'
<svg xmlns="http://www.w3.org/2000/svg" width="256" height="256" viewBox="0 0 256 256">
  <rect x="16" y="16" width="224" height="224" rx="48" fill="#2563eb"/>
  <circle cx="128" cy="110" r="52" fill="#fff"/>
  <text x="128" y="215" font-family="Inter" font-size="36" font-weight="700" text-anchor="middle" fill="#fff">DS</text>
</svg>
EOF
}

fixture_photo() { # fixture_photo <out.jpg> [WxH] — a gradient "photo" with camera + GPS metadata
  magick -size "${2:-3000x2000}" gradient:'#f97316-#1e3a8a' -attenuate 0.4 +noise Gaussian -quality 92 "$1"
  exiftool -q -overwrite_original -Make=TestCam -Model=X1 -Orientation#=1 \
    -GPSLatitude=33.5731 -GPSLatitudeRef=N -GPSLongitude=7.5898 -GPSLongitudeRef=W "$1"
}

fixture_video() { # fixture_video <out> [seconds] [WxH] — test pattern + quiet tone, with audio
  ffmpeg -hide_banner -loglevel error -y \
    -f lavfi -i "testsrc2=size=${3:-640x360}:rate=30:duration=${2:-3}" \
    -f lavfi -i "sine=frequency=440:sample_rate=48000:duration=${2:-3}" \
    -af volume=-30dB -c:v libx264 -preset ultrafast -pix_fmt yuv420p -c:a aac -shortest "$1"
}

fixture_pdf() { # fixture_pdf <out.pdf> — 2-page vector PDF with embedded text, no bleed boxes
  fixture_svg page.svg
  inkscape page.svg --export-type=pdf --export-filename=p1.pdf 2>/dev/null
  gs -q -dNOPAUSE -dBATCH -dSAFER -sDEVICE=pdfwrite -sOutputFile="$1" p1.pdf p1.pdf
}

codec_of() { ffprobe -v error -select_streams v:0 -show_entries stream=codec_name -of csv=p=0 "$1"; }
duration_of() { ffprobe -v error -show_entries format=duration -of csv=p=0 "$1"; }

fixture_bleed_pdf() { # fixture_bleed_pdf <out.pdf> <bleed-pt> — A5 page with real Trim/Bleed boxes
  python3 - "$1" "$2" <<'PY'
import sys
out, b = sys.argv[1], float(sys.argv[2])
w, h = 419.53 + 2 * b, 595.28 + 2 * b          # A5 trim size plus bleed on every side
content = f"0.15 0.39 0.92 rg 0 0 {w:.2f} {h:.2f} re f".encode()
objs = [b"<< /Type /Catalog /Pages 2 0 R >>",
        b"<< /Type /Pages /Kids [3 0 R] /Count 1 >>",
        (f"<< /Type /Page /Parent 2 0 R /MediaBox [0 0 {w:.2f} {h:.2f}] /BleedBox [0 0 {w:.2f} {h:.2f}] "
         f"/TrimBox [{b:.2f} {b:.2f} {w - b:.2f} {h - b:.2f}] /Contents 4 0 R /Resources << >> >>").encode(),
        b"<< /Length %d >>\nstream\n" % len(content) + content + b"\nendstream"]
pdf, offs = b"%PDF-1.7\n", []
for i, o in enumerate(objs, 1):
    offs.append(len(pdf))
    pdf += b"%d 0 obj\n" % i + o + b"\nendobj\n"
x = len(pdf)
pdf += b"xref\n0 %d\n0000000000 65535 f \n" % (len(objs) + 1) + b"".join(b"%010d 00000 n \n" % o for o in offs)
pdf += b"trailer\n<< /Size %d /Root 1 0 R >>\nstartxref\n%d\n%%%%EOF\n" % (len(objs) + 1, x)
open(out, "wb").write(pdf)
PY
}
