#!/usr/bin/env bash
# ds-image: full
# Render a .blend headlessly (still or animation).
# Usage: render.sh scene.blend [--engine eevee|cycles] [--samples N] [--res 1920x1080]
#                  [--frame N | --anim] [--out renders/]
# Animations render PNG frames, then encode an MP4 with ffmpeg (VAAPI when available).
set -euo pipefail
. "$(dirname "$(readlink -f "$0")")/../../../lib/env.sh"
blend=${1:-}; [[ -f $blend ]] || { sed -n '3,6p' "$0"; exit 2; }
shift
engine=; samples=; res=; frame=; anim=0; out=renders
while (($#)); do
  case $1 in
    --engine) engine=$2; shift ;;
    --samples) samples=$2; shift ;;
    --res) res=$2; shift ;;
    --frame) frame=$2; shift ;;
    --anim) anim=1 ;;
    --out) out=$2; shift ;;
    *) echo "unknown option $1" >&2; exit 2 ;;
  esac
  shift
done
mkdir -p "$out"
name=$(basename "${blend%.blend}")

py="import bpy
s = bpy.context.scene
eng = '${engine}'
if eng: s.render.engine = {'eevee': 'BLENDER_EEVEE', 'cycles': 'CYCLES'}[eng]
if s.render.engine == 'CYCLES':
    s.cycles.device = 'CPU'
    s.cycles.use_denoising = True
    if '${samples}': s.cycles.samples = int('${samples}')
elif '${samples}':
    s.eevee.taa_render_samples = int('${samples}')
if '${res}':
    w, h = '${res}'.split('x'); s.render.resolution_x, s.render.resolution_y = int(w), int(h)
    s.render.resolution_percentage = 100
s.render.image_settings.file_format = 'PNG'
print('RENDER', s.render.engine, s.render.resolution_x, s.render.resolution_y, s.frame_start, s.frame_end, s.render.fps)
"

start=$(date +%s)
if ((anim)); then
  blender -b "$blend" --python-expr "$py" -o "$(readlink -f "$out")/${name}_####" -a 2>&1 | grep -E '^RENDER|Saved|Error' | tail -3
  fps=$(blender -b "$blend" --python-expr 'import bpy; print("FPS", bpy.context.scene.render.fps)' 2>/dev/null | awk '/^FPS/{print $2}')
  sw=(-c:v libx264 -crf 18 -preset slow -pix_fmt yuv420p)
  enc=("${sw[@]}")
  if [[ -e /dev/dri/renderD128 ]] && [[ $(ffmpeg -hide_banner -encoders 2>/dev/null) == *h264_vaapi* ]]; then
    enc=(-vaapi_device /dev/dri/renderD128 -vf 'format=nv12,hwupload' -c:v h264_vaapi -qp 18)
  fi
  encode() {
    ffmpeg -y -loglevel error -framerate "${fps:-24}" -pattern_type glob -i "$out/${name}_*.png" \
      "$@" -movflags +faststart "$out/$name.mp4"
  }
  encode "${enc[@]}" 2>/dev/null || encode "${sw[@]}"
  echo "✔ $out/$name.mp4"
else
  blender -b "$blend" --python-expr "$py" -o "$(readlink -f "$out")/${name}_####" -f "${frame:-1}" 2>&1 | grep -E '^RENDER|Saved|Error' | tail -3
fi
echo "done in $(( $(date +%s) - start ))s"
