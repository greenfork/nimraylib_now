discard """
  action: "compile"
  joinable: false
  matrix: "; -d:release; --gc:orc -d:release"
"""

# ******************************************************************************************
#
#    raylib [textures] example - Bunnymark
#
#    This example has been created using raylib 1.6 (www.raylib.com)
#    raylib is licensed under an unmodified zlib/libpng license (View raylib.h for details)
#
#    Copyright (c) 2014-2019 Ramon Santamaria (@raysan5)
#    Converted in 2021 by greenfork
#
# ******************************************************************************************

import lenientops
import ../../src/nimraylib_now

const
  MAX_BUNNIES = 50000

##  This is the maximum amount of elements (quads) per batch
##  NOTE: This value is defined in [rlgl] module and can be changed there

const
  MAX_BATCH_ELEMENTS = 8192

type
  BunnyObj {.bycopy.} = object
    position: Vector2
    speed: Vector2
    color: Color
  Bunny = ref BunnyObj

##  Initialization
## --------------------------------------------------------------------------------------
var screenWidth = 800
var screenHeight = 450
initWindow(screenWidth, screenHeight, "raylib [textures] example - bunnymark")
##  Load bunny texture
var texBunny: Texture2D = loadTexture("resources/wabbit_alpha.png")
var bunnies: array[MAX_BUNNIES, Bunny] ##  Bunnies array
for bunny in bunnies.mitems:
  bunny = new Bunny
var bunniesCount = 0 ##  Bunnies counter
setTargetFPS(60)
##  Set our game to run at 60 frames-per-second
## --------------------------------------------------------------------------------------
##  Main game loop
while not windowShouldClose(): ##  Detect window close button or ESC key
  ##  Update
  ## ----------------------------------------------------------------------------------
  if isMouseButtonDown(Left_Button):
    ##  Create more bunnies
    for i in 0..<100:
      if bunniesCount < MAX_BUNNIES:
        bunnies[bunniesCount].position = getMousePosition()
        bunnies[bunniesCount].speed.x = (getRandomValue(-250, 250).float / 60.0)
        bunnies[bunniesCount].speed.y = (getRandomValue(-250, 250).float / 60.0)
        bunnies[bunniesCount].color = Color(
          r: getRandomValue(50, 240).uint8,
          g: getRandomValue(80, 240).uint8,
          b: getRandomValue(100, 240).uint8,
          a: 255
        )
        inc(bunniesCount)
  for i in 0..<bunniesCount:
    bunnies[i].position.x += bunnies[i].speed.x
    bunnies[i].position.y += bunnies[i].speed.y
    if ((bunnies[i].position.x + texBunny.width / 2.0) > getScreenWidth()) or
        ((bunnies[i].position.x + texBunny.width div 2) < 0):
      bunnies[i].speed.x = bunnies[i].speed.x * -1
    if ((bunnies[i].position.y + texBunny.height div 2) > getScreenHeight()) or
        ((bunnies[i].position.y + texBunny.height div 2 - 40) < 0):
      bunnies[i].speed.y = bunnies[i].speed.y * -1
  ## ----------------------------------------------------------------------------------
  ##  Draw
  ## ----------------------------------------------------------------------------------
  beginDrawing()
  clearBackground(Raywhite)
  for i in 0..<bunniesCount:
    ##  NOTE: When internal batch buffer limit is reached (MAX_BATCH_ELEMENTS),
    ##  a draw call is launched and buffer starts being filled again;
    ##  before issuing a draw call, updated vertex data from internal CPU buffer is send to GPU...
    ##  Process of sending data is costly and it could happen that GPU data has not been completely
    ##  processed for drawing while new data is tried to be sent (updating current in-use buffers)
    ##  it could generates a stall and consequently a frame drop, limiting the number of drawn bunnies
    drawTexture(texBunny, bunnies[i].position.x.cint, bunnies[i].position.y.cint,
                bunnies[i].color)
  drawRectangle(0, 0, screenWidth, 40, Black)
  drawText(textFormat("bunnies: %i", bunniesCount), 120, 10, 20, Green)
  drawText(textFormat("batched draw calls: %i",
                      1 + bunniesCount div MAX_BATCH_ELEMENTS), 320, 10, 20, Maroon)
  drawFPS(10, 10)
  endDrawing()
## ----------------------------------------------------------------------------------
##  De-Initialization
## --------------------------------------------------------------------------------------
unloadTexture(texBunny)
##  Unload bunny texture
closeWindow()
##  Close window and OpenGL context
## --------------------------------------------------------------------------------------
