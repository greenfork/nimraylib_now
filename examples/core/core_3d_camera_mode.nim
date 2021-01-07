# ******************************************************************************************
#
#    raylib [core] example - Initialize 3d camera mode
#
#    This example has been created using raylib 1.0 (www.raylib.com)
#    raylib is licensed under an unmodified zlib/libpng license (View raylib.h for details)
#
#    Copyright (c) 2014 Ramon Santamaria (@raysan5)
#    Converted in 2021 by greenfork
#
# ******************************************************************************************

import ../../src/nimraylib_now/raylib

##  Initialization
## --------------------------------------------------------------------------------------
var screenWidth: int32 = 800
var screenHeight: int32 = 450
initWindow(screenWidth, screenHeight, "raylib [core] example - 3d camera mode")
##  Define the camera to look into our 3d world
var camera = Camera3D()
camera.position = (0.0f, 10.0f, 10.0f)   # Camera position
camera.target = (0.0f, 0.0f, 0.0f)       # Camera looking at point
camera.up = (0.0f, 1.0f, 0.0f) # Camera up vector (rotation towards target)
camera.fovy = 45.0
##  Camera field-of-view Y
camera.`type` = Perspective
##  Camera mode type
var cubePosition: Vector3 = (0.0, 0.0, 0.0)
setTargetFPS(60)
##  Set our game to run at 60 frames-per-second
## --------------------------------------------------------------------------------------
##  Main game loop
while not windowShouldClose(): ##  Detect window close button or ESC key
  ##  Update
  ## ----------------------------------------------------------------------------------
  ##  TODO: Update your variables here
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
  drawText("Welcome to the third dimension!", 10, 40, 20, Darkgray)
  drawFPS(10, 10)
  endDrawing()
## ----------------------------------------------------------------------------------
##  De-Initialization
## --------------------------------------------------------------------------------------
closeWindow()
##  Close window and OpenGL context
## --------------------------------------------------------------------------------------
