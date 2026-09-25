# Changelog

## 0.1.0 — 2026-09-25

First public release, copied from the author's personal Arch workstation skills and made distro-agnostic and container-first.

### Added
- **Sandbox images** `ghcr.io/codeonym-oss/design-skills:<version>-{core,full}` on Ubuntu 26.04 LTS (amd64 + arm64):
  core ≈ 1.2 GB (ImageMagick 7, Inkscape 1.4, ffmpeg 8, Ghostscript, Poppler, optimizers, exiftool, FontForge, fonts,
  FOGRA/ISO Coated ICC profiles), full ≈ 2.9 GB (+ Blender 5, GIMP 3.2, G'MIC, Krita 6, Scribus 1.6, darktable 5, MLT, Mesa, Xvfb, Noto CJK).
- **Dispatcher** (`lib/ds.sh`): every skill script re-runs itself in the pinned image with the same paths; mounts
  path arguments outside the working dir; runs as the calling user; VAAPI GPU passthrough; Docker or Podman; `DS_RUNTIME=native` escape hatch.
- **`ds` CLI**: run scripts, `exec` any tool, `shell`, `doctor`, `list`, `pull`, `image`, `test`, `version`.
- **`design-sandbox` skill** documenting the environment.
- **Project fonts**: `./fonts` (and `DS_FONTS`) are visible to every tool in the container.
- **Distro-agnostic checks** with install hints for apt, pacman, dnf and Homebrew (`lib/packages.tsv`).
- `print-layout/new-print-doc.sh --brand '#hex'`; Scribus runs under Xvfb when headless.
- `photo-editing/batch-develop.sh` accepts a `.dtstyle` file path.
- Test suite: 46 unit tests (bash 5 and 3.2) and 54 integration tests run inside the images; CI builds and tests
  every variant × architecture before publishing.

### Changed
- All skills and guides rewritten for any OS: no Arch/AUR commands, no machine-specific hardware, OBS guidance for
  Windows/macOS/Linux, keystroke/zoom tools per platform.
- `convert-model.sh` passes paths to Blender as arguments (file names with quotes work).

### Fixed (vs. the upstream Ubuntu packages)
- Blender's glTF Draco compression: Ubuntu ships the encoder under a CPython-tagged file name the add-on doesn't
  load; the image links it so `--draco` actually compresses.
- `font-specimen.sh` no longer relies on ImageMagick `@file` reads, which common security policies forbid.
