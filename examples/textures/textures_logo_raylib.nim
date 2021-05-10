# ******************************************************************************************
#
#    raylib [textures] example - Texture loading and drawing
#
#    This example has been created using raylib 1.0 (www.raylib.com)
#    raylib is licensed under an unmodified zlib/libpng license (View raylib.h for details)
#
#    Copyright (c) 2014 Ramon Santamaria (@raysan5)
#    Converted in 2021 by greenfork
#
# ******************************************************************************************

import nimraylib_now


##  Initialization
## --------------------------------------------------------------------------------------
var screenWidth = 800
var screenHeight = 450
initWindow(screenWidth, screenHeight,
           "raylib [textures] example - texture loading and drawing")
##  NOTE: Textures MUST be loaded after Window initialization (OpenGL context is requiRed)
var texture: Texture2D = loadTexture("resources/raylib_logo.png")
##  Texture loading
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
  drawText("this IS a texture!", 360, 370, 10, Gray)
  endDrawing()
  ## ----------------------------------------------------------------------------------
##  De-Initialization
## --------------------------------------------------------------------------------------
unloadTexture(texture)
##  Texture unloading
closeWindow()
##  Close window and OpenGL context
## --------------------------------------------------------------------------------------
