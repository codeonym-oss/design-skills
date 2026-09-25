---
name: ui-design
description: UI/UX and web/app interface design — wireframes and mockups in Penpot, Figma or Lunacy, design tokens (color scales, type, spacing) for Tailwind/CSS, and generated assets (favicons, app/PWA icons, web manifest) built headlessly in a reproducible container. Use when the user wants wireframes, app or website mockups, a design system (colors, type scale, spacing tokens), favicons/app icons/PWA icons, or wants to hand designs off to a Next.js/Tailwind codebase.
---

# UI design (Penpot · Figma · Lunacy · Inkscape)

Design apps run on the desktop or in the browser; the asset scripts run inside the design-skills container
automatically (`bash <skill-dir>/scripts/<name>.sh …`, see `design-sandbox`).

## Toolkit

| Tool | Use it for | Where |
|---|---|---|
| **Penpot** | Open-source, SVG-native design; CSS/SVG inspect for handoff; self-hostable | https://design.penpot.app |
| **Figma** | When a client/team already uses Figma | https://figma.com |
| **Lunacy** | Free offline desktop editor (Windows/macOS/Linux), opens `.fig` and `.sketch` | https://icons8.com/lunacy |
| **Inkscape 1.4** | Custom icons and illustrations as SVG | container: `inkscape` |
| **Color picker** | Pick colors anywhere on screen (HEX/RGB/OKLCH) | Eyedropper (Linux) · Digital Color Meter (macOS) · PowerToys Color Picker (Windows) |
| **Fonts** | Inter, IBM Plex, Roboto, Source Sans 3, JetBrains Mono… | `typography` skill |

An agent can also design directly in code: write the screen as HTML/Tailwind or SVG, render it, look at it, iterate.

## Scripts

| Script | What it does |
|---|---|
| `check.sh` | Verifies Inkscape, ImageMagick, oxipng, python3 and the UI fonts |
| `icon-set.sh <icon.svg> [outdir] [--bg '#0d1117'] [--name 'App']` | favicon.ico (16/32/48) + favicon.svg, apple-touch-icon, PWA 192/512 + maskable, 1024 master, `site.webmanifest`, `<head>` snippet |
| `palette.sh '#RRGGBB' [name] [outdir]` | 50–950 perceptual (OKLCH) scale → CSS variables, Tailwind v4 `@theme` block, swatch PNG |

## Guides

- `references/ui-workflow.md` — brief → wireframe → design system → hi-fi → prototype → handoff.
- `references/design-tokens.md` — spacing/type/radius scales and how to carry them into Next.js + Tailwind.

## Rules of thumb

1. Start grayscale and low-fi; add brand color only after layout and hierarchy work.
2. 8-pt spacing grid (4 for dense UI); 12 columns on desktop, 4 on mobile.
3. Build components (buttons, inputs, cards) with variants before assembling screens.
4. Every text/background pair ≥ 4.5:1 contrast (3:1 for large text).
5. Design mobile (390 px) and desktop (1440 px) frames for every key screen; support RTL layouts if the product ships in Arabic/Hebrew.
