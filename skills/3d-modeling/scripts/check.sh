#!/usr/bin/env bash
# ds-image: full
# Check Blender and its headless render setup.
. "$(dirname "$(readlink -f "$0")")/../../../lib/check.sh"

section "Blender"
tool blender "Blender"
info "$(blender --version 2>/dev/null | head -1)"

section "Render setup"
report=$(blender -b --factory-startup --python-expr '
import bpy, addon_utils
p = bpy.context.preferences.addons["cycles"].preferences
for t in ("HIP", "ONEAPI", "CUDA", "OPTIX", "METAL"):
    try:
        p.compute_device_type = t
        p.get_devices()
        names = [d.name for d in p.devices if d.type == t]
        print("DEV", t, ", ".join(names) if names else "-")
    except Exception:
        print("DEV", t, "-")
print("ENG", ",".join(bpy.types.RenderSettings.bl_rna.properties["engine"].enum_items.keys()))
mods = {m.__name__.split(".")[-1] for m in addon_utils.modules()}
print("ADD", " ".join(a for a in ("io_scene_gltf2", "io_scene_fbx", "node_wrangler", "rigify") if a in mods))
' 2>/dev/null | grep -E '^(DEV|ENG|ADD) ')
gpu=$(awk '$1=="DEV" && $3!="-" {print $2": "substr($0, index($0,$3))}' <<<"$report")
if [[ -n $gpu ]]; then info "Cycles GPU: $gpu"; else info "Cycles on CPU ($(nproc) threads) — fine for mockups; use low samples + denoising"; fi
info "engines: $(awk '$1=="ENG" {print $2}' <<<"$report")"
info "add-ons: $(awk '$1=="ADD" {$1=""; print}' <<<"$report")"
[[ $report == *io_scene_gltf2* ]] || warn "glTF add-on missing — GLB import/export will fail"

section "Encoding animations"
tool ffmpeg "ffmpeg"

summary
