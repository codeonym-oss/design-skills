#!/usr/bin/env bats
# bats file_tags=full
load helpers

cube_obj() {
  cat >"${1:-cube.obj}" <<'EOF'
o Cube
v -1 -1 -1
v 1 -1 -1
v 1 1 -1
v -1 1 -1
v -1 -1 1
v 1 -1 1
v 1 1 1
v -1 1 1
f 1 2 3 4
f 5 8 7 6
f 1 5 6 2
f 2 6 7 3
f 3 7 8 4
f 5 1 4 8
EOF
}

@test "3d-modeling: check passes (glTF add-on present)" {
  run ds 3d-modeling/check
  echo "$output"
  [ "$status" -eq 0 ]
  [[ "$output" == *"io_scene_gltf2"* ]]
}

@test "convert-model: OBJ → GLB → STL, Draco makes GLB smaller" {
  cube_obj
  run ds 3d-modeling/convert-model cube.obj cube.glb
  [ "$status" -eq 0 ]
  [ "$(head -c 4 cube.glb)" = glTF ]
  run ds 3d-modeling/convert-model cube.glb out/cube.stl
  [ "$status" -eq 0 ]
  [ -s out/cube.stl ]
  run ds 3d-modeling/convert-model cube.obj cube-draco.glb --draco
  [ "$status" -eq 0 ]
  grep -q KHR_draco_mesh_compression cube-draco.glb
}

@test "convert-model: odd file names are passed safely" {
  cube_obj "it's a cube.obj"
  run ds 3d-modeling/convert-model "it's a cube.obj" "it's a cube.ply"
  [ "$status" -eq 0 ]
  [ -s "it's a cube.ply" ]
}

@test "mockup.py: a flat design becomes a rendered 3D mockup" {
  magick -size 600x800 gradient:'#2563eb-#f97316' poster.png
  run bash "$SK/3d-modeling/scripts/blender.sh" -b --factory-startup -P "$SK/3d-modeling/scripts/mockup.py" -- \
      --image poster.png --out mock.png --res 320x180 --samples 4 --save mock.blend
  echo "$output" | tail -5
  [ "$status" -eq 0 ]
  [ "$(dims mock.png)" = 320x180 ]
  [ -s mock.blend ]
}

@test "turntable.py + render.sh --anim: frames encoded into an MP4" {
  cube_obj
  run bash "$SK/3d-modeling/scripts/blender.sh" -b --factory-startup -P "$SK/3d-modeling/scripts/turntable.py" -- \
      --model cube.obj --frames 6 --res 160x90 --samples 2 --save tt.blend
  [ "$status" -eq 0 ]
  run ds 3d-modeling/render tt.blend --anim --out renders
  echo "$output" | tail -5
  [ "$status" -eq 0 ]
  [ "$(ls renders/tt_*.png | wc -l)" -eq 6 ]
  [ "$(codec_of renders/tt.mp4)" = h264 ]
}

@test "render.sh: a single still with Cycles on CPU" {
  cube_obj
  bash "$SK/3d-modeling/scripts/blender.sh" -b --factory-startup -P "$SK/3d-modeling/scripts/turntable.py" -- \
      --model cube.obj --frames 2 --save s.blend >/dev/null 2>&1
  run ds 3d-modeling/render s.blend --engine cycles --samples 2 --res 128x72 --frame 1 --out stills
  [ "$status" -eq 0 ]
  [ "$(dims stills/s_0001.png)" = 128x72 ]
}

@test "render.sh: settings are validated, never injected into Python" {
  cube_obj
  bash "$SK/3d-modeling/scripts/blender.sh" -b --factory-startup -P "$SK/3d-modeling/scripts/turntable.py" -- \
      --model cube.obj --frames 2 --save v.blend >/dev/null 2>&1
  run ds 3d-modeling/render v.blend --samples "1'); import os; os.system('touch pwned'); ('"
  [ "$status" -eq 2 ]
  run ds 3d-modeling/render v.blend --engine luxcore
  [ "$status" -eq 2 ]
  [ ! -e pwned ]
}
