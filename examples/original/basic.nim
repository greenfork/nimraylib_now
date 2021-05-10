# -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- #
# Raylib Forever basic usage sample
# Developed in 2*20 by Guevara-chan
# Adapted in 2021 by greenfork
# -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- #

import nimraylib_now

initWindow 800, 600, "[nim]RaylibNow!"
60.setTargetFPS

# Camera setup.
var camera = Camera(
  position: (x: 0.0, y: 10.0, z: -15.0),
  up: (x: 0.0, y: 0.5, z: 0.0),
  fovy: 45
)
camera.setCameraMode Orbital

# ==Main code==
while not windowShouldClose():
  camera.addr.updateCamera
  beginDrawing()
  label (x: 10.0, y: 0.0, width: 100.0, height: 25.0), "by V.A. Guevara"
  clearBackground(Black)
  beginMode3D(camera)
  drawGrid 10, 1.0
  drawSphere (0.0, 0.0, 0.0), 0.5, Red
  endMode3D()
  let
    slogan = "/Hello from Nim/"
    size = 20
    width = measureText(slogan, size)
  slogan.drawText(
    (getScreenWidth() - width) div 2,
    getScreenHeight() div 2 - 100,
    size,
    LightGray
  )
  drawRectangleV(
    (x: 10.0, y: 10.0),
    (x: (getScreenWidth() - 20).float, y: (getScreenHeight() - 20).float),
    (r: 255, g: 0, b: 0, a: 20)
  )
  endDrawing()
