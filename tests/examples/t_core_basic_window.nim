discard """
  action: "compile"
  joinable: false
  matrix: "; -d:release; --gc:orc -d:release"
"""

# ******************************************************************************************
#
#    raylib [core] example - Basic window
#
#    Welcome to raylib!
#
#    To test examples, just press F6 and execute raylib_compile_execute script
#    Note that compiled executable is placed in the same folder as .c file
#
#    You can find all basic examples on C:\raylib\raylib\examples folder or
#    raylib official webpage: www.raylib.com
#
#    Enjoy using raylib. :)
#
#    This example has been created using raylib 1.0 (www.raylib.com)
#    raylib is licensed under an unmodified zlib/libpng license (View raylib.h for details)
#
#    Copyright (c) 2013-2016 Ramon Santamaria (@raysan5)
#    Converted in 2021 by greenfork
#
# ******************************************************************************************

import ../../src/nimraylib_now

##  Initialization
## --------------------------------------------------------------------------------------
var screenWidth: int32 = 800
var screenHeight: int32 = 450
initWindow(screenWidth, screenHeight, "raylib [core] example - basic window")
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
  drawText("Congrats! You created your first window!", 190, 200, 20, Lightgray)
  endDrawing()
  ## ----------------------------------------------------------------------------------
##  De-Initialization
## --------------------------------------------------------------------------------------
closeWindow()
##  Close window and OpenGL context
## --------------------------------------------------------------------------------------
