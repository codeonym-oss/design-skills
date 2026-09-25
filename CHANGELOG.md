# Changelog

## [0.1.2](https://github.com/codeonym-oss/design-skills/compare/v0.1.1...v0.1.2) (2026-09-25)


### Documentation

* link the repo's own design-skills board ([#25](https://github.com/codeonym-oss/design-skills/issues/25)) ([d8a410b](https://github.com/codeonym-oss/design-skills/commit/d8a410ba046a2c3176a2aca5ccd0a64d44891cf9))
* track issues in GitHub Issues instead of Linear ([#23](https://github.com/codeonym-oss/design-skills/issues/23)) ([a702986](https://github.com/codeonym-oss/design-skills/commit/a70298696ab705adc931219836b376ba5a10242f))

## [0.1.1](https://github.com/codeonym-oss/design-skills/compare/v0.1.0...v0.1.1) (2026-09-25)


### Build & Image

* **deps:** Bump actions/checkout from 5 to 7 ([#3](https://github.com/codeonym-oss/design-skills/issues/3)) ([c56c70f](https://github.com/codeonym-oss/design-skills/commit/c56c70f3e394d16cf7f161da546b3b6fb4606e38))
* **deps:** Bump actions/download-artifact from 4 to 8 ([bdbfc0e](https://github.com/codeonym-oss/design-skills/commit/bdbfc0e46c0b0895088e2c00e8ce6a05b199e1a3))
* **deps:** Bump actions/upload-artifact from 4 to 7 ([#4](https://github.com/codeonym-oss/design-skills/issues/4)) ([ae1eda7](https://github.com/codeonym-oss/design-skills/commit/ae1eda7ee76113e5d5fcf10402d6923cccbf322f))
* **deps:** Bump docker/build-push-action from 6 to 7 ([#1](https://github.com/codeonym-oss/design-skills/issues/1)) ([a433ab2](https://github.com/codeonym-oss/design-skills/commit/a433ab2b293dd74050d0fbeb82b5e07d1aeb7a8f))
* **deps:** Bump docker/login-action from 3 to 4 ([#2](https://github.com/codeonym-oss/design-skills/issues/2)) ([78d81b7](https://github.com/codeonym-oss/design-skills/commit/78d81b7c8fe4a20a78b6a126b38154eda6bb4fba))

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
