"""360° turntable of a 3D model — for portfolio shots and client previews.

Imports a model (.glb/.gltf/.obj/.fbx/.stl or .blend), centers and scales it,
adds a studio (floor + 3 area lights + camera) and animates a full rotation.

Usage:
  blender -b --factory-startup -P turntable.py -- --model chair.glb [--frames 120]
          [--bg '#e4e4e7'] [--engine eevee|cycles] [--samples 32] [--res 1280x720]
          [--save turntable.blend] [--render]
Without --render it only saves the .blend (then use render.sh --anim for an MP4).
"""
import argparse
import math
import os
import sys

import bpy
from mathutils import Vector

argv = sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else []
ap = argparse.ArgumentParser()
ap.add_argument("--model", required=True)
ap.add_argument("--frames", type=int, default=120)
ap.add_argument("--bg", default="#e4e4e7")
ap.add_argument("--engine", default="eevee", choices=["eevee", "cycles"])
ap.add_argument("--samples", type=int, default=32)
ap.add_argument("--res", default="1280x720")
ap.add_argument("--save", default="turntable.blend")
ap.add_argument("--render", action="store_true")
a = ap.parse_args(argv)

path = os.path.abspath(a.model)
ext = os.path.splitext(path)[1].lower()

# Start from an empty scene (factory startup has a cube, light and camera).
for o in list(bpy.data.objects):
    bpy.data.objects.remove(o, do_unlink=True)
scene = bpy.context.scene

importers = {
    ".glb": lambda: bpy.ops.import_scene.gltf(filepath=path),
    ".gltf": lambda: bpy.ops.import_scene.gltf(filepath=path),
    ".obj": lambda: bpy.ops.wm.obj_import(filepath=path),
    ".fbx": lambda: bpy.ops.import_scene.fbx(filepath=path),
    ".stl": lambda: bpy.ops.wm.stl_import(filepath=path),
    ".ply": lambda: bpy.ops.wm.ply_import(filepath=path),
}
if ext == ".blend":
    with bpy.data.libraries.load(path) as (src, dst):
        dst.objects = [n for n in src.objects]
    for o in dst.objects:
        if o is not None and o.type in {"MESH", "CURVE", "EMPTY"}:
            scene.collection.objects.link(o)
elif ext in importers:
    importers[ext]()
else:
    sys.exit(f"unsupported model type: {ext}")

meshes = [o for o in scene.objects if o.type == "MESH"]
if not meshes:
    sys.exit("no mesh objects found in model")

# Parent everything to a pivot, then normalize size and position.
pivot = bpy.data.objects.new("Pivot", None)
scene.collection.objects.link(pivot)
for o in list(scene.objects):
    if o is not pivot and o.parent is None:
        o.parent = pivot

bpy.context.view_layer.update()
corners = [o.matrix_world @ Vector(c) for o in meshes for c in o.bound_box]
lo = Vector((min(c.x for c in corners), min(c.y for c in corners), min(c.z for c in corners)))
hi = Vector((max(c.x for c in corners), max(c.y for c in corners), max(c.z for c in corners)))
size = max(hi - lo)
scale = 2.0 / size if size else 1.0
center = (lo + hi) / 2
for o in pivot.children:
    o.location -= Vector((center.x, center.y, lo.z))
pivot.scale = (scale,) * 3


def hex_rgba(h):
    h = h.lstrip("#")
    srgb = [int(h[i:i + 2], 16) / 255 for i in (0, 2, 4)]
    return (*[c / 12.92 if c <= 0.04045 else ((c + 0.055) / 1.055) ** 2.4 for c in srgb], 1.0)


# Floor + world
bpy.ops.mesh.primitive_plane_add(size=50)
fmat = bpy.data.materials.new("Floor")
fmat.use_nodes = True
fmat.node_tree.nodes["Principled BSDF"].inputs["Base Color"].default_value = hex_rgba(a.bg)
bpy.context.active_object.data.materials.append(fmat)
world = bpy.data.worlds.new("World")
scene.world = world
world.use_nodes = True
world.node_tree.nodes["Background"].inputs["Color"].default_value = hex_rgba(a.bg)
world.node_tree.nodes["Background"].inputs["Strength"].default_value = 0.5

for name, loc, energy, rot in [("Key", (-3, -4, 4), 800, (50, 0, -35)),
                               ("Fill", (4, -3, 2), 250, (70, 0, 55)),
                               ("Rim", (0, 4, 3.5), 450, (-55, 0, 180))]:
    ld = bpy.data.lights.new(name, "AREA")
    ld.energy, ld.size = energy, 3
    lo_ = bpy.data.objects.new(name, ld)
    lo_.location, lo_.rotation_euler = loc, [math.radians(r) for r in rot]
    scene.collection.objects.link(lo_)

# Camera looking at the model's middle
target = bpy.data.objects.new("Target", None)
target.location = (0, 0, 1.0 * (hi.z - lo.z) * scale / 2)
scene.collection.objects.link(target)
cd = bpy.data.cameras.new("Camera")
cd.lens = 50
cam = bpy.data.objects.new("Camera", cd)
cam.location = (0, -6.5, 2.4)
scene.collection.objects.link(cam)
tc = cam.constraints.new("TRACK_TO")
tc.target, tc.track_axis, tc.up_axis = target, "TRACK_NEGATIVE_Z", "UP_Y"
scene.camera = cam

# Linear 360° spin
scene.frame_start, scene.frame_end = 1, a.frames
pivot.rotation_euler = (0, 0, 0)
pivot.keyframe_insert("rotation_euler", index=2, frame=1)
pivot.rotation_euler = (0, 0, math.radians(360))
pivot.keyframe_insert("rotation_euler", index=2, frame=a.frames + 1)
action = pivot.animation_data.action
try:
    curves = action.fcurves
except AttributeError:  # layered actions (Blender 4.4+/5.x)
    curves = [fc for layer in action.layers for strip in layer.strips
              for bag in strip.channelbags for fc in bag.fcurves]
for fc in curves:
    for kp in fc.keyframe_points:
        kp.interpolation = "LINEAR"

rw, rh = (int(v) for v in a.res.split("x"))
scene.render.resolution_x, scene.render.resolution_y = rw, rh
scene.render.resolution_percentage = 100
scene.render.fps = 30
scene.view_settings.view_transform = "AgX"
if a.engine == "cycles":
    scene.render.engine = "CYCLES"
    scene.cycles.device, scene.cycles.samples, scene.cycles.use_denoising = "CPU", a.samples, True
else:
    scene.render.engine = "BLENDER_EEVEE"
    scene.eevee.taa_render_samples = a.samples
scene.render.image_settings.file_format = "PNG"

bpy.ops.wm.save_as_mainfile(filepath=os.path.abspath(a.save))
print(f"TURNTABLE saved {os.path.abspath(a.save)} ({a.frames} frames)")
if a.render:
    scene.render.filepath = os.path.join(os.path.dirname(os.path.abspath(a.save)), "renders",
                                         os.path.splitext(os.path.basename(a.save))[0] + "_")
    bpy.ops.render.render(animation=True)
