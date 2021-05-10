discard """
  action: "compile"
  joinable: false
  matrix: "; -d:release; --gc:orc -d:release"
"""

# ******************************************************************************************
#
#    raylib [textures] example - Procedural images generation
#
#    This example has been created using raylib 1.8 (www.raylib.com)
#    raylib is licensed under an unmodified zlib/libpng license (View raylib.h for details)
#
#    Copyright (c) 2O17 Wilhem Barbier (@nounoursheureux)
#    Converted in 2021 by greenfork
#
# ******************************************************************************************

import ../../src/nimraylib_now

const
  NUM_TEXTURES = 7


##  Initialization
## --------------------------------------------------------------------------------------
var screenWidth = 800
var screenHeight = 450
initWindow(screenWidth, screenHeight,
           "raylib [textures] example - procedural images generation")
var verticalGradient: Image = genImageGradientV(screenWidth, screenHeight, Red, Blue)
var horizontalGradient: Image = genImageGradientH(screenWidth, screenHeight, Red,
    Blue)
var radialGradient: Image = genImageGradientRadial(screenWidth, screenHeight, 0.0,
    White, Black)
var checked: Image = genImageChecked(screenWidth, screenHeight, 32, 32, Red, Blue)
var WhiteNoise: Image = genImageWhiteNoise(screenWidth, screenHeight, 0.5)
var perlinNoise: Image = genImagePerlinNoise(screenWidth, screenHeight, 50, 50, 4.0)
var cellular: Image = genImageCellular(screenWidth, screenHeight, 32)
var textures: array[NUM_TEXTURES, Texture2D]
textures[0] = loadTextureFromImage(verticalGradient)
textures[1] = loadTextureFromImage(horizontalGradient)
textures[2] = loadTextureFromImage(radialGradient)
textures[3] = loadTextureFromImage(checked)
textures[4] = loadTextureFromImage(WhiteNoise)
textures[5] = loadTextureFromImage(perlinNoise)
textures[6] = loadTextureFromImage(cellular)
##  Unload image data (CPU RAM)
unloadImage(verticalGradient)
unloadImage(horizontalGradient)
unloadImage(radialGradient)
unloadImage(checked)
unloadImage(WhiteNoise)
unloadImage(perlinNoise)
unloadImage(cellular)
var currentTexture = 0
setTargetFPS(60)
## ---------------------------------------------------------------------------------------
##  Main game loop
while not windowShouldClose():
  ##  Update
  ## ----------------------------------------------------------------------------------
  if isMouseButtonPressed(Left_Button) or isKeyPressed(Right):
    currentTexture = (currentTexture + 1) mod NUM_TEXTURES
    ##  Cycle between the textures
  beginDrawing()
  clearBackground(Raywhite)
  drawTexture(textures[currentTexture], 0, 0, White)
  drawRectangle(30, 400, 325, 30, fade(Skyblue, 0.5))
  drawRectangleLines(30, 400, 325, 30, fade(White, 0.5))
  drawText("MOUSE LEFT BUTTON to CYCLE PROCEDURAL TEXTURES", 40, 410, 10, White)
  case currentTexture
  of 0:
    drawText("VERTICAL GRADIENT", 560, 10, 20, Raywhite)
  of 1:
    drawText("HORIZONTAL GRADIENT", 540, 10, 20, Raywhite)
  of 2:
    drawText("RADIAL GRADIENT", 580, 10, 20, Lightgray)
  of 3:
    drawText("CHECKED", 680, 10, 20, Raywhite)
  of 4:
    drawText("WHITE NOISE", 640, 10, 20, Red)
  of 5:
    drawText("PERLIN NOISE", 630, 10, 20, Raywhite)
  of 6:
    drawText("CELLULAR", 670, 10, 20, Raywhite)
  else:
    discard
  endDrawing()
## ----------------------------------------------------------------------------------
##  De-Initialization
## --------------------------------------------------------------------------------------
##  Unload textures data (GPU VRAM)
var i = 0
while i < NUM_TEXTURES:
  unloadTexture(textures[i])
  inc(i)
closeWindow()
##  Close window and OpenGL context
## --------------------------------------------------------------------------------------
