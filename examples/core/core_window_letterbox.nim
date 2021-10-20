# ******************************************************************************************
#
#    raylib [core] example - window scale letterbox (and virtual mouse)
#
#    This example has been created using raylib 2.5 (www.raylib.com)
#    raylib is licensed under an unmodified zlib/libpng license (View raylib.h for details)
#
#    Example contributed by Anata (@anatagawa) and reviewed by Ramon Santamaria (@raysan5)
#
#    Copyright (c) 2019 Anata (@anatagawa) and Ramon Santamaria (@raysan5)
#    Converted in 2021 by greenfork
#
# ******************************************************************************************

import lenientops
import nimraylib_now

##  Clamp Vector2 value with min and max and return a new vector2
##  NOTE: Required for virtual mouse, to clamp inside virtual game size
proc clampValue(value: Vector2, minV: Vector2, maxV: Vector2): Vector2 =
  result = value
  result.x = if (result.x > maxV.x): maxV.x else: result.x
  result.x = if (result.x < minV.x): minV.x else: result.x
  result.y = if (result.y > maxV.y): maxV.y else: result.y
  result.y = if (result.y < minV.y): minV.y else: result.y

var windowWidth = 800
var windowHeight = 450
##  Enable config flags for resizable window and vertical synchro
setConfigFlags(Window_Resizable or Vsync_Hint)
initWindow(windowWidth, windowHeight,
           "raylib [core] example - window scale letterbox")
setWindowMinSize(320, 240)
var gameScreenWidth = 640
var gameScreenHeight = 480
##  Render texture initialization, used to hold the rendering result so we can easily resize it
var target: RenderTexture2D = loadRenderTexture(gameScreenWidth, gameScreenHeight)
setTextureFilter(target.texture, Bilinear)
##  Texture scale filter to use
var colors: array[10, Color]
for color in colors.mitems:
  color = Color(r: getRandomValue(100, 250).uint8, g: getRandomValue(50, 150).uint8,
                b: getRandomValue(10, 100).uint8, a: 255'u8)
setTargetFPS(60)
##  Set our game to run at 60 frames-per-second
## --------------------------------------------------------------------------------------
##  Main game loop
while not windowShouldClose(): ##  Detect window close button or ESC key
  ##  Update
  ## ----------------------------------------------------------------------------------
  ##  Compute required framebuffer scaling
  var scale: float = min((float)(getScreenWidth() / gameScreenWidth),
                           (float)(getScreenHeight() / gameScreenHeight))
  if isKeyPressed(Space):
    ##  Recalculate random colors for the bars
    for color in colors.mitems:
      color = Color(r: getRandomValue(100, 250).uint8, g: getRandomValue(50, 150).uint8,
                    b: getRandomValue(10, 100).uint8, a: 255'u8)
  var mouse: Vector2 = getMousePosition()
  var virtualMouse: Vector2
  virtualMouse.x = (mouse.x - (getScreenWidth() - (gameScreenWidth * scale)) * 0.5) / scale
  virtualMouse.y = (mouse.y - (getScreenHeight() - (gameScreenHeight * scale)) * 0.5) / scale
  virtualMouse = clampValue(virtualMouse, (0.0, 0.0), (gameScreenWidth.float, gameScreenHeight.float))
  ##  Apply the same transformation as the virtual mouse to the real mouse (i.e. to work with raygui)
  # setMouseOffset(
  #   -((getScreenWidth() - (gameScreenWidth * scale)) * 0.5).cint,
  #   -((getScreenHeight() - (gameScreenHeight * scale)) * 0.5).cint
  # )
  # setMouseScale(1.0/scale, 1.0/scale)

  ## ----------------------------------------------------------------------------------
  ##  Draw
  ##
  ## ----------------------------------------------------------------------------------
  beginDrawing()
  clearBackground(Black)
  ##  Draw everything in the render texture, note this will not be rendered on screen, yet
  beginTextureMode(target)
  clearBackground(Raywhite)
  ##  Clear render texture background color
  var i = 0
  while i < 10:
    drawRectangle(0, (gameScreenHeight div 10) * i, gameScreenWidth,
                  gameScreenHeight div 10, colors[i])
    inc(i)
  drawText("If executed inside a window,\nyou can resize the window,\nand see the screen scaling!",
           10, 25, 20, White)
  drawText(textFormat("Default Mouse: [%i , %i]", mouse.x.int, mouse.y.int),
    350, 25, 20, Green)
  drawText(textFormat("Virtual Mouse: [%i , %i]", virtualMouse.x.int, virtualMouse.y.int),
    350, 55, 20, Yellow)
  endTextureMode()
  ## Draw RenderTexture2D to window, properly scaled
  drawTexturePro(
    target.texture,
    (0.0, 0.0, target.texture.width.float, -target.texture.height.float),
    ((getScreenWidth() - (gameScreenWidth*scale))*0.5,
     (getScreenHeight() - (gameScreenHeight*scale))*0.5,
     (gameScreenWidth*scale),
     (gameScreenHeight*scale)
    ),
    (0.0, 0.0),
    0.0,
    White
  )
  endDrawing()
## --------------------------------------------------------------------------------------
##  De-Initialization
## --------------------------------------------------------------------------------------
unloadRenderTexture(target)
##  Unload render texture
closeWindow()
##  Close window and OpenGL context
## --------------------------------------------------------------------------------------
