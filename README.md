# design-skills

[![ci](https://github.com/codeonym-oss/design-skills/actions/workflows/ci.yml/badge.svg)](https://github.com/codeonym-oss/design-skills/actions/workflows/ci.yml)
[![image](https://github.com/codeonym-oss/design-skills/actions/workflows/image.yml/badge.svg)](https://github.com/codeonym-oss/design-skills/actions/workflows/image.yml)
[![release](https://img.shields.io/github/v/release/codeonym-oss/design-skills)](https://github.com/codeonym-oss/design-skills/releases)
[![license](https://img.shields.io/github/license/codeonym-oss/design-skills)](LICENSE)

Design skills for [Claude Code](https://claude.com/claude-code), with the whole toolchain in a **versioned, headless
container**: Blender, GIMP, Inkscape, Krita, Scribus, darktable, MLT, ffmpeg, ImageMagick, Ghostscript, FontForge,
the web-image optimizers and a curated font library. Install the plugin, have Docker or Podman, and every skill
works the same on Linux, macOS (Intel and Apple Silicon) and Windows (WSL2) — no per-machine setup.

Skills are installed under the `codeonym-oss:` prefix.

| Skill | Covers | Image |
|---|---|---|
| `codeonym-oss:design-sandbox` | The environment itself: `ds` CLI, images, mounts, fonts, GPU, troubleshooting | — |
| `codeonym-oss:design-doctor` | Health check of everything; which skill/tool for which job | — |
| `codeonym-oss:graphic-design` | Logos, banners, social sizes, SVG export, vectorizing, web-image optimization | core |
| `codeonym-oss:illustration` | Krita canvases from presets, headless `.kra` export, tablet setup | full |
| `codeonym-oss:photo-editing` | darktable batch development, web-ready photos, metadata/GPS stripping, contact sheets | core · full |
| `codeonym-oss:ui-design` | Favicons/PWA icon sets + manifest, OKLCH color scales → CSS/Tailwind v4, design tokens | core |
| `codeonym-oss:typography` | Font inventory, specimens (any script), project fonts, WOFF2 + `@font-face` | core |
| `codeonym-oss:print-layout` | Scribus templates with bleed/CMYK, PDF preflight, proofs, compression, CMYK conversion | core · full |
| `codeonym-oss:3d-modeling` | Blender renders, design mockups, turntables, GLB (+Draco) conversion, STL | full |
| `codeonym-oss:video-editing` | Platform encodes, loudness normalization, GIF/WebM, thumbnails, headless Kdenlive/MLT renders | core · full |
| `codeonym-oss:screen-recording` | OBS setup on any OS, recording workflow, post-production of recordings | host · core |

## Install

```bash
claude plugin marketplace add codeonym-oss/design-skills
claude plugin install codeonym-oss@codeonym-oss
```

Then pull an image once (or let the first script pull it). `ds` ships inside the plugin; put it on your PATH:

```bash
ln -s ~/.claude/plugins/cache/codeonym-oss/codeonym-oss/*/bin/ds ~/.local/bin/ds
ds pull core     # ≈1.2 GB: graphic, photo, UI, type, print PDFs, video
ds pull full     # ≈2.9 GB: adds Blender, GIMP, Krita, Scribus, darktable, melt
```

Or just ask Claude: *"check my design setup"* runs the doctor.

## How it works

```
bash skills/graphic-design/scripts/optimize.sh ~/Pictures/hero.png
        │  lib/env.sh → lib/ds.sh
        ▼
docker run --rm --user $UID:$GID \
  -v $PWD:$PWD -w $PWD                     ← your folder, same path inside
  -v <plugin>:<plugin>:ro                  ← the scripts
  -v ~/Pictures:~/Pictures                 ← any other folder you named
  [--device /dev/dri]                      ← VAAPI when the host has a GPU
  ghcr.io/codeonym-oss/design-skills:0.1.0-core  bash …/optimize.sh ~/Pictures/hero.png
```

- Each script re-runs itself in the image pinned to the plugin's `VERSION`, with identical paths, so outputs land
  next to your files and are owned by you.
- Scripts marked `# ds-image: full` use the full image; once the full image is pulled it serves everything.
- `DS_RUNTIME=native` runs on your own installed tools instead; `ds doctor --verbose` prints install commands for
  apt, pacman, dnf or Homebrew.
- Fonts in `./fonts` are available to every tool in the container.

### Desktop apps vs. the container

Everything scriptable runs headlessly in the image. Interactive desktop apps stay on your machine, and the skills
explain them per OS: OBS and its plugins, keystroke overlays and auto-zoom recorders (`screen-recording`), Penpot,
Figma and Lunacy (`ui-design`), color pickers, AI upscalers (Upscayl), GIMP plugins like Resynthesizer, the Kdenlive
editor (projects are rendered headlessly with melt), and tablet drivers.

### Images

| Tag | |
|---|---|
| `ghcr.io/codeonym-oss/design-skills:0.1.0-core` / `:0.1.0-full` | immutable release (what the plugin uses) |
| `:0.1-core`, `:core`, `:0.1-full`, `:full`, `:latest` | moving tags |
| `:edge-core`, `:edge-full` | latest `main` |

Every published image carries an SBOM and SLSA provenance (`docker buildx imagetools inspect <ref> --format '{{json .SBOM}}'`).

Built on Ubuntu 26.04 LTS (base pinned by digest), for `linux/amd64` and `linux/arm64`. Publishing from a fork?
GHCR creates new packages as private — set the package to *Public* once (package settings) so `docker pull` works anonymously.

### Without Claude

```bash
docker run --rm -v "$PWD:/work" -w /work --user "$(id -u):$(id -g)" \
  ghcr.io/codeonym-oss/design-skills:0.1.0-core ds graphic-design/social-sizes banner.png
docker run --rm -it -v "$PWD:/work" -w /work ghcr.io/codeonym-oss/design-skills:0.1.0-full   # a shell with everything
```

## Development

```bash
make build        # build core + full, tagged exactly as ds expects
make test         # unit tests on the host + integration tests inside both images
make lint         # shellcheck
make test-bash32  # host-side code under bash 3.2 (macOS)
```

Layout:
```
.claude-plugin/   plugin.json · marketplace.json
bin/ds            the CLI
lib/              ds.sh (dispatcher) · env.sh (sourced by every script) · check.sh + packages.tsv (checks, install hints)
skills/<name>/    SKILL.md · scripts/ · references/
docker/           Dockerfile (core-tools → full-tools → core / full)
tests/unit        bats: dispatcher, CLI, check library, repo consistency (fake container runtime)
tests/integration bats: every script against generated fixtures, inside the image (tag `full` = full image only)
```

See [CONTRIBUTING.md](CONTRIBUTING.md) for adding tools and skills and the release flow, [CHANGELOG.md](CHANGELOG.md),
and [SECURITY.md](SECURITY.md) to report vulnerabilities. The maintainers track the roadmap in
Linear; bug reports and feature requests are welcome as GitHub issues.

## Origins

Started as a copy of the author's personal Arch Linux workstation skills (`codeonym-org/codeonym-arch-design`),
rebuilt here to be distro-agnostic and container-first.

## License

MIT. The images bundle third-party open-source software under their own licenses (GPL, LGPL, OFL, Apache, …).
