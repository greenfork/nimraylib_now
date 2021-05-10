discard """
  action: "compile"
  joinable: false
  matrix: "; -d:release; --gc:orc -d:release"
"""

# ******************************************************************************************
#
#    raylib [textures] example - blend modes
#
#    NOTE: Images are loaded in CPU memory (RAM); textures are loaded in GPU memory (VRAM)
#
#    This example has been created using raylib 3.5 (www.raylib.com)
#    raylib is licensed under an unmodified zlib/libpng license (View raylib.h for details)
#
#    Example contributed by Karlo Licudine (@accidentalrebel) and reviewed by Ramon Santamaria (@raysan5)
#
#    Copyright (c) 2020 Karlo Licudine (@accidentalrebel)
#    Converted in 2021 by greenfork
#
# ******************************************************************************************

import ../../src/nimraylib_now


##  Initialization
## --------------------------------------------------------------------------------------
var screenWidth = 800
var screenHeight = 450
initWindow(screenWidth, screenHeight, "raylib [textures] example - blend modes")
##  NOTE: Textures MUST be loaded after Window initialization (OpenGL context is requiRed)
var bgImage: Image = loadImage("resources/cyberpunk_street_background.png")
##  Loaded in CPU memory (RAM)
var bgTexture: Texture2D = loadTextureFromImage(bgImage)
##  Image converted to texture, GPU memory (VRAM)
var fgImage: Image = loadImage("resources/cyberpunk_street_foreground.png")
##  Loaded in CPU memory (RAM)
var fgTexture: Texture2D = loadTextureFromImage(fgImage)
##  Image converted to texture, GPU memory (VRAM)
##  Once image has been converted to texture and uploaded to VRAM, it can be unloaded from RAM
unloadImage(bgImage)
unloadImage(fgImage)
var blendCountMax = 4
var blendMode: BlendMode
##  Main game loop
while not windowShouldClose(): ##  Detect window close button or ESC key
  ##  Update
  ## ----------------------------------------------------------------------------------
  if isKeyPressed(Space):
    if blendMode >= (blendCountMax - 1):
      blendMode = BlendMode(0.ord)
    else:
      blendMode = succ(blendMode)
  beginDrawing()
  clearBackground(Raywhite)
  drawTexture(bgTexture, screenWidth div 2 - bgTexture.width div 2,
              screenHeight div 2 - bgTexture.height div 2, White)
  ##  Apply the blend mode and then draw the foreground texture
  beginBlendMode(blendMode)
  drawTexture(fgTexture, screenWidth div 2 - fgTexture.width div 2,
              screenHeight div 2 - fgTexture.height div 2, White)
  endBlendMode()
  ##  Draw the texts
  drawText("Press SPACE to change blend modes.", 310, 350, 10, Gray)
  case blendMode
  of Alpha:
    drawText("Current: BLEND_ALPHA", (screenWidth div 2) - 60, 370, 10, Gray)
  of Additive:
    drawText("Current: BLEND_ADDITIVE", (screenWidth div 2) - 60, 370, 10, Gray)
  of Multiplied:
    drawText("Current: BLEND_MULTIPLIED", (screenWidth div 2) - 60, 370, 10, Gray)
  of Add_Colors:
    drawText("Current: BLEND_ADD_COLORS", (screenWidth div 2) - 60, 370, 10, Gray)
  else:
    discard
  drawText("(c) Cyberpunk Street Environment by Luis Zuno (@ansimuz)",
           screenWidth - 330, screenHeight - 20, 10, Gray)
  endDrawing()
  ## ----------------------------------------------------------------------------------
##  De-Initialization
## --------------------------------------------------------------------------------------
unloadTexture(fgTexture)
##  Unload foreground texture
unloadTexture(bgTexture)
##  Unload background texture
closeWindow()
##  Close window and OpenGL context
## --------------------------------------------------------------------------------------
