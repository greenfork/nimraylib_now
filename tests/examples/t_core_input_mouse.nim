discard """
  action: "compile"
  joinable: false
  matrix: "; -d:release; --gc:orc -d:release"
"""

# ******************************************************************************************
#
#    raylib [core] example - Mouse input
#
#    This example has been created using raylib 1.0 (www.raylib.com)
#    raylib is licensed under an unmodified zlib/libpng license (View raylib.h for details)
#
#    Copyright (c) 2014 Ramon Santamaria (@raysan5)
#    Converted in 2021 by greenfork
#
# ******************************************************************************************

import ../../src/nimraylib_now

##  Initialization
## --------------------------------------------------------------------------------------
var screenWidth: int32 = 800
var screenHeight: int32 = 450
initWindow(screenWidth, screenHeight, "raylib [core] example - mouse input")
var ballPosition: Vector2 = (-100.0, -100.0)
var ballColor: Color = Darkblue
setTargetFPS(60)
##  Set our game to run at 60 frames-per-second
## ---------------------------------------------------------------------------------------
##  Main game loop
while not windowShouldClose(): ##  Detect window close button or ESC key
  ##  Update
  ## ----------------------------------------------------------------------------------
  ballPosition = getMousePosition()
  if isMouseButtonPressed(MouseButton.Left):
    ballColor = Maroon
  elif isMouseButtonPressed(MouseButton.Middle):
    ballColor = Lime
  elif isMouseButtonPressed(MouseButton.Right):
    ballColor = Darkblue
  ## ----------------------------------------------------------------------------------
  ##  Draw
  ## ----------------------------------------------------------------------------------
  beginDrawing()
  clearBackground(Raywhite)
  drawCircleV(ballPosition, 40, ballColor)
  drawText("move ball with mouse and click mouse button to change color", 10,
           10, 20, Darkgray)
  endDrawing()
## ----------------------------------------------------------------------------------
##  De-Initialization
## --------------------------------------------------------------------------------------
closeWindow()
##  Close window and OpenGL context
## --------------------------------------------------------------------------------------
