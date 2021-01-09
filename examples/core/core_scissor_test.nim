# ******************************************************************************************
#
#    raylib [core] example - Scissor test
#
#    This example has been created using raylib 2.5 (www.raylib.com)
#    raylib is licensed under an unmodified zlib/libpng license (View raylib.h for details)
#
#    Example contributed by Chris Dill (@MysteriousSpace) and reviewed by Ramon Santamaria (@raysan5)
#
#    Copyright (c) 2019 Chris Dill (@MysteriousSpace)
#    Converted in 2021 by greenfork
#
# ******************************************************************************************

import ../../src/nimraylib_now/raylib

##  Initialization
## --------------------------------------------------------------------------------------
var screenWidth = 800
var screenHeight = 450
initWindow(screenWidth, screenHeight, "raylib [core] example - scissor test")
var scissorArea: Rectangle = (0.0, 0.0, 300.0, 300.0)
var scissorMode: bool = true
setTargetFPS(60)
##  Set our game to run at 60 frames-per-second
## --------------------------------------------------------------------------------------
##  Main game loop
while not windowShouldClose(): ##  Detect window close button or ESC key
  ##  Update
  ## ----------------------------------------------------------------------------------
  if isKeyPressed(S):
    scissorMode = not scissorMode
  scissorArea.x = getMouseX().float - scissorArea.width / 2
  scissorArea.y = getMouseY().float - scissorArea.height / 2
  ## ----------------------------------------------------------------------------------
  ##  Draw
  ## ----------------------------------------------------------------------------------
  beginDrawing()
  clearBackground(Raywhite)
  if scissorMode:
    beginScissorMode(scissorArea.x.cint, scissorArea.y.cint, scissorArea.width.cint,
                     scissorArea.height.cint)
  drawRectangle(0, 0, getScreenWidth(), getScreenHeight(), Red)
  drawText("Move the mouse around to reveal this text!", 190, 200, 20, Lightgray)
  if scissorMode:
    endScissorMode()
  drawRectangleLinesEx(scissorArea, 1, Black)
  drawText("Press S to toggle scissor test", 10, 10, 20, Black)
  endDrawing()
## ----------------------------------------------------------------------------------
##  De-Initialization
## --------------------------------------------------------------------------------------
closeWindow()
##  Close window and OpenGL context
## --------------------------------------------------------------------------------------
