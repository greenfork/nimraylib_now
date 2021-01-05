# -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- #
# Raylib Forever basic usage sample
# Developed in 2*20 by Guevara-chan
# -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- #
import ../../raylib/raylib, ../../raylib/raygui
initWindow 800, 600, "RayLib/[nim]"
60.setTargetFPS


# Camera setup.
var camera = Camera(position: Vector3(z: -15.0f, y: 10), up: Vector3(y: 0.5), fovy: 45.0)
camera.setCameraMode CAMERA_ORBITAL

# ==Main code==
while not windowShouldClose():
  camera.addr.updateCamera
  beginDrawing()
  label Rectangle(x: 10, y: 0, width: 100, height: 25), "by V.A. Guevara"
  Black.clearBackground
  beginMode3D(camera)
  drawGrid 10, 1.0f
  drawSphere Vector3(), 0.5f, Red
  endMode3D()
  let
    slogan = "/Hello from Nim/"
    size = 20.int32
    width = measureText(slogan, size)
  slogan.drawText (getScreenWidth() - width) div 2, getScreenHeight() div 2 - 100, size, LightGray
  drawRectangleV(
    Vector2(x: 10, y: 10),
    Vector2(x: (getScreenWidth() - 20).float, y: (getScreenHeight() - 20).float),
    Color(r: 255, a: 20)
  )
  endDrawing()
