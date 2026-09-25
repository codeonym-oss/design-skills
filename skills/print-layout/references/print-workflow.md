# Print workflow: brief → printer

## 1. Specs first (ask the printer)
Final size, paper (coated/uncoated, gsm), bleed required (usually 3 mm), color profile (e.g. *PSO Coated v3 / FOGRA51* in Europe, *GRACoL* in the US), PDF standard (PDF/X-4 is common), and whether crop marks are wanted.

## 2. Start the document
```bash
bash <skill-dir>/scripts/new-print-doc.sh a5 event-flyer --title "Agents that level up" --font "IBM Plex Sans" --proof
scribus event-flyer.sla
```
Or by hand: *File → New*, set size, units mm, *Bleeds* 3 mm on all sides, margins 10–12 mm.

## 3. Build the layout in Scribus
| Task | How |
|---|---|
| Place an image | Image frame (I) → draw → right-click → *Get Image* (Ctrl+D). Right-click → *Adjust Image to Frame* |
| Text | Text frame (T) → double-click to type, or *Edit Text* (Ctrl+T) for the story editor |
| Styles | *Edit → Styles* (F3): make paragraph styles `H1`, `Body`, `Caption` — never format text by hand |
| Master pages | *Edit → Master Pages* for repeated headers, footers, page numbers (*Insert → Character → Page Number*) |
| Colors | *Edit → Colors and Fills*: define in CMYK; the template already has Brand, Ink, Paper |
| Align | *Windows → Align and Distribute* |
| Linked text | Link text frames (N) so text flows across columns/pages |
| Preview | *View → Preview Mode* hides guides; *Windows → Preflight Verifier* flags issues |

Artwork: make logos in Inkscape and save as PDF or SVG (text to paths), photos in GIMP/darktable exported as 300 ppi TIFF or JPEG q95.

## 4. Export the print PDF
*File → Export → Save as PDF*:
- **General**: Compatibility PDF/X-4 (or what the printer asked), resolution 300 dpi, compression *Lossless* or *Automatic* with max quality.
- **Fonts**: *Embed all*.
- **Pre-Press**: *Crop marks* ✔, *Use document bleeds* ✔, offset ≈ 3 mm.
- **Color**: Output intended for *Printer*, with the printer's ICC profile if you have it (put `.icc` files in `./icc` next to the project — FOGRA39/ISO Coated v2 ship with the image).

## 5. Check before sending
```bash
bash <skill-dir>/scripts/pdf-preflight.sh event-flyer.pdf      # boxes, fonts, image ppi
bash <skill-dir>/scripts/pdf-proof.sh event-flyer.pdf          # PNG proofs for you/the client
```
Look at the proof at 100 %: nothing important within 5 mm of the trim, no white edges, no low-res images.

## 6. Hand-off
Send the PDF, and for bigger jobs zip the `.sla` with *File → Collect for Output* (gathers fonts and images). Ask for a physical proof for large or expensive runs — screen and paper colors differ.

## Common sizes
| Item | Trim size | Notes |
|---|---|---|
| Business card (EU) | 85 × 55 mm | 4 mm safe margin |
| DL flyer | 99 × 210 mm | fits a DL envelope; tri-fold A4 panel size |
| A5 / A4 / A3 flyer & poster | 148×210 / 210×297 / 297×420 mm | |
| Poster 50 × 70 cm | 500 × 700 mm | 5 mm bleed, images ≥ 150 ppi fine at viewing distance |
| Roll-up banner | 850 × 2000 mm | ask printer for extra bottom bleed (often 100 mm) |

## Tri-fold brochure (A4 landscape → DL)
Page 297 × 210 mm, 2 pages. Column guides (*Page → Manage Guides*): panels at 99 / 99 / 97 mm — the inside-folding panel is 2 mm narrower so it folds cleanly.
