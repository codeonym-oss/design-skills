# UI design workflow

## 1. Brief & flows
- Who is the user, what is the one job of this screen/app?
- List the user flows (sign up, main task, settings). Draw them as boxes and arrows — Penpot/Lunacy both have flowchart shapes, or use paper.

## 2. Wireframes (low-fi, grayscale)
- Frames: **Desktop 1440×1024**, **Mobile 390×844**.
- Only gray boxes, real-ish text (no lorem for headings), one font (Inter).
- Layout grid: 12 columns, 24 px gutter, 80 px margins (desktop); 4 columns, 16 px gutter/margins (mobile).
- Goal: hierarchy and flow, not beauty. Review with the flows from step 1.

## 3. Design system (before hi-fi)
Create a separate page named `Design System`:
1. **Color**: brand scale via `bash <skill-dir>/scripts/palette.sh '#2563EB' brand`, plus a neutral scale (`<skill-dir>/scripts/palette.sh '#64748b' gray`), success/warning/danger. Import the hex values as document colors (Lunacy: *Colors* panel; Penpot: *Assets → Colors*).
2. **Type scale**: see `design-tokens.md`. Create text styles (H1–H4, body, small, caption, code).
3. **Spacing & radius** tokens.
4. **Components** with variants: Button (primary/secondary/ghost × sm/md/lg × default/hover/disabled), Input, Select, Checkbox, Card, Navbar, Modal, Toast. In Lunacy: select → *Create Component* (Ctrl+Alt+K); Penpot: Ctrl+K.

## 4. High fidelity
Assemble screens from components only. If you need a new pattern, make it a component first. Use **auto layout** (Lunacy: Shift+A; Penpot: Ctrl+Shift+A) for everything that stacks — it is what makes designs map cleanly to flexbox.

## 5. Prototype
Link frames with interactions (click → navigate, overlay for modals). Present in browser (Penpot *View mode*) to test the flow with someone for 5 minutes.

## 6. Handoff to code (Next.js + Tailwind)
- Export tokens: `<skill-dir>/scripts/palette.sh` already emits a Tailwind v4 `@theme` block — paste into `app/globals.css`.
- Icons: export as SVG (plain) from Inkscape/Lunacy; for React, inline them or use `lucide-react` when a matching icon exists.
- Penpot *Inspect* tab gives CSS for any layer; Lunacy has *Inspect* on the right panel too.
- Favicons & app icons: `bash <skill-dir>/scripts/icon-set.sh logo-mark.svg public --bg '#0d1117' --name 'My App'`.

## Where to start in Lunacy
Built-in *Graphics* panel (left) has free icons, illustrations and photos — drag in directly. *File → Import* opens `.fig` files from Figma community kits.
