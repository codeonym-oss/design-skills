#!/usr/bin/env bash
# Build a 50–950 color scale from one brand color (perceptual, OKLCH lightness steps).
# Usage: palette.sh '#2563EB' [name=brand] [outdir=.]
# Output: <name>-palette.css (CSS vars + Tailwind v4 @theme), <name>-palette.png (swatches)
set -euo pipefail
. "$(dirname "$(readlink -f "$0")")/../../../lib/env.sh"
hex=${1:-}; name=${2:-brand}; out=${3:-.}
[[ $hex =~ ^#?[0-9a-fA-F]{6}$ ]] || { echo "usage: $0 '#RRGGBB' [name] [outdir]" >&2; exit 2; }
mkdir -p "$out"

python3 - "$hex" "$name" "$out" <<'PY'
import sys, math, subprocess
hexc, name, out = sys.argv[1].lstrip('#'), sys.argv[2], sys.argv[3]

def srgb_to_lin(c): return c/12.92 if c <= 0.04045 else ((c+0.055)/1.055)**2.4
def lin_to_srgb(c):
    c = max(0.0, min(1.0, c))
    return 12.92*c if c <= 0.0031308 else 1.055*c**(1/2.4)-0.055

def hex_to_oklch(h):
    r, g, b = (srgb_to_lin(int(h[i:i+2], 16)/255) for i in (0, 2, 4))
    l = 0.4122214708*r + 0.5363325363*g + 0.0514459929*b
    m = 0.2119034982*r + 0.6806995451*g + 0.1073969566*b
    s = 0.0883024619*r + 0.2817188376*g + 0.6299787005*b
    l, m, s = (x ** (1/3) for x in (l, m, s))
    L = 0.2104542553*l + 0.7936177850*m - 0.0040720468*s
    a = 1.9779984951*l - 2.4285922050*m + 0.4505937099*s
    bb = 0.0259040371*l + 0.7827717662*m - 0.8086757660*s
    return L, math.hypot(a, bb), math.atan2(bb, a)

def oklch_to_rgb(L, C, H):
    a, b = C*math.cos(H), C*math.sin(H)
    l = (L + 0.3963377774*a + 0.2158037573*b) ** 3
    m = (L - 0.1055613458*a - 0.0638541728*b) ** 3
    s = (L - 0.0894841775*a - 1.2914855480*b) ** 3
    r = 4.0767416621*l - 3.3077115913*m + 0.2309699292*s
    g = -1.2684380046*l + 2.6097574011*m - 0.3413193965*s
    bl = -0.0041960863*l - 0.7034186147*m + 1.7076147010*s
    return r, g, bl

def in_gamut(rgb): return all(-1e-4 <= c <= 1+1e-4 for c in rgb)

def to_hex(L, C, H):
    # Reduce chroma until the color fits in sRGB.
    while C > 0 and not in_gamut(oklch_to_rgb(L, C, H)):
        C -= 0.002
    return '#' + ''.join(f'{round(lin_to_srgb(c)*255):02x}' for c in oklch_to_rgb(L, max(C, 0), H))

L0, C0, H0 = hex_to_oklch(hexc)
steps = {50: .97, 100: .93, 200: .87, 300: .79, 400: .70, 500: .62, 600: .54, 700: .46, 800: .38, 900: .30, 950: .22}
# Chroma tapers toward the light and dark ends like hand-made scales.
scale = {k: to_hex(L, C0 * (1 - abs(L - 0.6) * 0.9), H0) for k, L in steps.items()}

css = [f'/* {name} scale generated from #{hexc} */', ':root {']
css += [f'  --{name}-{k}: {v};' for k, v in scale.items()]
css += ['}', '', '/* Tailwind v4 */', '@theme {']
css += [f'  --color-{name}-{k}: {v};' for k, v in scale.items()]
css += ['}']
open(f'{out}/{name}-palette.css', 'w').write('\n'.join(css) + '\n')

font = subprocess.run(['fc-match', '-f', '%{file}', 'Inter:medium'], capture_output=True, text=True).stdout.strip()
args = ['magick']
for k, v in scale.items():
    fg = '#000' if steps[k] > 0.6 else '#fff'
    args += ['(', '-size', '120x120', f'xc:{v}', *(['-font', font] if font else []), '-fill', fg, '-pointsize', '16', '-gravity', 'center',
             '-annotate', '+0-10', str(k), '-annotate', '+0+14', v, ')']
args += ['+append', '+repage', f'{out}/{name}-palette.png']
subprocess.run(args, check=True)

for k, v in scale.items(): print(f'  {name}-{k:<4} {v}')
print(f'✔ {out}/{name}-palette.css  ✔ {out}/{name}-palette.png')
PY
