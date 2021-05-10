discard """
  action: "compile"
  joinable: false
  matrix: "; -d:release; --gc:orc -d:release"
"""

# ******************************************************************************************
#
#    raylib [textures] example - Draw part of the texture tiled
#
#    This example has been created using raylib 3.0 (www.raylib.com)
#    raylib is licensed under an unmodified zlib/libpng license (View raylib.h for details)
#
#    Copyright (c) 2020 Vlad Adrian (@demizdor) and Ramon Santamaria (@raysan5)
#    Converted in 2021 by greenfork
#
# ******************************************************************************************

import ../../src/nimraylib_now

const
  OPT_WIDTH = 220
  MARGIN_SIZE = 8
  COLOR_SIZE = 16

##  Initialization
## --------------------------------------------------------------------------------------
var screenWidth = 800
var screenHeight = 450
setConfigFlags(WindowResizable)
##  Make the window resizable
initWindow(screenWidth, screenHeight,
           "raylib [textures] example - Draw part of a texture tiled")
##  NOTE: Textures MUST be loaded after Window initialization (OpenGL context is requiRed)
var texPattern: Texture = loadTexture("resources/patterns.png")
setTextureFilter(texPattern, Trilinear)
##  Makes the texture smoother when upscaled
##  Coordinates for all patterns inside the texture
var recPattern = [
  Rectangle(x: 3, y: 3, width: 66, height: 66),
  Rectangle(x: 75, y: 3, width: 100, height: 100),
  Rectangle(x: 3, y: 75, width: 66, height: 66),
  Rectangle(x: 7, y: 156, width: 50, height: 50),
  Rectangle(x: 85, y: 106, width: 90, height: 45),
  Rectangle(x: 75, y: 154, width: 100, height: 60)
]
##  Setup colors
var colors = [Black, Maroon, Orange, Blue, Purple, Beige, Lime, Red, Darkgray,
                    Skyblue]
const
  MAX_COLORS = colors.len
var colorRec: array[MAX_COLORS, Rectangle]
##  Calculate rectangle for each color
var
  i = 0
  x = 0
  y = 0
while i < MAX_COLORS:
  colorRec[i].x = (float) 2 + MARGIN_SIZE + x
  colorRec[i].y = (float) 22 + 256 + MARGIN_SIZE + y
  colorRec[i].width = COLOR_SIZE * 2
  colorRec[i].height = COLOR_SIZE
  if i == (MAX_COLORS div 2 - 1):
    x = 0
    inc(y, COLOR_SIZE + MARGIN_SIZE)
  else:
    inc(x, (COLOR_SIZE * 2 + MARGIN_SIZE))
  inc(i)
var
  activePattern = 0
  activeCol = 0
var
  scale = 1.0
  rotation = 0.0
setTargetFPS(60)
## ---------------------------------------------------------------------------------------
##  Main game loop
while not windowShouldClose(): ##  Detect window close button or ESC key
  ##  Update
  ## ----------------------------------------------------------------------------------
  screenWidth = getScreenWidth()
  screenHeight = getScreenHeight()
  ##  Handle mouse
  if isMouseButtonPressed(Left_Button):
    var mouse: Vector2 = getMousePosition()
    ##  Check which pattern was clicked and set it as the active pattern
    var i = 0
    while i < recPattern.len:
      if checkCollisionPointRec(mouse, Rectangle(x: 2 + MARGIN_SIZE + recPattern[i].x,
          y: 40 + MARGIN_SIZE + recPattern[i].y, width: recPattern[i].width,
          height: recPattern[i].height)):
        activePattern = i
        break
      inc(i)
    ##  Check to see which color was clicked and set it as the active color
    for i in 0..<MAX_COLORS:
      if checkCollisionPointRec(mouse, colorRec[i]):
        activeCol = i
        break
  if isKeyPressed(Up):
    scale += 0.25
  if isKeyPressed(Down):
    scale -= 0.25
  if scale > 10.0:
    scale = 10.0
  elif scale <= 0.0:           ##  Change rotation
    scale = 0.25
  if isKeyPressed(Left):
    rotation -= 25.0
  if isKeyPressed(Right):
    rotation += 25.0
  if isKeyPressed(Space):
    rotation = 0.0
    scale = 1.0
  beginDrawing()
  clearBackground(Raywhite)
  ##  Draw the tiled area
  drawTextureTiled(texPattern, recPattern[activePattern], Rectangle(
      x: OPT_WIDTH + MARGIN_SIZE, y: MARGIN_SIZE,
      width: (float) screenWidth - OPT_WIDTH - 2 * MARGIN_SIZE, height: (float) screenHeight - 2 * MARGIN_SIZE),
                   (0.0, 0.0), rotation, scale, colors[activeCol])
  ##  Draw options
  drawRectangle(MARGIN_SIZE, MARGIN_SIZE, OPT_WIDTH - MARGIN_SIZE,
                screenHeight - 2 * MARGIN_SIZE, colorAlpha(Lightgray, 0.5))
  drawText("Select Pattern", 2 + MARGIN_SIZE, 30 + MARGIN_SIZE, 10, Black)
  drawTexture(texPattern, 2 + MARGIN_SIZE, 40 + MARGIN_SIZE, Black)
  drawRectangle((int)2 + MARGIN_SIZE + recPattern[activePattern].x,
                (int)40 + MARGIN_SIZE + recPattern[activePattern].y,
                (int)recPattern[activePattern].width,
                (int)recPattern[activePattern].height, colorAlpha(Darkblue, 0.3))
  drawText("Select Color", 2 + MARGIN_SIZE, 10 + 256 + MARGIN_SIZE, 10, Black)
  for i in 0..<MAX_COLORS:
    drawRectangleRec(colorRec[i], colors[i])
    if activeCol == i:
      drawRectangleLinesEx(colorRec[i], 3, colorAlpha(White, 0.5))
  drawText("Scale (UP/DOWN to change)", 2 + MARGIN_SIZE, 80 + 256 + MARGIN_SIZE, 10,
           Black)
  drawText(textFormat("%.2fx", scale), 2 + MARGIN_SIZE, 92 + 256 + MARGIN_SIZE, 20, Black)
  drawText("Rotation (LEFT/RIGHT to change)", 2 + MARGIN_SIZE,
           122 + 256 + MARGIN_SIZE, 10, Black)
  drawText(textFormat("%.0f degrees", rotation), 2 + MARGIN_SIZE,
           134 + 256 + MARGIN_SIZE, 20, Black)
  drawText("Press [SPACE] to reset", 2 + MARGIN_SIZE, 164 + 256 + MARGIN_SIZE, 10,
           Darkblue)
  ##  Draw FPS
  drawText(textFormat("%i FPS", getFPS()), 2 + MARGIN_SIZE, 2 + MARGIN_SIZE, 20, Black)
  endDrawing()
  ## ----------------------------------------------------------------------------------
##  De-Initialization
## --------------------------------------------------------------------------------------
unloadTexture(texPattern)
##  Unload texture
closeWindow()
##  Close window and OpenGL context
## --------------------------------------------------------------------------------------
