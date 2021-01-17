# ******************************************************************************************
#
#    raylib [textures] example - Image loading and drawing on it
#
#    NOTE: Images are loaded in CPU memory (RAM); textures are loaded in GPU memory (VRAM)
#
#    This example has been created using raylib 1.4 (www.raylib.com)
#    raylib is licensed under an unmodified zlib/libpng license (View raylib.h for details)
#
#    Copyright (c) 2016 Ramon Santamaria (@raysan5)
#    Converted in 2021 by greenfork
#
# ******************************************************************************************

import ../../src/nimraylib_now/raylib

##  Initialization
## --------------------------------------------------------------------------------------
var screenWidth = 800
var screenHeight = 450
initWindow(screenWidth, screenHeight,
           "raylib [textures] example - image drawing")
##  NOTE: Textures MUST be loaded after Window initialization (OpenGL context is requiRed)
var cat: Image = loadImage("resources/cat.png") ##  Load image in CPU memory (RAM)
imageCrop(addr(cat), (100.0, 10.0, 280.0, 380.0)) ##  Crop an image piece
imageFlipHorizontal(addr(cat)) ##  Flip cropped image horizontally
imageResize(addr(cat), 150, 200) ##  Resize flipped-cropped image
var parrots: Image = loadImage("resources/parrots.png") ##  Load image in CPU memory (RAM)
##  Draw one image over the other with a scaling of 1.5f
imageDraw(
  addr(parrots),
  cat,
  Rectangle(x: 0.0, y: 0.0, width: cat.width.float, height: cat.height.float),
  Rectangle(x: 30.0, y: 40.0, width: cat.width.float*1.5, height: cat.height.float*1.5),
  White)
imageCrop(addr(parrots), (0.0, 50.0, parrots.width.float, parrots.height.float - 100.0)) ##  Crop resulting image
##  Draw on the image with a few image draw methods
imageDrawPixel(addr(parrots), 10, 10, Raywhite)
imageDrawCircle(addr(parrots), 10, 10, 5, Raywhite)
imageDrawRectangle(addr(parrots), 5, 20, 10, 10, Raywhite)
unloadImage(cat)
##  Unload image from RAM
##  Load custom font for frawing on image
var font: Font = loadFont("resources/custom_jupiter_crash.png")
##  Draw over image using custom font
imageDrawTextEx(addr(parrots), font, "PARROTS & CAT", (300.0, 230.0),
                font.baseSize.float, -2.0, White)
unloadFont(font)
##  Unload custom spritefont (already drawn used on image)
var texture: Texture2D = loadTextureFromImage(parrots)
##  Image converted to texture, uploaded to GPU memory (VRAM)
unloadImage(parrots)
##  Once image has been converted to texture and uploaded to VRAM, it can be unloaded from RAM
setTargetFPS(60)
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
              screenHeight div 2 - texture.height div 2 - 40, White)
  drawRectangleLines(screenWidth div 2 - texture.width div 2,
                     screenHeight div 2 - texture.height div 2 - 40, texture.width,
                     texture.height, Darkgray)
  drawText("We are drawing only one texture from various images composed!",
           240, 350, 10, Darkgray)
  drawText("Source images have been cropped, scaled, flipped and copied one over the other.",
           190, 370, 10, Darkgray)
  endDrawing()
## ----------------------------------------------------------------------------------
##  De-Initialization
## --------------------------------------------------------------------------------------
unloadTexture(texture)
##  Texture unloading
closeWindow()
##  Close window and OpenGL context
## --------------------------------------------------------------------------------------
