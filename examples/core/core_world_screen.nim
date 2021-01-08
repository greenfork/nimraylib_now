# ******************************************************************************************
#
#    raylib [core] example - World to screen
#
#    This example has been created using raylib 1.3 (www.raylib.com)
#    raylib is licensed under an unmodified zlib/libpng license (View raylib.h for details)
#
#    Copyright (c) 2015 Ramon Santamaria (@raysan5)
#    Converted in 2021 by greenfork
#
# ******************************************************************************************

import ../../src/nimraylib_now/raylib

##  Initialization
## --------------------------------------------------------------------------------------
var screenWidth: int32 = 800
var screenHeight: int32 = 450
initWindow(screenWidth, screenHeight, "raylib [core] example - 3d camera free")
##  Define the camera to look into our 3d world
var camera = Camera()
camera.position = (10.0f, 10.0f, 10.0f)
camera.target = (0.0f, 0.0f, 0.0f)
camera.up = (0.0f, 1.0f, 0.0f).Vector3
camera.fovy = 45.0
camera.`type` = Perspective
var cubePosition: Vector3 = (0.0, 0.0, 0.0)
var cubeScreenPosition: Vector2 = (0.0, 0.0)
setCameraMode(camera, Free)
##  Set a free camera mode
setTargetFPS(60)
##  Set our game to run at 60 frames-per-second
## --------------------------------------------------------------------------------------
##  Main game loop
while not windowShouldClose(): ##  Detect window close button or ESC key
  ##  Update
  ## ----------------------------------------------------------------------------------
  updateCamera(addr(camera))
  ## Update camera
  ## Calculate cube screen space position (with a little offset to be in top)
  cubeScreenPosition = getWorldToScreen((cubePosition.x, cubePosition.y + 2.5f, cubePosition.z), camera);
  ## ----------------------------------------------------------------------------------
  ##  Draw
  ## ----------------------------------------------------------------------------------
  beginDrawing()
  clearBackground(Raywhite)
  beginMode3D(camera)
  drawCube(cubePosition, 2.0, 2.0, 2.0, Red)
  drawCubeWires(cubePosition, 2.0, 2.0, 2.0, Maroon)
  drawGrid(10, 1.0)
  endMode3D()
  drawText(
    "Enemy: 100 / 100",
    (cubeScreenPosition.x.int32 - measureText("Enemy: 100/100", 20) div 2),
    cubeScreenPosition.y.int32,
    20,
    Black
  )
  drawText(
    "Text is always on top of the cube",
    ((screenWidth - measureText("Text is always on top of the cube", 20)) / 2).int32,
    25,
    20,
    Gray
  )
  endDrawing()
## ----------------------------------------------------------------------------------
##  De-Initialization
## --------------------------------------------------------------------------------------
closeWindow()
##  Close window and OpenGL context
## --------------------------------------------------------------------------------------
