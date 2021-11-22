discard """
  action: "compile"
  joinable: false
  matrix: "; -d:release; --gc:orc -d:release"
"""

# ******************************************************************************************
#
#    raylib [textures] example - sprite button
#
#    This example has been created using raylib 2.5 (www.raylib.com)
#    raylib is licensed under an unmodified zlib/libpng license (View raylib.h for details)
#
#    Copyright (c) 2019 Ramon Santamaria (@raysan5)
#    Converted in 2021 by greenfork
#
# ******************************************************************************************

import ../../src/nimraylib_now

const
  NUM_FRAMES = 3

##  Initialization
## --------------------------------------------------------------------------------------
var screenWidth = 800
var screenHeight = 450
initWindow(screenWidth, screenHeight,
           "raylib [textures] example - sprite button")
initAudioDevice()
##  Initialize audio device
var fxButton: Sound = loadSound("resources/buttonfx.wav")
##  Load button sound
var button: Texture2D = loadTexture("resources/button.png")
##  Load button texture
##  Define frame rectangle for drawing
var frameHeight = button.height div NUM_FRAMES
var sourceRec: Rectangle = (0.0, 0.0, button.width.float, frameHeight.float)
##  Define button bounds on screen
var btnBounds: Rectangle = ((float)screenWidth div 2 - button.width div 2, (float)screenHeight div 2 -
    button.height div NUM_FRAMES div 2, button.width.float, frameHeight.float)
var btnState = 0
##  Button state: 0-NORMAL, 1-MOUSE_HOVER, 2-PRESSED
var btnAction: bool = false
##  Button action should be activated
var mousePoint: Vector2
setTargetFPS(60)
## --------------------------------------------------------------------------------------
##  Main game loop
while not windowShouldClose(): ##  Detect window close button or ESC key
  ##  Update
  ## ----------------------------------------------------------------------------------
  mousePoint = getMousePosition()
  btnAction = false
  ##  Check button state
  if checkCollisionPointRec(mousePoint, btnBounds):
    if isMouseButtonDown(MouseButton.Left):
      btnState = 2
    else:
      btnState = 1
    if isMouseButtonReleased(MouseButton.Left):
      btnAction = true
  else:
    btnState = 0
  if btnAction:
    playSound(fxButton)
    ##  TODO: Any desiRed action
  sourceRec.y = (float)btnState * frameHeight
  ## ----------------------------------------------------------------------------------
  ##  Draw
  ## ----------------------------------------------------------------------------------
  beginDrawing()
  clearBackground(Raywhite)
  drawTextureRec(button, sourceRec, (btnBounds.x.float, btnBounds.y.float), White)
  ##  Draw button frame
  endDrawing()
## ----------------------------------------------------------------------------------
##  De-Initialization
## --------------------------------------------------------------------------------------
unloadTexture(button)
##  Unload button texture
unloadSound(fxButton)
##  Unload sound
closeAudioDevice()
##  Close audio device
closeWindow()
##  Close window and OpenGL context
## --------------------------------------------------------------------------------------
