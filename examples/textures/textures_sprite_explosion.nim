# ******************************************************************************************
#
#    raylib [textures] example - sprite explosion
#
#    This example has been created using raylib 2.5 (www.raylib.com)
#    raylib is licensed under an unmodified zlib/libpng license (View raylib.h for details)
#
#    Copyright (c) 2019 Anata and Ramon Santamaria (@raysan5)
#    Converted in 2021 by greenfork
#
# ******************************************************************************************

import nimraylib_now

const
  NUM_FRAMES_PER_LINE = 5
  NUM_LINES = 5

##  Initialization
## --------------------------------------------------------------------------------------
var screenWidth = 800
var screenHeight = 450
initWindow(screenWidth, screenHeight,
           "raylib [textures] example - sprite explosion")
initAudioDevice()
##  Load explosion sound
var fxBoom: Sound = loadSound("resources/boom.wav")
##  Load explosion texture
var explosion: Texture2D = loadTexture("resources/explosion.png")
##  Init variables for animation
var frameWidth = explosion.width div NUM_FRAMES_PER_LINE
##  Sprite one frame rectangle width
var frameHeight = explosion.height div NUM_LINES
##  Sprite one frame rectangle height
var currentFrame = 0
var currentLine = 0
var frameRec: Rectangle = (0.0, 0.0, frameWidth.float, frameHeight.float)
var position: Vector2
var active: bool = false
var framesCounter = 0
setTargetFPS(120)
## --------------------------------------------------------------------------------------
##  Main game loop
while not windowShouldClose(): ##  Detect window close button or ESC key
  ##  Update
  ## ----------------------------------------------------------------------------------
  ##  Check for mouse button pressed and activate explosion (if not active)
  if isMouseButtonPressed(MouseButton.Left) and not active:
    position = getMousePosition()
    active = true
    position.x -= (float)frameWidth div 2
    position.y -= (float)frameHeight div 2
    playSound(fxBoom)
  if active:
    inc(framesCounter)
    if framesCounter > 2:
      inc(currentFrame)
      if currentFrame >= NUM_FRAMES_PER_LINE:
        currentFrame = 0
        inc(currentLine)
        if currentLine >= NUM_LINES:
          currentLine = 0
          active = false
      framesCounter = 0
  frameRec.x = (float) frameWidth * currentFrame
  frameRec.y = (float) frameHeight * currentLine
  ## ----------------------------------------------------------------------------------
  ##  Draw
  ## ----------------------------------------------------------------------------------
  beginDrawing()
  clearBackground(Raywhite)
  ##  Draw explosion requiRed frame rectangle
  if active:
    drawTextureRec(explosion, frameRec, position, White)
  endDrawing()
## ----------------------------------------------------------------------------------
##  De-Initialization
## --------------------------------------------------------------------------------------
unloadTexture(explosion)
##  Unload texture
unloadSound(fxBoom)
##  Unload sound
closeAudioDevice()
closeWindow()
##  Close window and OpenGL context
## --------------------------------------------------------------------------------------
