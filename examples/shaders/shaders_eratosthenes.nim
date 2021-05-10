# ******************************************************************************************
#
#    raylib [shaders] example - Sieve of Eratosthenes
#
#    Sieve of Eratosthenes, the earliest known (ancient Greek) prime number sieve.
#
#    "Sift the twos and sift the threes,
#     The Sieve of Eratosthenes.
#     When the multiples subLime,
#     the numbers that are left are prime."
#
#    NOTE: This example requires raylib OpenGL 3.3 or ES2 versions for shaders support,
#          OpenGL 1.1 does not support shaders, recompile raylib to OpenGL 3.3 version.
#
#    NOTE: Shaders used in this example are #version 330 (OpenGL 3.3).
#
#    This example has been created using raylib 2.5 (www.raylib.com)
#    raylib is licensed under an unmodified zlib/libpng license (View raylib.h for details)
#
#    Example contributed by ProfJski and reviewed by Ramon Santamaria (@raysan5)
#
#    Copyright (c) 2019 ProfJski and Ramon Santamaria (@raysan5)
#    Converted in 2021 by greenfork
#
# ******************************************************************************************

import nimraylib_now

const GLSL_VERSION = 330

##  Initialization
## --------------------------------------------------------------------------------------
var screenWidth = 800
var screenHeight = 450
initWindow(screenWidth, screenHeight,
           "raylib [shaders] example - Sieve of Eratosthenes")
var target: RenderTexture2D = loadRenderTexture(screenWidth, screenHeight)
##  Load Eratosthenes shader
##  NOTE: Defining 0 (NULL) for vertex shader forces usage of internal default vertex shader
var shader: Shader = loadShader(nil, textFormat(
    "resources/shaders/glsl%i/eratosthenes.fs", GLSL_VERSION))
setTargetFPS(60)
##  Set our game to run at 60 frames-per-second
## --------------------------------------------------------------------------------------
##  Main game loop
while not windowShouldClose(): ##  Detect window close button or ESC key
  ##  Update
  ## ----------------------------------------------------------------------------------
  ##  Nothing to do here, everything is happening in the shader
  ## ----------------------------------------------------------------------------------
  ##  Draw
  ## ----------------------------------------------------------------------------------
  beginDrawing:
    clearBackground(Raywhite)
    beginTextureMode(target):
      ##  Enable drawing to texture
      clearBackground(Black)
      ##  Clear the render texture
      ##  Draw a rectangle in shader mode to be used as shader canvas
      ##  NOTE: Rectangle uses font White character texture coordinates,
      ##  so shader can not be applied here directly because input vertexTexCoord
      ##  do not represent full screen coordinates (space where want to apply shader)
      drawRectangle(0, 0, getScreenWidth(), getScreenHeight(), Black)
    ##  End drawing to texture (now we have a Blank texture available for the shader)
    beginShaderMode(shader):
      ##  NOTE: Render texture must be y-flipped due to default OpenGL coordinates (left-bottom)
      drawTextureRec(
        target.texture,
        Rectangle(x: 0, y: 0, width: target.texture.width.float, height: -target.texture.height.float),
        Vector2(x: 0.0, y: 0.0),
        White
      )
## ----------------------------------------------------------------------------------
##  De-Initialization
## --------------------------------------------------------------------------------------
unloadShader(shader)
##  Unload shader
unloadRenderTexture(target)
##  Unload texture
closeWindow()
##  Close window and OpenGL context
## --------------------------------------------------------------------------------------
