<!-- Title: a conventional commit, e.g. "feat(typography): add variable-font axes to specimens".
     It becomes the squash commit and the changelog entry. Use feat!: / BREAKING CHANGE: for breaking changes. -->

## What and why

Fixes #<!-- issue number -->

## How it was tested

- [ ] `make test-unit`
- [ ] `make test-core` / `make test-full` (CI runs both on amd64 + arm64)
- [ ] New or changed scripts have integration tests and are documented in their `SKILL.md`
- [ ] Image changes: new tools are in `check.sh`, `lib/packages.tsv` (and `DS_FULL_TOOLS` if full-only)
