discard """
  action: "compile"
  joinable: false
  matrix: "; -d:release; --gc:orc -d:release"
"""

# ******************************************************************************************
#
#    raylib [texture] example - Image text drawing using TTF generated spritefont
#
#    This example has been created using raylib 1.8 (www.raylib.com)
#    raylib is licensed under an unmodified zlib/libpng license (View raylib.h for details)
#
#    Copyright (c) 2017 Ramon Santamaria (@raysan5)
#    Converted in 2021 by greenfork
#
# ******************************************************************************************

import ../../src/nimraylib_now

##  Initialization
## --------------------------------------------------------------------------------------
var screenWidth = 800
var screenHeight = 450
initWindow(screenWidth, screenHeight,
           "raylib [texture] example - image text drawing")
var parrots: Image = loadImage("resources/parrots.png")
##  Load image in CPU memory (RAM)
##  TTF Font loading with custom generation parameters
var font: Font = loadFontEx("resources/KAISG.ttf", 64, nil, 0)
##  Draw over image using custom font
imageDrawTextEx(addr(parrots), font, "[Parrots font drawing]",
                (20.0, 20.0), cast[cfloat](font.baseSize), 0.0, Red)
var texture: Texture2D = loadTextureFromImage(parrots)
##  Image converted to texture, uploaded to GPU memory (VRAM)
unloadImage(parrots)
##  Once image has been converted to texture and uploaded to VRAM, it can be unloaded from RAM
var position: Vector2 = ((float)(screenWidth div 2 - texture.width div 2),
                     (float)(screenHeight div 2 - texture.height div 2 - 20))
var showFont: bool = false
setTargetFPS(60)
## --------------------------------------------------------------------------------------
##  Main game loop
while not windowShouldClose(): ##  Detect window close button or ESC key
  ##  Update
  ## ----------------------------------------------------------------------------------
  if isKeyDown(Space):
    showFont = true
  else:
    showFont = false
  ## ----------------------------------------------------------------------------------
  ##  Draw
  ## ----------------------------------------------------------------------------------
  beginDrawing()
  clearBackground(Raywhite)
  if not showFont:
    ##  Draw texture with text already drawn inside
    drawTextureV(texture, position, White)
    ##  Draw text directly using sprite font
    drawTextEx(font, "[Parrots font drawing]", Vector2(x: position.x + 20,
               y: position.y + 20 + 280), (float)font.baseSize, 0.0, White)
  else:
    drawTexture(font.texture, screenWidth div 2 - font.texture.width div 2, 50, Black)
  drawText("PRESS SPACE to SEE USED SPRITEFONT ", 290, 420, 10, Darkgray)
  endDrawing()
## ----------------------------------------------------------------------------------
##  De-Initialization
## --------------------------------------------------------------------------------------
unloadTexture(texture)
##  Texture unloading
unloadFont(font)
##  Unload custom spritefont
closeWindow()
##  Close window and OpenGL context
## --------------------------------------------------------------------------------------
