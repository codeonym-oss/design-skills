# Issue tracker (for agents and contributors)

Work is tracked in **Linear**: workspace `codeonym`, team **Codeonym** (key `COD`), project
[design-skills](https://linear.app/codeonym/project/design-skills-368256c0108e).

- **Milestones** map to releases (`v0.2.0 — Pro distribution`, `v0.3.0 — More headless skills`, …).
- **Labels**: type (`Feature`, `Improvement`, `Bug`) + one `Area` (`skills`, `image`, `ci-release`, `docs`).
- **Statuses**: Backlog → Todo → In Progress → In Review → Done. The Linear GitHub integration moves issues
  automatically: a branch/PR that references `COD-<n>` → *In Progress*/*In Review*; merging → *Done*.

## Working an issue

1. Branch with Linear's generated name (issue → *Copy git branch name*), e.g.
   `bouarourayoub0/cod-18-new-skill-diagrams-…`.
2. PR title = conventional commit (`feat(diagrams): …`); PR body contains `Fixes COD-18`
   (several issues: one `Fixes COD-n` line each).
3. CI must pass (lint + unit, image build-test core/full × amd64/arm64, PR title); squash-merge.
4. release-please picks the commit up for the next release PR — no manual version bumps.

Public bug reports can also arrive as GitHub issues; triage them into Linear (the GitHub integration can
sync them) and link the Linear issue back.
