# Issue tracker (for agents and contributors)

Work is tracked in **GitHub Issues** on this repo; the
[codeonym-oss board](https://github.com/orgs/codeonym-oss/projects) shows it across the organization's repos.

- **Milestones** map to releases (`v0.1.1 — Pro distribution`, `v0.2.0 — More headless skills`, …).
- **Issue type**: `Feature`, `Improvement`, `Bug` or `Task` (set on the issue, not as a label).
- **Labels**: one `area: …` (`skills`, `image`, `ci-release`, `docs`), optionally `priority: medium|low`.
- **Status** lives on the board: Backlog → Todo → In Progress → In Review → Done. Merging a PR that says
  `Fixes #<n>` closes the issue, and the board moves it to *Done*.

## Working an issue

1. Branch from `main` named after the issue, e.g. `18-diagrams-skill` (or *Create a branch* on the issue page).
2. PR title = conventional commit (`feat(diagrams): …`); PR body contains `Fixes #18`
   (several issues: one `Fixes #n` line each).
3. CI must pass (lint + unit, image build-test core/full × amd64/arm64, PR title); squash-merge.
4. release-please picks the commit up for the next release PR — no manual version bumps.

Issues were tracked in Linear until v0.1.1. Older commits and PRs mention `COD-<n>`: `COD-17` is now #10,
`COD-11`…`COD-16` keep their number (#11…#16), and `COD-18`…`COD-23` are #17…#22. Each migrated issue names its
old id at the bottom.
