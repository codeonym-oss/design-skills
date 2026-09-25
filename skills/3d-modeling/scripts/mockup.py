"""Studio 3D mockup of a flat design (poster, card, cover, screenshot).

Builds a clean scene: your image on a thin slab with rounded corners, a soft
shadow-catching floor, three-point area lighting and a camera, then renders.

Usage:
  blender -b --factory-startup -P mockup.py -- --image design.png [--out mockup.png]
          [--style tilt|flat|lean] [--bg '#f4f4f5'] [--engine eevee|cycles]
          [--samples 64] [--res 1920x1080] [--save scene.blend]
"""
import argparse
import math
import os
import sys

import bpy

argv = sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else []
ap = argparse.ArgumentParser()
ap.add_argument("--image", required=True)
ap.add_argument("--out", default="mockup.png")
ap.add_argument("--style", default="tilt", choices=["tilt", "flat", "lean"])
ap.add_argument("--bg", default="#f4f4f5")
ap.add_argument("--engine", default="eevee", choices=["eevee", "cycles"])
ap.add_argument("--samples", type=int, default=64)
ap.add_argument("--res", default="1920x1080")
ap.add_argument("--save", default="")
a = ap.parse_args(argv)


def hex_rgba(h):
    h = h.lstrip("#")
    srgb = [int(h[i:i + 2], 16) / 255 for i in (0, 2, 4)]
    lin = [c / 12.92 if c <= 0.04045 else ((c + 0.055) / 1.055) ** 2.4 for c in srgb]
    return (*lin, 1.0)


# Start from an empty scene (factory startup has a cube, light and camera).
for o in list(bpy.data.objects):
    bpy.data.objects.remove(o, do_unlink=True)
scene = bpy.context.scene

# Image and aspect ratio
img = bpy.data.images.load(os.path.abspath(a.image))
iw, ih = img.size
aspect = iw / ih if ih else 1.0
height = 2.0
width = height * aspect

# Slab with the design on the front face
bpy.ops.mesh.primitive_cube_add(size=1)
slab = bpy.context.active_object
slab.name = "Design"
slab.scale = (width, 0.02, height)
bpy.ops.object.transform_apply(scale=True)
bev = slab.modifiers.new("Bevel", "BEVEL")
bev.width, bev.segments = 0.01, 4

mat = bpy.data.materials.new("DesignMat")
mat.use_nodes = True
nt = mat.node_tree
bsdf = nt.nodes["Principled BSDF"]
bsdf.inputs["Roughness"].default_value = 0.35
tex = nt.nodes.new("ShaderNodeTexImage")
tex.image = img
coord = nt.nodes.new("ShaderNodeTexCoord")
nt.links.new(tex.outputs["Color"], bsdf.inputs["Base Color"])
# Generated coords run 0..1 across the bounding box: X → u, Z → v.
mapping = nt.nodes.new("ShaderNodeMapping")
sep = nt.nodes.new("ShaderNodeSeparateXYZ")
comb = nt.nodes.new("ShaderNodeCombineXYZ")
nt.links.new(coord.outputs["Generated"], sep.inputs["Vector"])
nt.links.new(sep.outputs["X"], comb.inputs["X"])
nt.links.new(sep.outputs["Z"], comb.inputs["Y"])
nt.links.new(comb.outputs["Vector"], mapping.inputs["Vector"])
nt.links.new(mapping.outputs["Vector"], tex.inputs["Vector"])
slab.data.materials.append(mat)

# Floor that catches shadows, tinted with the background color
bpy.ops.mesh.primitive_plane_add(size=60, location=(0, 0, -height / 2 - 0.001))
floor = bpy.context.active_object
fmat = bpy.data.materials.new("Floor")
fmat.use_nodes = True
fmat.node_tree.nodes["Principled BSDF"].inputs["Base Color"].default_value = hex_rgba(a.bg)
fmat.node_tree.nodes["Principled BSDF"].inputs["Roughness"].default_value = 0.8
floor.data.materials.append(fmat)

# Pose
if a.style == "tilt":
    slab.rotation_euler = (0, 0, math.radians(-22))
elif a.style == "lean":
    slab.rotation_euler = (math.radians(-12), 0, math.radians(-8))
    slab.location.y = 0.25

# World: soft background of the same color
world = bpy.data.worlds.new("World")
scene.world = world
world.use_nodes = True
world.node_tree.nodes["Background"].inputs["Color"].default_value = hex_rgba(a.bg)
world.node_tree.nodes["Background"].inputs["Strength"].default_value = 0.6


def area_light(name, loc, energy, size, rot):
    data = bpy.data.lights.new(name, "AREA")
    data.energy, data.size = energy, size
    obj = bpy.data.objects.new(name, data)
    obj.location = loc
    obj.rotation_euler = [math.radians(r) for r in rot]
    scene.collection.objects.link(obj)


area_light("Key", (-4, -5, 4), 900, 4, (55, 0, -40))
area_light("Fill", (5, -4, 1.5), 300, 5, (75, 0, 50))
area_light("Rim", (2, 5, 4), 500, 3, (-50, 0, 160))

# Camera framing the design
cam_data = bpy.data.cameras.new("Camera")
cam_data.lens = 70
cam = bpy.data.objects.new("Camera", cam_data)
scene.collection.objects.link(cam)
scene.camera = cam
dist = max(width, height) * 4.2
cam.location = (dist * 0.18, -dist, height * 0.12)
track = cam.constraints.new("TRACK_TO")
track.target = slab
track.track_axis, track.up_axis = "TRACK_NEGATIVE_Z", "UP_Y"

# Render settings
rw, rh = (int(v) for v in a.res.split("x"))
scene.render.resolution_x, scene.render.resolution_y = rw, rh
scene.render.resolution_percentage = 100
scene.view_settings.view_transform = "AgX"
if a.engine == "cycles":
    scene.render.engine = "CYCLES"
    scene.cycles.device = "CPU"
    scene.cycles.samples = a.samples
    scene.cycles.use_denoising = True
else:
    scene.render.engine = "BLENDER_EEVEE"
    scene.eevee.taa_render_samples = a.samples
scene.render.image_settings.file_format = "PNG"
scene.render.filepath = os.path.abspath(a.out)

if a.save:
    bpy.ops.wm.save_as_mainfile(filepath=os.path.abspath(a.save))
bpy.ops.render.render(write_still=True)
print(f"MOCKUP {scene.render.filepath}")
