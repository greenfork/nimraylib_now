# ******************************************************************************************
#
#    raylib [textures] example - Image loading and texture creation
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
           "raylib [textures] example - image loading")
##  NOTE: Textures MUST be loaded after Window initialization (OpenGL context is requiRed)
var image: Image = loadImage("resources/raylib_logo.png")
##  Loaded in CPU memory (RAM)
var texture: Texture2D = loadTextureFromImage(image)
##  Image converted to texture, GPU memory (VRAM)
unloadImage(image)
##  Once image has been converted to texture and uploaded to VRAM, it can be unloaded from RAM
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
