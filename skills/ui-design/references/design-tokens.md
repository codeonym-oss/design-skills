# Design tokens starter

## Spacing (4-pt base)
`0 · 2 · 4 · 8 · 12 · 16 · 20 · 24 · 32 · 40 · 48 · 64 · 80 · 96 · 128` px
Use 16 for default padding, 24 between related groups, 48–96 between page sections.

## Type scale (1.25 ratio, base 16 px, Inter)
| Token | Size / line-height | Weight | Use |
|---|---|---|---|
| display | 48 / 56 | 700 | hero |
| h1 | 39 / 48 | 700 | page title |
| h2 | 31 / 40 | 600 | section |
| h3 | 25 / 32 | 600 | card title |
| h4 | 20 / 28 | 600 | sub-section |
| body | 16 / 24 | 400 | text |
| small | 14 / 20 | 400 | meta, labels |
| caption | 12 / 16 | 500 | badges, hints |
| code | 14 / 20 | 400 | JetBrains Mono |

Line length: 60–75 characters for body text (`max-w-prose`).

## Radius
`none 0 · sm 4 · md 8 · lg 12 · xl 16 · full 9999` — pick one default (8) and use it everywhere.

## Elevation
| Token | Shadow |
|---|---|
| sm | `0 1px 2px rgb(0 0 0 / .06)` |
| md | `0 4px 12px rgb(0 0 0 / .08)` |
| lg | `0 12px 32px rgb(0 0 0 / .12)` |
Dark mode: prefer lighter surfaces (e.g. gray-900 → gray-800) over shadows.

## Color roles (map the generated scales)
| Role | Light | Dark |
|---|---|---|
| background | white | gray-950 |
| surface | gray-50 | gray-900 |
| border | gray-200 | gray-800 |
| text | gray-900 | gray-50 |
| text-muted | gray-600 | gray-400 |
| primary | brand-600 | brand-400 |
| primary-hover | brand-700 | brand-300 |

## Into Tailwind v4 (`app/globals.css`)
```css
@import "tailwindcss";
/* paste the @theme block printed by scripts/palette.sh for brand and gray */
@theme {
  --font-sans: "Inter", ui-sans-serif, system-ui, sans-serif;
  --font-mono: "JetBrains Mono", ui-monospace, monospace;
  --radius-md: 0.5rem;   /* use rounded-md as the default */
}
```
