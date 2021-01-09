#*******************************************************************************************
#
#   raylib [core] example - Picking in 3d mode
#
#   This example has been created using raylib 1.3 (www.raylib.com)
#   raylib is licensed under an unmodified zlib/libpng license (View raylib.h for details)
#
#   Copyright (c) 2015 Ramon Santamaria (@raysan5)
#   /Converted in 2*20 by Guevara-chan.
#   Adapted in 2021 by greenfork
#
#*******************************************************************************************

import ../../src/nimraylib_now/raylib

#  Initialization
# --------------------------------------------------------------------------------------
const screenWidth = 800
const screenHeight = 450

initWindow(screenWidth, screenHeight, "raylib [core] example - 3d picking")

#  Define the camera to look into our 3d world
var camera = Camera()
camera.position = (x: 10.0, y: 10.0, z: 10.0)    #  Camera position
camera.target = (x: 0.0, y: 0.0, z: 0.0)         #  Camera looking at point
camera.up = (x: 0.0, y: 1.0, z: 0.0)             #  Camera up vector (rotation towards target)
camera.fovy = 45.0                                        #  Camera field-of-view Y
camera.`type` = Perspective                          #  Camera mode type

var
    cubePosition = (x: 0.0, y: 1.0, z: 0.0)
    cubeSize = (x: 2.0, y: 2.0, z: 2.0)

    ray = Ray()                     #  Picking line ray

    collision = false

camera.setCameraMode Free    #  Set a free camera mode

setTargetFPS(60);                   #  Set our game to run at 60 frames-per-second
# --------------------------------------------------------------------------------------

#  Main game loop
while not windowShouldClose():      #  Detect window close button or ESC key
  #  Update
  # ----------------------------------------------------------------------------------
  camera.addr.updateCamera        #  Update camera

  if MouseButton.LeftButton.isMouseButtonPressed():
    if not collision:
      let ray = getMouseRay(getMousePosition(), camera);

      #  Check collision between ray and box
      collision = checkCollisionRayBox(
        ray,
        BoundingBox(
          min: (x: cubePosition.x - cubeSize.x/2, y: cubePosition.y - cubeSize.y/2, z: cubePosition.z - cubeSize.z/2),
          max: (x: cubePosition.x + cubeSize.x/2, y: cubePosition.y + cubeSize.y/2, z: cubePosition.z + cubeSize.z/2)
        )
      )
    else: collision = false
  # ----------------------------------------------------------------------------------

  #  Draw
  # ----------------------------------------------------------------------------------
  beginDrawing()

  clearBackground Raywhite

  beginMode3D camera

  if collision:
      drawCube(cubePosition, cubeSize.x, cubeSize.y, cubeSize.z, RED)
      drawCubeWires(cubePosition, cubeSize.x, cubeSize.y, cubeSize.z, MAROON)

      drawCubeWires(cubePosition, cubeSize.x + 0.2, cubeSize.y + 0.2, cubeSize.z + 0.2, GREEN)
  else:
      drawCube(cubePosition, cubeSize.x, cubeSize.y, cubeSize.z, GRAY)
      drawCubeWires(cubePosition, cubeSize.x, cubeSize.y, cubeSize.z, DARKGRAY)

  drawRay(ray, MAROON)
  drawGrid(10, 1.0)

  endMode3D()

  drawText("Try selecting the box with mouse!", 240, 10, 20, DARKGRAY)

  if collision:
    drawText("BOX SELECTED", (screenWidth - measureText("BOX SELECTED", 30)) div 2,
      (screenHeight * 0.1).cint, 30, GREEN)

  drawFPS(10, 10)

  endDrawing()
  # ----------------------------------------------------------------------------------

#  De-Initialization
# --------------------------------------------------------------------------------------
closeWindow()         #  Close window and OpenGL context
# --------------------------------------------------------------------------------------
