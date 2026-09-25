#!/usr/bin/env bash
# ds-image: full
# Convert 3D models between formats with Blender (headless).
# Usage: convert-model.sh <in.(blend|glb|gltf|obj|fbx|stl|ply)> <out.(glb|gltf|obj|fbx|stl|ply)> [--draco]
#   --draco compresses glTF meshes (much smaller files for three.js / the web).
set -euo pipefail
. "$(dirname "$(readlink -f "$0")")/../../../lib/env.sh"
in=${1:-}; out=${2:-}
[[ -f $in && -n $out ]] || { sed -n '3,5p' "$0"; exit 2; }
draco=0; [[ ${3:-} == --draco ]] && draco=1
mkdir -p "$(dirname "$out")"

# Paths go in as arguments (after --), never pasted into the Python source.
blender -b --factory-startup --python-expr '
import bpy, os, sys
src, dst, draco = sys.argv[sys.argv.index("--") + 1:]
src, dst, draco = os.path.abspath(src), os.path.abspath(dst), draco == "1"
ie, oe = os.path.splitext(src)[1].lower(), os.path.splitext(dst)[1].lower()
if ie == ".blend":
    bpy.ops.wm.open_mainfile(filepath=src)
else:
    bpy.ops.wm.read_factory_settings(use_empty=True)
    {".glb": lambda: bpy.ops.import_scene.gltf(filepath=src),
     ".gltf": lambda: bpy.ops.import_scene.gltf(filepath=src),
     ".obj": lambda: bpy.ops.wm.obj_import(filepath=src),
     ".fbx": lambda: bpy.ops.import_scene.fbx(filepath=src),
     ".stl": lambda: bpy.ops.wm.stl_import(filepath=src),
     ".ply": lambda: bpy.ops.wm.ply_import(filepath=src)}[ie]()
{".glb": lambda: bpy.ops.export_scene.gltf(filepath=dst, export_format="GLB", export_draco_mesh_compression_enable=draco),
 ".gltf": lambda: bpy.ops.export_scene.gltf(filepath=dst, export_format="GLTF_SEPARATE", export_draco_mesh_compression_enable=draco),
 ".obj": lambda: bpy.ops.wm.obj_export(filepath=dst),
 ".fbx": lambda: bpy.ops.export_scene.fbx(filepath=dst),
 ".stl": lambda: bpy.ops.wm.stl_export(filepath=dst),
 ".ply": lambda: bpy.ops.wm.ply_export(filepath=dst)}[oe]()
print("CONVERTED", dst)
' -- "$in" "$out" "$draco" 2>&1 | grep -E '^CONVERTED|Error|KeyError' || true

[[ -f $out ]] && echo "✔ $out ($(numfmt --to=iec --suffix=B "$(stat -c %s "$out")"))" || { echo "✘ conversion failed" >&2; exit 1; }
