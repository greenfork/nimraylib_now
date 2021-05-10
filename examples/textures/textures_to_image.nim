# ******************************************************************************************
#
#    raylib [textures] example - Retrieve image data from texture: GetTextureData()
#
#    NOTE: Images are loaded in CPU memory (RAM); textures are loaded in GPU memory (VRAM)
#
#    This example has been created using raylib 1.3 (www.raylib.com)
#    raylib is licensed under an unmodified zlib/libpng license (View raylib.h for details)
#
#    Copyright (c) 2015 Ramon Santamaria (@raysan5)
#    Converted in 2021 by greenfork
#
# ******************************************************************************************

import nimraylib_now

##  Initialization
## --------------------------------------------------------------------------------------
var screenWidth = 800
var screenHeight = 450
initWindow(screenWidth, screenHeight,
           "raylib [textures] example - texture to image")
##  NOTE: Textures MUST be loaded after Window initialization (OpenGL context is requiRed)
var image: Image = loadImage("resources/raylib_logo.png")
##  Load image data into CPU memory (RAM)
var texture: Texture2D = loadTextureFromImage(image)
##  Image converted to texture, GPU memory (RAM -> VRAM)
unloadImage(image)
##  Unload image data from CPU memory (RAM)
image = getTextureData(texture)
##  Retrieve image data from GPU memory (VRAM -> RAM)
unloadTexture(texture)
##  Unload texture from GPU memory (VRAM)
texture = loadTextureFromImage(image)
##  Recreate texture from retrieved image data (RAM -> VRAM)
unloadImage(image)
##  Unload retrieved image data from CPU memory (RAM)
## ---------------------------------------------------------------------------------------
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
  drawTexture(texture, screenWidth div 2 - texture.width div 2,
              screenHeight div 2 - texture.height div 2, White)
  drawText("this IS a texture loaded from an image!", 300, 370, 10, Gray)
  endDrawing()
## ----------------------------------------------------------------------------------
##  De-Initialization
## --------------------------------------------------------------------------------------
unloadTexture(texture)
##  Texture unloading
closeWindow()
##  Close window and OpenGL context
## --------------------------------------------------------------------------------------
