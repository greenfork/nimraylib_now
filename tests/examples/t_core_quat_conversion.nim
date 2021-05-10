discard """
  action: "compile"
  joinable: false
  matrix: "; -d:release; --gc:orc -d:release"
"""

# ******************************************************************************************
#
#    raylib [core] example - quat conversions
#
#    Generally you should really stick to eulers OR quats...
#    This tests that various conversions are equivalent.
#
#    This example has been created using raylib 3.5 (www.raylib.com)
#    raylib is licensed under an unmodified zlib/libpng license (View raylib.h for details)
#
#    Example contributed by Chris Camacho (@chriscamacho) and reviewed by Ramon Santamaria (@raysan5)
#
#    Copyright (c) 2020 Chris Camacho (@chriscamacho) and Ramon Santamaria (@raysan5)
#    Converted in 2021 by greenfork
#
# ******************************************************************************************

import math
import ../../src/nimraylib_now

##  Initialization
## --------------------------------------------------------------------------------------
var screenWidth = 800
var screenHeight = 450
initWindow(screenWidth, screenHeight, "raylib [core] example - quat conversions")
var camera = Camera3D()
camera.position = (0.0, 10.0, 10.0)  # Camera position
camera.target = (0.0, 0.0, 0.0)      # Camera looking at point
camera.up = (0.0, 1.0, 0.0)          # Camera up vector (rotation towards target)
camera.fovy = 45.0
##  Camera field-of-view Y
camera.projection = Perspective
##  Camera mode type
var mesh: Mesh = genMeshCylinder(0.2, 1.0, 32)
var model: Model = loadModelFromMesh(mesh)
##  Some required variables
var q1: Quaternion
var
  m1: Matrix
  m2: Matrix
  m3: Matrix
  m4: Matrix
var
  v1: Vector3
  v2: Vector3
setTargetFPS(60)
##  Set our game to run at 60 frames-per-second
## --------------------------------------------------------------------------------------
##  Main game loop
while not windowShouldClose(): ##  Detect window close button or ESC key
  ##  Update
  ## --------------------------------------------------------------------------------------
  if not isKeyDown(Space):
    v1.x += 0.01
    v1.y += 0.03
    v1.z += 0.05
  if v1.x > PI * 2:
    v1.x -= PI * 2
  if v1.y > PI * 2:
    v1.y -= PI * 2
  if v1.z > PI * 2:
    v1.z -= PI * 2
  q1 = fromEuler(v1.x, v1.y, v1.z)
  m1 = rotateZYX(v1)
  m2 = toMatrix(q1)
  q1 = fromMatrix(m1)
  m3 = toMatrix(q1)
  v2 = toEuler(q1)
  v2.x = degToRad v2.x
  v2.y = degToRad v2.y
  v2.z = degToRad v2.z
  m4 = rotateZYX(v2)
  ## --------------------------------------------------------------------------------------
  ##  Draw
  ## ----------------------------------------------------------------------------------
  beginDrawing:
    clearBackground(Raywhite)

    beginMode3D(camera):
      model.transform = m1
      drawModel(model, (-1.0, 0.0, 0.0), 1.0, Red)
      model.transform = m2
      drawModel(model, (1.0, 0.0, 0.0), 1.0, Red)
      model.transform = m3
      drawModel(model, (0.0, 0.0, 0.0), 1.0, Red)
      model.transform = m4
      drawModel(model, (0.0, 0.0, -1.0), 1.0, Red)
      drawGrid(10, 1.0)

    if v2.x < 0:
      v2.x += PI * 2
    if v2.y < 0:
      v2.y += PI * 2
    if v2.z < 0:
      v2.z += PI * 2
    var
      cx: Color = Black
      cy: Color =  Black
      cz: Color =   Black
    if v1.x == v2.x:
      cx = Green
    if v1.y == v2.y:
      cy = Green
    if v1.z == v2.z:
      cz = Green
    drawText(textFormat("%2.3f", v1.x), 20, 20, 20, cx)
    drawText(textFormat("%2.3f", v1.y), 20, 40, 20, cy)
    drawText(textFormat("%2.3f", v1.z), 20, 60, 20, cz)
    drawText(textFormat("%2.3f", v2.x), 200, 20, 20, cx)
    drawText(textFormat("%2.3f", v2.y), 200, 40, 20, cy)
    drawText(textFormat("%2.3f", v2.z), 200, 60, 20, cz)
## ----------------------------------------------------------------------------------
##  De-Initialization
## --------------------------------------------------------------------------------------
unloadModel(model)
##  Unload model data (mesh and materials)
closeWindow()
##  Close window and OpenGL context
## --------------------------------------------------------------------------------------
