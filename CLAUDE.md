# design-skills — notes for Claude

- Public plugin `codeonym-oss` (skills are `codeonym-oss:<skill>`). Read `CONTRIBUTING.md` for how scripts,
  tools and skills are added; `README.md` for how the container dispatch works.
- Issues live in GitHub Issues on this repo (milestones = releases) — see `docs/agents/issue-tracker.md`.
- `main` is protected: work on a branch named after the issue (`<n>-short-name`), open a PR with a conventional-commit
  title and `Fixes #<n>`; never push to `main` or edit `VERSION`/`plugin.json` versions by hand (release-please does).
- Tests: `make test-unit` (fast, host), `make test-core` / `make test-full` (inside the images; `make build`
  first if the Dockerfile changed). Host-side code (`bin/ds`, `lib/ds.sh`, `lib/env.sh`) must stay bash 3.2
  compatible — `make test-bash32`.
