# ******************************************************************************************
#
#    raylib [core] example - Generate random values
#
#    This example has been created using raylib 1.1 (www.raylib.com)
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
           "raylib [core] example - generate random values")
var framesCounter: int32 = 0 ##  Variable used to count frames
var randValue: int32 = getRandomValue(-8, 5) ##  Get a random integer number between -8 and 5 (both included)
setTargetFPS(60) ##  Set our game to run at 60 frames-per-second
## --------------------------------------------------------------------------------------
##  Main game loop
while not windowShouldClose(): ##  Detect window close button or ESC key
  ##  Update
  ## ----------------------------------------------------------------------------------
  inc(framesCounter)
  ##  Every two seconds (120 frames) a new random value is generated
  if ((framesCounter div 120) mod 2) == 1:
    randValue = getRandomValue(-8, 5)
    framesCounter = 0
  beginDrawing()
  clearBackground(Raywhite)
  drawText("Every 2 seconds a new random value is generated:", 130, 100, 20,
           Maroon)
  drawText(textFormat("%i", randValue), 360, 180, 80, Lightgray)
  endDrawing()
## ----------------------------------------------------------------------------------
##  De-Initialization
## --------------------------------------------------------------------------------------
closeWindow()
##  Close window and OpenGL context
## --------------------------------------------------------------------------------------
