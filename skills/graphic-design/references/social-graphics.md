# Social media & banner graphics

## Size table (used by `scripts/social-sizes.sh`)
| Name | Size | Notes |
|---|---|---|
| instagram-square | 1080×1080 | feed |
| instagram-portrait | 1080×1350 | best feed reach |
| story-reel | 1080×1920 | keep text inside the middle 1080×1420 |
| linkedin-post | 1200×1200 | |
| linkedin-banner | 1584×396 | profile photo covers the bottom-left |
| x-post | 1600×900 | 16:9 |
| x-header | 1500×500 | avatar covers bottom-left, crops top/bottom on mobile |
| youtube-thumbnail | 1280×720 | readable at 160 px wide |
| youtube-banner | 2560×1440 | safe area for all devices: centered 1546×423 |
| og-image | 1200×630 | link previews (portfolio, blog posts) |
| github-social | 1280×640 | repo *Settings → Social preview* |

## Workflow
1. **Master in Inkscape** at the largest ratio you need (e.g. 1920×1080), text as live text.
2. Create one page per format (*Document Properties → Pages*, add pages with the sizes above) and copy the layout onto each, re-arranging instead of just scaling. Or, for simple centered compositions, export one master PNG and run:
   ```bash
   bash <skill-dir>/scripts/social-sizes.sh post.png          # crop to fill every format
   bash <skill-dir>/scripts/social-sizes.sh post.png --fit --bg '#0d1117'   # letterbox instead
   ```
3. Photos behind text: prepare them in GIMP, darken/blur the area under the text (*Filters → Blur → Gaussian*, or a 60 % black gradient layer).
4. Export, then `bash <skill-dir>/scripts/optimize.sh export/social/*.png`.

## Design rules that make posts read
- One message per graphic. Headline ≤ 7 words.
- Text size: the headline should be readable at thumbnail size — test by zooming Inkscape to 25 %.
- Contrast ≥ 4.5:1 between text and background.
- Stay 5 % away from every edge; platforms crop.
- Reuse 2 fonts and 3 colors across a series so posts are recognizable in the feed.

## YouTube thumbnail recipe
Face or key visual on one side (≥ 40 % height), 3–4 word hook on the other, one saturated accent color, outline or drop shadow on text. Build it in GIMP: cut out the subject with *Tools → Selection → Foreground Select*, add an outer glow with *Filters → Light and Shadow → Drop Shadow*.
