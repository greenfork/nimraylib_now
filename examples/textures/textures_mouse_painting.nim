# ******************************************************************************************
#
#    raylib [textures] example - Mouse painting
#
#    This example has been created using raylib 2.5 (www.raylib.com)
#    raylib is licensed under an unmodified zlib/libpng license (View raylib.h for details)
#
#    Example contributed by Chris Dill (@MysteriousSpace) and reviewed by Ramon Santamaria (@raysan5)
#
#    Copyright (c) 2019 Chris Dill (@MysteriousSpace) and Ramon Santamaria (@raysan5)
#    Converted in 2021 by greenfork
#
# ******************************************************************************************

import ../../src/nimraylib_now/raylib

const
  MAX_COLORS_COUNT = 23

##  Initialization
## --------------------------------------------------------------------------------------
var screenWidth = 800
var screenHeight = 450
initWindow(screenWidth, screenHeight,
           "raylib [textures] example - mouse painting")
##  Colours to choose from
var colors: array[MAX_COLORS_COUNT, Color] = [Raywhite, Yellow, Gold, Orange, Pink, Red,
    Maroon, Green, Lime, Darkgreen, Skyblue, Blue, Darkblue, Purple, Violet,
    Darkpurple, Beige, Brown, Darkbrown, Lightgray, Gray, Darkgray, Black]
##  Define colorsRecs data (for every rectangle)
var colorsRecs: array[MAX_COLORS_COUNT, Rectangle]
for i in 0..<MAX_COLORS_COUNT:
  colorsRecs[i].x = (float) 10 + 30 * i + 2 * i
  colorsRecs[i].y = 10.0
  colorsRecs[i].width = 30
  colorsRecs[i].height = 30
var colorSelected = 0
var colorSelectedPrev = colorSelected
var colorMouseHover = 0
var brushSize = 20
var btnSaveRec: Rectangle = (750.0, 10.0, 40.0, 30.0)
var btnSaveMouseHover: bool = false
var showSaveMessage: bool = false
var saveMessageCounter = 0
##  Create a RenderTexture2D to use as a canvas
var target: RenderTexture2D = loadRenderTexture(screenWidth, screenHeight)
##  Clear render texture before entering the game loop
beginTextureMode(target)
clearBackground(colors[0])
endTextureMode()
setTargetFPS(120)
##  Set our game to run at 120 frames-per-second
## --------------------------------------------------------------------------------------
##  Main game loop
while not windowShouldClose(): ##  Detect window close button or ESC key
  ##  Update
  ## ----------------------------------------------------------------------------------
  var mousePos: Vector2 = getMousePosition()
  ##  Move between colors with keys
  if isKeyPressed(Right):
    inc(colorSelected)
  elif isKeyPressed(Left):
    dec(colorSelected)
  if colorSelected >= MAX_COLORS_COUNT:
    colorSelected = MAX_COLORS_COUNT - 1
  elif colorSelected < 0:      ##  Choose color with mouse
    colorSelected = 0
  var i = 0
  while i < MAX_COLORS_COUNT:
    if checkCollisionPointRec(mousePos, colorsRecs[i]):
      colorMouseHover = i
      break
    else:
      colorMouseHover = -1
    inc(i)
  if (colorMouseHover >= 0) and isMouseButtonPressed(Left_Button):
    colorSelected = colorMouseHover
    colorSelectedPrev = colorSelected
  brushSize += getMouseWheelMove().int * 5
  if brushSize < 2:
    brushSize = 2
  if brushSize > 50:
    brushSize = 50
  if isKeyPressed(C):
    ##  Clear render texture to clear color
    beginTextureMode(target)
    clearBackground(colors[0])
    endTextureMode()
  if isMouseButtonDown(Left_Button) or
      (getGestureDetected() == Drag):
    ##  Paint circle into render texture
    ##  NOTE: To avoid discontinuous circles, we could store
    ##  previous-next mouse points and just draw a line using brush size
    beginTextureMode(target)
    if mousePos.y > 50:
      drawCircle(mousePos.x.int, mousePos.y.int, brushSize.float, colors[colorSelected])
    endTextureMode()
  if isMouseButtonDown(Right_Button):
    colorSelected = 0
    ##  Erase circle from render texture
    beginTextureMode(target)
    if mousePos.y > 50:
      drawCircle(mousePos.x.int, mousePos.y.int, brushSize.float, colors[0])
    endTextureMode()
  else:
    colorSelected = colorSelectedPrev
  ##  Check mouse hover save button
  if checkCollisionPointRec(mousePos, btnSaveRec):
    btnSaveMouseHover = true
  else:
    btnSaveMouseHover = false
  ##  Image saving logic
  ##  NOTE: Saving painted texture to a default named image
  if (btnSaveMouseHover and isMouseButtonReleased(Left_Button)) or
      isKeyPressed(S):
    var image: Image = getTextureData(target.texture)
    imageFlipVertical(addr(image))
    discard exportImage(image, "my_amazing_texture_painting.png")
    unloadImage(image)
    showSaveMessage = true
  if showSaveMessage:
    ##  On saving, show a full screen message for 2 seconds
    inc(saveMessageCounter)
    if saveMessageCounter > 240:
      showSaveMessage = false
      saveMessageCounter = 0
  beginDrawing()
  clearBackground(Raywhite)
  ##  NOTE: Render texture must be y-flipped due to default OpenGL coordinates (left-bottom)
  drawTextureRec(
    target.texture,
    Rectangle(x: 0.0, y: 0.0, width: target.texture.width.float, height: -target.texture.height.float),
    Vector2(x: 0, y: 0),
    White
  )
  ##  Draw drawing circle for reference
  if mousePos.y > 50:
    if isMouseButtonDown(Right_Button):
      drawCircleLines(mousePos.x.int, mousePos.y.int, brushSize.float, Gray)
    else:
      drawCircle(getMouseX().int, getMouseY().int, brushSize.float, colors[colorSelected])
  drawRectangle(0, 0, getScreenWidth(), 50, Raywhite)
  drawLine(0, 50, getScreenWidth(), 50, Lightgray)
  ##  Draw color selection rectangles
  for i in 0..<MAX_COLORS_COUNT:
    drawRectangleRec(colorsRecs[i], colors[i])
  drawRectangleLines(10, 10, 30, 30, Lightgray)
  if colorMouseHover >= 0:
    drawRectangleRec(colorsRecs[colorMouseHover], fade(White, 0.6))
  drawRectangleLinesEx(
    Rectangle(
      x: colorsRecs[colorSelected].x - 2,
      y: colorsRecs[colorSelected].y - 2,
      width: colorsRecs[colorSelected].width + 4,
      height: colorsRecs[colorSelected].height + 4
    ),
    2,
    Black
  )

  drawRectangleLinesEx(btnSaveRec, 2, if btnSaveMouseHover: Red else: Black)
  drawText("SAVE!", 755, 20, 10, if btnSaveMouseHover: Red else: Black)
  ##  Draw save image message
  if showSaveMessage:
    drawRectangle(0, 0, getScreenWidth(), getScreenHeight(), fade(Raywhite, 0.8))
    drawRectangle(0, 150, getScreenWidth(), 80, Black)
    drawText("IMAGE SAVED:  my_amazing_texture_painting.png", 150, 180, 20,
             Raywhite)
  endDrawing()
## ----------------------------------------------------------------------------------
##  De-Initialization
## --------------------------------------------------------------------------------------
unloadRenderTexture(target)
##  Unload render texture
closeWindow()
##  Close window and OpenGL context
## --------------------------------------------------------------------------------------
