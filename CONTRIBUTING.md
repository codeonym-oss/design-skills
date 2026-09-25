# Contributing

Issues and pull requests are welcome. The bar: **every script works the same for everyone**, and a test proves it.

## Setup

Docker (or Podman) and `bats` (or `npx`, used automatically). Then:

```bash
make build   # core + full images, tagged ghcr.io/codeonym-oss/design-skills:<VERSION>-{core,full}
make test    # unit + integration
```

Iterate on a script without rebuilding: the tests (and `ds`) mount this checkout into the image, so a rebuild is only
needed when the **Dockerfile** changes.

## Adding a script to a skill

1. `skills/<skill>/scripts/<name>.sh`, starting with:
   ```bash
   #!/usr/bin/env bash
   # ds-image: full            ← only if it needs Blender/GIMP/Krita/Scribus/darktable/melt
   # One-line description (shown by `ds list`).
   # Usage: <name>.sh <args>
   set -euo pipefail
   . "$(dirname "$(readlink -f "$0")")/../../../lib/env.sh"
   ```
   Desktop-only scripts (they must see the user's session) use `# ds-runtime: host` instead.
2. Write outputs next to the input (`export/`, `web/`) or, for many-input results (sheets, specimens, icon sets), in the
   working folder with an overridable name. Never overwrite inputs — scripts whose job is in-place editing
   (`strip-metadata.sh`) keep a backup by default. Print `✔ <output>` lines. Reject unknown options.
3. Add a test in `tests/integration/<skill>.bats` with a generated fixture (see `helpers.bash`); tag it
   `# bats test_tags=full` if it needs the full image.
4. Document it in the skill's `SKILL.md` table — `tests/unit/repo.bats` fails on undocumented or missing scripts.

## Adding a tool to the image

1. Add the apt package to `docker/Dockerfile` (`core-tools` if it's small and broadly useful, else `full-tools`).
   Upstream binaries must be pinned by version **and** sha256 for both amd64 and arm64 (see oxipng).
2. Check it in the relevant `check.sh` (`tool` = required, `full_tool` = full image only, `optional` = desktop app).
3. Add its install names to `lib/packages.tsv` (apt, pacman, dnf, brew) so native users get install hints.
4. If it only exists in the full image, add it to `DS_FULL_TOOLS` in `lib/ds.sh` so `ds exec` picks the right image.

## Adding a skill

`skills/<name>/SKILL.md` (frontmatter `name` = folder name, a specific `description` saying when to use it),
`scripts/check.sh`, and register `./skills/<name>` in `.claude-plugin/plugin.json`.

## Host-side code must run on macOS

`bin/ds`, `lib/ds.sh` and `lib/env.sh` run on the user's machine before the container starts: keep them bash 3.2
compatible (no `${x,,}`, `declare -A`, `mapfile`; expand possibly-empty arrays as `${a[@]+"${a[@]}"}`) and avoid
GNU-only flags (`readlink -f` is fine: macOS 12.3+). `make test-bash32` checks the bash syntax on BusyBox tools.
Forwarded environment variables a script reads must be listed in `DS_PASS_ENV` (`lib/ds.sh`).

## Releasing

1. Bump `VERSION` and `version` in `.claude-plugin/plugin.json` (a unit test keeps them equal); add a `CHANGELOG.md` entry.
2. Merge to `main` (publishes `:edge-*`), then tag `vX.Y.Z` — CI builds amd64 + arm64, runs the integration suite
   in each image, pushes `:X.Y.Z-core/-full` + moving tags, and creates the GitHub release.
