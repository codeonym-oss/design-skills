---
name: design-sandbox
description: The reproducible design environment behind every codeonym-oss design skill — versioned Docker/Podman images (core and full) on GHCR with Blender, GIMP, Inkscape, Krita, Scribus, darktable, ffmpeg, ImageMagick, fonts and more, driven by the `ds` CLI. Use when the user wants to set up, pull, update or troubleshoot the design toolchain, run any design tool headlessly (`ds exec`), open a shell in the environment, use the images without Claude, or understand how the skill scripts run in the container (mounts, fonts, GPU, versions).
---

# Design sandbox (`ds` + the design-skills images)

Every skill script re-runs itself inside a pinned container image, so everyone gets the same tools and versions with
nothing to install except Docker or Podman. `ds` is the CLI: `<skill-dir>/../../bin/ds`.

## Images

| Image | Contents | Size |
|---|---|---|
| `ghcr.io/codeonym-oss/design-skills:<version>-core` | Ubuntu 26.04 LTS · ImageMagick 7 · Inkscape 1.4 · ffmpeg 8 · Ghostscript · Poppler · potrace · scour · resvg · pngquant/oxipng/jpegoptim/cwebp/avifenc/cjxl · exiftool · FontForge · woff2 · curated fonts (Latin, Arabic, emoji…) · FOGRA/ISO Coated ICC profiles | ≈ 1.2 GB |
| `ghcr.io/codeonym-oss/design-skills:<version>-full` | core + Blender 5 · GIMP 3.2 · G'MIC · Krita 6 · Scribus 1.6 · darktable 5 · MLT/melt · Mesa (software GL, VAAPI) · Xvfb · Noto CJK | ≈ 2.9 GB |

The tag version equals the plugin version (`VERSION`), so skills and tools always match. Images are built for
linux/amd64 and linux/arm64 (Apple Silicon runs them natively).

## How a script picks where to run (`lib/env.sh` → `lib/ds.sh`)

1. Already inside the image, or `DS_RUNTIME=native` → run right here (your own installed tools).
2. Script marked `# ds-runtime: host` (desktop things like OBS checks) → run on the host.
3. Otherwise → `docker`/`podman run` the same script with the same arguments in the image:
   - **full** if the script is marked `# ds-image: full` or the full image is already pulled, else **core**;
   - the current folder is mounted **at the same path**, read-write, and is the working directory;
   - any argument that is an absolute (or `../`) path outside it gets its folder mounted too;
   - files are created as your user (not root); the GPU render node (`/dev/dri`) is passed through when present.

No container runtime at all → scripts run natively, and each skill's check script prints install commands for your OS.

## `ds` commands

```bash
ds pull core                     # ≈1.2 GB — enough for graphic/photo/UI/type/print-PDF/video skills
ds pull full                     # ≈2.9 GB — adds Blender, GIMP, Krita, Scribus, darktable, melt
ds doctor                        # what's pulled, what's healthy
ds list                          # every skill script with its one-line description
ds graphic-design/optimize a.png # run a skill script (same as bash skills/graphic-design/scripts/optimize.sh a.png)
ds exec inkscape --version       # any tool in the image (full-only tools pick the full image)
ds exec blender -b scene.blend -a
ds shell [core|full]             # interactive shell, current folder mounted
ds image full                    # print the image reference
ds test                          # run the test suite inside the image
```

## Configuration (environment variables)

| Variable | Effect |
|---|---|
| `DS_RUNTIME=auto\|docker\|podman\|native` | Force a runtime; `native` uses tools installed on the host |
| `DS_VARIANT=core\|full` | Force an image variant |
| `DS_IMAGE=<ref>` · `DS_IMAGE_REPO` · `DS_IMAGE_TAG` | Use another image (a fork, a local build, a pinned digest) |
| `DS_MOUNTS="/data/assets /mnt/shared"` | Extra folders to mount (same path inside) |
| `DS_FONTS="/path/to/fonts"` | Extra font folders, registered for every tool (as `./fonts` is) |
| `DS_GPU=0` | Don't pass `/dev/dri` through |
| `DS_ENV="VAR1 VAR2"` | Extra environment variables to forward (QUALITY, FORMAT, WIDTH always are) |
| `DS_RUN_ARGS="…"` | Extra `run` flags, e.g. `--security-opt label=disable` (SELinux) or `--memory 8g --cpus 4` |

## Without Claude

```bash
docker run --rm -v "$PWD:/work" -w /work --user "$(id -u):$(id -g)" \
  ghcr.io/codeonym-oss/design-skills:0.1.0-core ds graphic-design/social-sizes banner.png
```
The image carries the skills at `/opt/design-skills` and `ds` on PATH.

## Troubleshooting

- **`permission denied … docker.sock`** → add yourself to the `docker` group (Linux) or use Podman rootless.
- **A file "doesn't exist" inside** → it's outside the current folder and wasn't a path argument; `cd` to a common parent or set `DS_MOUNTS`.
- **SELinux (Fedora/RHEL) denies access to mounted files** → `export DS_RUN_ARGS="--security-opt label=disable"`.
- **Windows** → run Claude Code and Docker inside WSL2; keep projects in the WSL filesystem for speed.
- **Slow first run** → the image is being pulled; `ds pull core` once up front.
- **Want your own installed tools** → `DS_RUNTIME=native`; `ds doctor --verbose` shows what's missing and how to install it.
- **Build the images yourself** → from the repo: `make build` (tags exactly what `ds` looks for), `make test`.
