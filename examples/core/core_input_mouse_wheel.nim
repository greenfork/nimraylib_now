# ******************************************************************************************
#
#    raylib [core] examples - Mouse wheel input
#
#    This test has been created using raylib 1.1 (www.raylib.com)
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
initWindow(screenWidth, screenHeight,
           "raylib [core] example - input mouse wheel")
var boxPositionY: int32 = screenHeight div 2 - 40
var scrollSpeed: int32 = 4
##  Scrolling speed in pixels
setTargetFPS(60)
##  Set our game to run at 60 frames-per-second
## --------------------------------------------------------------------------------------
##  Main game loop
while not windowShouldClose(): ##  Detect window close button or ESC key
  ##  Update
  ## ----------------------------------------------------------------------------------
  inc(boxPositionY, (getMouseWheelMove().int32 * scrollSpeed))
  ## ----------------------------------------------------------------------------------
  ##  Draw
  ## ----------------------------------------------------------------------------------
  beginDrawing()
  clearBackground(Raywhite)
  drawRectangle(screenWidth div 2 - 40, boxPositionY, 80, 80, Maroon)
  drawText("Use mouse wheel to move the cube up and down!", 10, 10, 20, Gray)
  drawText(textFormat("Box position Y: %03i", boxPositionY), 10, 40, 20, Lightgray)
  endDrawing()
## ----------------------------------------------------------------------------------
##  De-Initialization
## --------------------------------------------------------------------------------------
closeWindow()
##  Close window and OpenGL context
## --------------------------------------------------------------------------------------
