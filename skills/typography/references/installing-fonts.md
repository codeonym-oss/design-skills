# Adding fonts

## In the design container (what the skill scripts use)
- **Project fonts:** put `.ttf` / `.otf` / `.ttc` files in `./fonts` (next to your design files). Every tool in the
  container sees them automatically — Inkscape, ImageMagick, Scribus, Blender, specimens.
- **A shared font folder:** `export DS_FONTS=/path/to/brand-fonts` (several folders separated by spaces).
- **Google Fonts:** download the family from https://fonts.google.com (or the files from https://github.com/google/fonts)
  into `./fonts`. Variable fonts (e.g. `Inter[opsz,wght].ttf`) cover every weight in one file.

Verify:
```bash
bash <skill-dir>/scripts/font-inventory.sh "<family>"
bash <skill-dir>/scripts/font-specimen.sh "<family>" -o check.png
```

## On your desktop (for GUI apps: GIMP, Krita, Figma desktop…)
| OS | User install | System-wide |
|---|---|---|
| Linux | copy into `~/.local/share/fonts/<Family>/`, then `fc-cache -f` · or a font manager (GNOME Fonts, Font Manager) | distro packages, e.g. `apt install fonts-inter`, `pacman -S inter-font`, `dnf install rsms-inter-fonts` |
| macOS | double-click → *Install* in Font Book (goes to `~/Library/Fonts`) | Font Book → *Install for all users* · `brew install --cask font-inter` |
| Windows | right-click → *Install* | right-click → *Install for all users* |

Restart apps like Inkscape, GIMP, Krita and Scribus to see new fonts.

## Font manager tips (Font Manager / Font Book)
- Make one collection per project so you find its fonts quickly.
- *Disable* rarely used families instead of uninstalling to keep app font menus short.
- Compare mode previews the same text in several fonts — or use `font-specimen.sh` for a shareable PNG.

## Licensing quick guide
| License | Web embed | Desktop use | Modify |
|---|---|---|---|
| SIL OFL (Inter, IBM Plex, Source, Fira, JetBrains Mono, Noto) | ✔ | ✔ | ✔ (rename if distributing) |
| Apache 2.0 (Roboto, Open Sans) | ✔ | ✔ | ✔ |
| Commercial / "free for personal use" | Check EULA — often ✘ | often personal only | ✘ |

Don't commit commercial font files to public repos; keep them in a private `./fonts` or `DS_FONTS` folder.

## Web use
- Next.js: `next/font/local` pointing at WOFF2 files from `webfont.sh`, or `next/font/google` for Google-hosted families.
- Plain sites: `bash <skill-dir>/scripts/webfont.sh ./fonts/MyFont-*.ttf public/fonts` → include `public/fonts/fonts.css`.
- Prefer variable fonts for the web: one file, every weight.
