# ******************************************************************************************
#
#    raylib [core] example - Initialize 3d camera free
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
var screenWidth = 800
var screenHeight = 450
initWindow(screenWidth, screenHeight, "raylib [core] example - 3d camera free")
##  Define the camera to look into our 3d world
var camera = Camera3D()
camera.position = (10.0, 10.0, 10.0)
camera.target = (0.0, 0.0, 0.0)      # Camera looking at point
camera.up = (0.0, 1.0, 0.0)          # Camera up vector (rotation towards target)
camera.fovy = 45.0
##  Camera field-of-view Y
camera.projection = Perspective
##  Camera mode type
var cubePosition: Vector3 = (0.0, 0.0, 0.0)
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
  ##  Update camera
  if isKeyDown(Z):
    camera.target = (0.0, 0.0, 0.0)
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
  drawRectangle(10, 10, 320, 133, fade(Skyblue, 0.5))
  drawRectangleLines(10, 10, 320, 133, Blue)
  drawText("Free camera default controls:", 20, 20, 10, Black)
  drawText("- Mouse Wheel to Zoom in-out", 40, 40, 10, Darkgray)
  drawText("- Mouse Wheel Pressed to Pan", 40, 60, 10, Darkgray)
  drawText("- Alt + Mouse Wheel Pressed to Rotate", 40, 80, 10, Darkgray)
  drawText("- Alt + Ctrl + Mouse Wheel Pressed for Smooth Zoom", 40, 100, 10,
           Darkgray)
  drawText("- Z to zoom to (0, 0, 0)", 40, 120, 10, Darkgray)
  endDrawing()
## ----------------------------------------------------------------------------------
##  De-Initialization
## --------------------------------------------------------------------------------------
closeWindow()
##  Close window and OpenGL context
## --------------------------------------------------------------------------------------
