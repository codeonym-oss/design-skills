# Font pairing & hierarchy (with fonts already installed)

## Proven pairings from the installed set
| Vibe | Headings | Body | Code / data |
|---|---|---|---|
| Modern product / SaaS | Inter (600–700) | Inter (400) | JetBrains Mono |
| Technical, engineered | IBM Plex Sans (600) | IBM Plex Sans (400) | IBM Plex Mono |
| Editorial / blog | IBM Plex Serif (600) | Source Sans 3 (400) | IBM Plex Mono |
| Warm & readable docs | Inter (700) | Noto Serif (400) | Fira Code |
| Neutral corporate | Roboto (500) | Open Sans (400) | Roboto Mono |

Compare any pairing before committing:
```bash
bash <skill-dir>/scripts/font-specimen.sh "IBM Plex Sans" "IBM Plex Serif" "JetBrains Mono" -t "Agents that level up" -o pairing.png
```

## Pairing rules
- **Contrast, not conflict**: pair a sans with a serif, or one family in two weights. Two different sans-serifs usually look like a mistake.
- Match **x-height** roughly so mixed lines look even.
- Superfamilies (IBM Plex, Source, Noto) pair safely with themselves.

## Hierarchy with one family
Use size + weight + color, in that order:
- H1 700 · H2 600 · H3 600 · body 400 · meta 400 in muted gray · labels 500 uppercase with +0.05em tracking.
- Scale ratio 1.25 (see `ui-design` skill → `design-tokens.md` for the table).

## Readability checklist
- Body ≥ 16 px screen / 10–11 pt print.
- Line-height: 1.5 body, 1.1–1.25 headings.
- 60–75 characters per line.
- Headings: tighten tracking slightly (−0.01 to −0.02em) at large sizes, especially Inter.
- Never fake bold/italic — use real weights (all families listed above ship them).
- Inter: enable `font-feature-settings: "cv11", "ss01"` for single-storey a and open digits if you like a friendlier look; `tnum` for tables.

## Monospace choice
JetBrains Mono (tall x-height, great at small sizes) · Fira Code (ligatures) · IBM Plex Mono (matches Plex UI). Use ligatures in the editor, turn them off in documentation screenshots aimed at beginners.
