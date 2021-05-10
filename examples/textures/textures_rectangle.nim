# ******************************************************************************************
#
#    raylib [textures] example - Texture loading and drawing a part defined by a rectangle
#
#    This example has been created using raylib 1.3 (www.raylib.com)
#    raylib is licensed under an unmodified zlib/libpng license (View raylib.h for details)
#
#    Copyright (c) 2014 Ramon Santamaria (@raysan5)
#    Converted in 2021 by greenfork
#
# ******************************************************************************************

import nimraylib_now

const
  MAX_FRAME_SPEED = 15
  MIN_FRAME_SPEED = 1


##  Initialization
## --------------------------------------------------------------------------------------
var screenWidth = 800
var screenHeight = 450
initWindow(screenWidth, screenHeight,
           "raylib [texture] example - texture rectangle")
##  NOTE: Textures MUST be loaded after Window initialization (OpenGL context is requiRed)
var scarfy: Texture2D = loadTexture("resources/scarfy.png")
##  Texture loading
var position: Vector2 = (350.0, 280.0)
var frameRec: Rectangle = (0.0, 0.0, (float)(scarfy.width div 6),
                       (float)(scarfy.height))
var currentFrame = 0
var framesCounter = 0
var framesSpeed = 8
##  Number of spritesheet frames shown by second
setTargetFPS(60)
##  Set our game to run at 60 frames-per-second
## --------------------------------------------------------------------------------------
##  Main game loop
while not windowShouldClose(): ##  Detect window close button or ESC key
  ##  Update
  ## ----------------------------------------------------------------------------------
  inc(framesCounter)
  if framesCounter >= (60 div framesSpeed):
    framesCounter = 0
    inc(currentFrame)
    if currentFrame > 5:
      currentFrame = 0
    frameRec.x = (currentFrame * (scarfy.width div 6)).float
  if isKeyPressed(Right):
    inc(framesSpeed)
  elif isKeyPressed(Left):
    dec(framesSpeed)
  if framesSpeed > MAX_FRAME_SPEED:
    framesSpeed = MAX_FRAME_SPEED
  elif framesSpeed < MIN_FRAME_SPEED: ## ----------------------------------------------------------------------------------
                                  ##  Draw
                                  ## ----------------------------------------------------------------------------------
    framesSpeed = MIN_FRAME_SPEED
  beginDrawing()
  clearBackground(Raywhite)
  drawTexture(scarfy, 15, 40, White)
  drawRectangleLines(15, 40, scarfy.width, scarfy.height, Lime)
  drawRectangleLines(15 + frameRec.x.int, 40 + frameRec.y.int, frameRec.width.int,
                     frameRec.height.int, Red)
  drawText("FRAME SPEED: ", 165, 210, 10, Darkgray)
  drawText(textFormat("%02i FPS", framesSpeed), 575, 210, 10, Darkgray)
  drawText("PRESS RIGHT/LEFT KEYS to CHANGE SPEED!", 290, 240, 10, Darkgray)
  var i = 0
  while i < MAX_FRAME_SPEED:
    if i < framesSpeed:
      drawRectangle(250 + 21 * i, 205, 20, 20, Red)
    drawRectangleLines(250 + 21 * i, 205, 20, 20, Maroon)
    inc(i)
  drawTextureRec(scarfy, frameRec, position, White)
  ##  Draw part of the texture
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
