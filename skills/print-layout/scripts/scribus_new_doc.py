# Scribus script: create a print-ready document template (+ optional proof PDF).
# Run through new-print-doc.sh, which sets these environment variables:
#   DOC_W, DOC_H (mm) · DOC_PAGES · DOC_BLEED (mm) · DOC_MARGIN (mm)
#   DOC_OUT (.sla path) · DOC_PDF (optional proof path) · DOC_TITLE · DOC_FONT · DOC_BRAND (#RRGGBB)
import os
import scribus

w, h = float(os.environ["DOC_W"]), float(os.environ["DOC_H"])
pages = int(os.environ.get("DOC_PAGES", "1"))
bleed = float(os.environ.get("DOC_BLEED", "3"))
m = float(os.environ.get("DOC_MARGIN", "12"))
out, pdf_out = os.environ["DOC_OUT"], os.environ.get("DOC_PDF", "")
title = os.environ.get("DOC_TITLE", "Headline goes here")

scribus.newDocument((w, h), (m, m, m, m), scribus.PORTRAIT, 1,
                    scribus.UNIT_MILLIMETERS, scribus.PAGE_1, 0, pages)
scribus.setBleeds(bleed, bleed, bleed, bleed)



def hex_to_cmyk255(h):
    """Naive RGB → CMYK (0-255, the Scribus API scale). A starting point only: pick the final
    CMYK values from your printer's profile or a swatch book — screen colors print duller."""
    r, g, b = (int(h.lstrip("#")[i:i + 2], 16) / 255 for i in (0, 2, 4))
    k = 1 - max(r, g, b)
    if k >= 1:
        return 0, 0, 0, 255
    return tuple(round(255 * v) for v in ((1 - r - k) / (1 - k), (1 - g - k) / (1 - k), (1 - b - k) / (1 - k), k))


# Brand colors defined in CMYK.
scribus.defineColorCMYK("Brand", *hex_to_cmyk255(os.environ.get("DOC_BRAND", "#2563EB")))
scribus.defineColorCMYK("Ink", 191, 166, 127, 229)     # rich black for large areas
scribus.defineColorCMYK("Paper", 5, 3, 0, 0)

fonts = scribus.getFontNames()
def pick(*names):
    for n in names:
        if n in fonts:
            return n
    return None

head_font = pick(os.environ.get("DOC_FONT", "") + " Bold", "Inter Bold", "IBM Plex Sans Bold", "Source Sans 3 Bold")
body_font = pick(os.environ.get("DOC_FONT", "") + " Regular", "Inter Regular", "IBM Plex Sans Regular", "Source Sans 3 Regular")

for p in range(1, pages + 1):
    scribus.gotoPage(p)
    # Background runs into the bleed so trimming never shows white edges.
    bg = scribus.createRect(-bleed, -bleed, w + 2 * bleed, h * 0.45 + bleed, f"bg{p}")
    scribus.setFillColor("Brand", bg)
    scribus.setLineColor("None", bg)

    img = scribus.createImage(m, h * 0.45 + 8, w - 2 * m, h * 0.25, f"image{p}")

    head = scribus.createText(m, m + 10, w - 2 * m, h * 0.3, f"headline{p}")
    scribus.setText(title, head)
    if head_font:
        scribus.setFont(head_font, head)
    scribus.setFontSize(max(18, round(w / 6)), head)
    scribus.setTextColor("White", head)

    body = scribus.createText(m, h * 0.72 + 6, w - 2 * m, h * 0.28 - m - 6, f"body{p}")
    scribus.setText("Body copy. Replace with your text — keep important content inside the margins.", body)
    if body_font:
        scribus.setFont(body_font, body)
    scribus.setFontSize(10, body)
    scribus.setLineSpacing(14, body)
    scribus.setTextColor("Ink", body)

scribus.saveDocAs(out)

if pdf_out:
    pdf = scribus.PDFfile()
    pdf.file = pdf_out
    pdf.useDocBleeds = True
    pdf.cropMarks = True
    pdf.bleedMarks = False
    pdf.fontEmbedding = 0     # embed all fonts
    pdf.resolution = 300
    pdf.save()

scribus.closeDoc()
