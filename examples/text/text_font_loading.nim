##############################################################################################
##
##   raylib [text] example - Font loading
##
##   raylib can load fonts from multiple file formats:
##
##     - TTF/OTF > Sprite font atlas is generated on loading, user can configure
##                 some of the generation parameters (size, characters to include)
##     - BMFonts > Angel code font fileformat, sprite font image must be provided
##                 together with the .fnt file, font generation cna not be configured
##     - XNA Spritefont > Sprite font image, following XNA Spritefont conventions,
##                 Characters in image must follow some spacing and order rules
##
##   This example has been created using raylib 2.6 (www.raylib.com)
##   raylib is licensed under an unmodified zlib/libpng license (View raylib.h for details)
##
##   Copyright (c) 2016-2019 Ramon Santamaria (@raysan5)
##   Converted in 2022 by LEPINE Florent (@Ryback08)
## 
################################################################################################

import nimraylib_now
 
var
  screenWidth: int = 800
  screenHeight: int = 450


initWindow(screenWidth, screenHeight, "raylib [text] example - font loading")  # Open window

## Define characters to draw
## NOTE: raylib supports UTF-8 encoding, following list is actually codified as UTF8 internally

var msg: string = "!\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHI\nJKLMNOPQRSTUVWXYZ[]^_`abcdefghijklmn\nopqrstuvwxyz{|}~¿ÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓ\nÔÕÖ×ØÙÚÛÜÝÞßàáâãäåæçèéêëìíîïðñòóôõö÷\nøùúûüýþÿ"

## NOTE: Textures/Fonts MUST be loaded after Window initialization (OpenGL context is required)

## BMFont (AngelCode) : Font data and image atlas have been generated using external program

var
  fontBm: Font = loadFont("resources/pixantiqua.fnt")
  fontTtf: Font = loadFontEx("resources/pixantiqua.ttf", 32, nil, 250)
  useTft: bool = false

setTargetFPS(60)               # Set the game to run at 60 frames per second

# Main game loop
while not windowShouldClose():
  #Update
  if isKeyDown(KeyboardKey.SPACE):
    useTft = true
  else:
    useTft = false

  # Draw  
  beginDrawing():
    clearBackground(White)
    drawText("Hold SPACE to use TTF generated font", 20, 20, 20, LIGHTGRAY)

    if not useTft:
      drawTextEx(fontBm, msg.cstring, Vector2(x: 20.0, y: 100.0), toFloat(fontBm.baseSize), 2, MAROON)
      drawText("Using BMFont (Angelcode) imported", 20, getScreenHeight() - 30, 20, GRAY)
    else:
      drawTextEx(fontTtf, msg.cstring, (20.0, 100.0).Vector2, fontTtf.baseSize.float, 2, LIME)
      drawText("Using TTF font generated", 20, getScreenHeight() - 30, 20, GRAY)

# De-Initialization
unloadFont(fontBm)    # AngelCode Font unloading
unloadFont(fontTtf)   # TTF Font unloading
closeWindow()         # Close window and OpenGL context
