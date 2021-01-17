# ******************************************************************************************
#
#    raylib [textures] example - Texture source and destination rectangles
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
initWindow(screenWidth, screenHeight, "raylib [textures] examples - texture source and destination rectangles")
##  NOTE: Textures MUST be loaded after Window initialization (OpenGL context is requiRed)
var scarfy: Texture2D = loadTexture("resources/scarfy.png")
##  Texture loading
var frameWidth = scarfy.width div 6
var frameHeight = scarfy.height
##  Source rectangle (part of the texture to use for drawing)
var sourceRec: Rectangle = (0.0, 0.0, frameWidth.float, frameHeight.float)
##  Destination rectangle (screen rectangle where drawing part of texture)
var destRec: Rectangle = ((float)screenWidth div 2, (float)screenHeight div 2, (float)frameWidth * 2,
                      (float)frameHeight * 2)
##  Origin of the texture (rotation/scale point), it's relative to destination rectangle size
var origin: Vector2 = (frameWidth.float, frameHeight.float)
var rotation = 0
setTargetFPS(60)
## --------------------------------------------------------------------------------------
##  Main game loop
while not windowShouldClose(): ##  Detect window close button or ESC key
  ##  Update
  ## ----------------------------------------------------------------------------------
  inc(rotation)
  ## ----------------------------------------------------------------------------------
  ##  Draw
  ## ----------------------------------------------------------------------------------
  beginDrawing()
  clearBackground(Raywhite)
  ##  NOTE: Using DrawTexturePro() we can easily rotate and scale the part of the texture we draw
  ##  sourceRec defines the part of the texture we use for drawing
  ##  destRec defines the rectangle where our texture part will fit (scaling it to fit)
  ##  origin defines the point of the texture used as reference for rotation and scaling
  ##  rotation defines the texture rotation (using origin as rotation point)
  drawTexturePro(scarfy, sourceRec, destRec, origin, rotation.float, White)
  drawLine(destRec.x.int, 0, destRec.x.int, screenHeight, Gray)
  drawLine(0, destRec.y.int, screenWidth, destRec.y.int, Gray)
  drawText("(c) Scarfy sprite by Eiden Marsal", screenWidth - 200,
           screenHeight - 20, 10, Gray)
  endDrawing()
## ----------------------------------------------------------------------------------
##  De-Initialization
## --------------------------------------------------------------------------------------
unloadTexture(scarfy)
##  Texture unloading
closeWindow()
##  Close window and OpenGL context
## --------------------------------------------------------------------------------------
