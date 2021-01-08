# -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- #
# Raylib Forever basic usage sample
# Developed in 2*20 by Guevara-chan
# Adapted in 2021 by greenfork
# -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- #

import ../../src/nimraylib_now/[raylib, raygui]

initWindow 800, 600, "[nim]RaylibNow!"
60.setTargetFPS

# Camera setup.
var camera = Camera(
  position: (x: 0f, y: 10f, z: -15f),
  up: (x: 0f, y: 0.5f, z: 0f),
  fovy: 45f
)
camera.setCameraMode Orbital

# ==Main code==
while not windowShouldClose():
  camera.addr.updateCamera
  beginDrawing()
  label (x: 10f, y: 0f, width: 100f, height: 25f), "by V.A. Guevara"
  clearBackground(Black)
  beginMode3D(camera)
  drawGrid 10, 1.0f
  drawSphere (0f, 0f, 0f), 0.5f, Red
  endMode3D()
  let
    slogan = "/Hello from Nim/"
    size = 20.int32
    width = measureText(slogan, size)
  slogan.drawText(
    (getScreenWidth() - width) div 2,
    getScreenHeight() div 2 - 100,
    size,
    LightGray
  )
  drawRectangleV(
    (x: 10f, y: 10f),
    (x: (getScreenWidth() - 20).float32, y: (getScreenHeight() - 20).float32),
    (r: 255, g: 0, b: 0, a: 20)
  )
  endDrawing()
