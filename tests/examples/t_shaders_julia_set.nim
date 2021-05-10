discard """
  action: "compile"
  joinable: false
  matrix: "; -d:release; --gc:orc -d:release"
"""

# ******************************************************************************************
#
#    raylib [shaders] example - julia sets
#
#    NOTE: This example requires raylib OpenGL 3.3 or ES2 versions for shaders support,
#          OpenGL 1.1 does not support shaders, recompile raylib to OpenGL 3.3 version.
#
#    NOTE: Shaders used in this example are #version 330 (OpenGL 3.3).
#
#    This example has been created using raylib 2.5 (www.raylib.com)
#    raylib is licensed under an unmodified zlib/libpng license (View raylib.h for details)
#
#    Example contributed by eggmund (@eggmund) and reviewed by Ramon Santamaria (@raysan5)
#
#    Copyright (c) 2019 eggmund (@eggmund) and Ramon Santamaria (@raysan5)
#    Converted in 2021 by greenfork
#
# ******************************************************************************************

import ../../src/nimraylib_now

const GLSL_VERSION = 330

##  A few good julia sets
var POINTS_OF_INTEREST: array[6, array[2, cfloat]] = [
  [-0.348827.cfloat, 0.607167],
  [-0.786268.cfloat, 0.169728],
  [-0.8.cfloat, 0.156],
  [0.285.cfloat, 0.0],
  [-0.835.cfloat, -0.2321],
  [-0.7017600000000001.cfloat, -0.3842]
]


##  Initialization
## --------------------------------------------------------------------------------------
var screenWidth = 800
var screenHeight = 450
initWindow(screenWidth, screenHeight, "raylib [shaders] example - julia sets")
##  Load julia set shader
##  NOTE: Defining 0 (NULL) for vertex shader forces usage of internal default vertex shader
var shader: Shader = loadShader(nil, textFormat(
    "resources/shaders/glsl%i/julia_set.fs", GLSL_VERSION))
##  c constant to use in z^2 + c
var c: array[2, cfloat] = [POINTS_OF_INTEREST[0][0], POINTS_OF_INTEREST[0][1]]
##  Offset and zoom to draw the julia set at. (centeRed on screen and default size)
var offset: array[2, cfloat] = [-(screenWidth div 2).cfloat, -(screenHeight div 2).cfloat]
var zoom: cfloat = 1.0
var offsetSpeed = Vector2()
##  Get variable (uniform) locations on the shader to connect with the program
##  NOTE: If uniform variable could not be found in the shader, function returns -1
var cLoc = getShaderLocation(shader, "c")
var zoomLoc = getShaderLocation(shader, "zoom")
var offsetLoc = getShaderLocation(shader, "offset")
##  Tell the shader what the screen dimensions, zoom, offset and c are
var screenDims: array[2, cfloat] = [screenWidth.cfloat, screenHeight.cfloat]
setShaderValue(shader, getShaderLocation(shader, "screenDims"), screenDims.addr, Vec2)
setShaderValue(shader, cLoc, c.addr, Vec2)
setShaderValue(shader, zoomLoc, addr(zoom), Float)
setShaderValue(shader, offsetLoc, offset.addr, Vec2)
##  Create a RenderTexture2D to be used for render to texture
var target: RenderTexture2D = loadRenderTexture(screenWidth, screenHeight)
var incrementSpeed = 0
##  Multiplier of speed to change c value
var showControls: bool = true
##  Show controls
var pause: bool = false
##  Pause animation
setTargetFPS(60)
##  Set our game to run at 60 frames-per-second
## --------------------------------------------------------------------------------------
##  Main game loop
while not windowShouldClose(): ##  Detect window close button or ESC key
  ##  Update
  ## ----------------------------------------------------------------------------------
  ##  Press [1 - 6] to reset c to a point of interest
  if isKeyPressed(One) or isKeyPressed(Two) or isKeyPressed(Three) or
      isKeyPressed(Four) or isKeyPressed(Five) or isKeyPressed(Six):
    if isKeyPressed(One):
      c[0] = POINTS_OF_INTEREST[0][0]
      c[1] = POINTS_OF_INTEREST[0][1]
    elif isKeyPressed(Two):
      c[0] = POINTS_OF_INTEREST[1][0]
      c[1] = POINTS_OF_INTEREST[1][1]
    elif isKeyPressed(Three):
      c[0] = POINTS_OF_INTEREST[2][0]
      c[1] = POINTS_OF_INTEREST[2][1]
    elif isKeyPressed(Four):
      c[0] = POINTS_OF_INTEREST[3][0]
      c[1] = POINTS_OF_INTEREST[3][1]
    elif isKeyPressed(Five):
      c[0] = POINTS_OF_INTEREST[4][0]
      c[1] = POINTS_OF_INTEREST[4][1]
    elif isKeyPressed(Six):
      c[0] = POINTS_OF_INTEREST[5][0]
      c[1] = POINTS_OF_INTEREST[5][1]
    setShaderValue(shader, cLoc, c.addr, Vec2)
  if isKeyPressed(Space):
    pause = not pause
  if isKeyPressed(F1):
    showControls = not showControls
  if not pause:
    if isKeyPressed(Right):
      inc(incrementSpeed)
    elif isKeyPressed(Left): ##  TODO: The idea is to zoom and move around with mouse
                               ##  Probably offset movement should be proportional to zoom level
      dec(incrementSpeed)
    if isMouseButtonDown(Left_Button) or isMouseButtonDown(Right_Button):
      if isMouseButtonDown(Left_Button):
        zoom += zoom*0.003
      if isMouseButtonDown(Right_Button):
        zoom -= zoom*0.003
      var mousePos: Vector2 = getMousePosition()
      offsetSpeed.x = mousePos.x - (float)(screenWidth div 2)
      offsetSpeed.y = mousePos.y - (float)(screenHeight div 2)
      ##  Slowly move camera to targetOffset
      offset[0] += getFrameTime() * offsetSpeed.x * 0.8
      offset[1] += getFrameTime() * offsetSpeed.y * 0.8
    else:
      offsetSpeed = (0.0, 0.0)
    setShaderValue(shader, zoomLoc, addr(zoom), Float)
    setShaderValue(shader, offsetLoc, offset.addr, Vec2)
    ##  Increment c value with time
    var amount = getFrameTime() * incrementSpeed.float * 0.0005
    c[0] += amount
    c[1] += amount
    setShaderValue(shader, cLoc, c.addr, Vec2)
  beginDrawing:
    clearBackground(Black)
    ##  Clear the screen of the previous frame.
    ##  Using a render texture to draw Julia set
    beginTextureMode(target):
      ##  Enable drawing to texture
      clearBackground(Black)
      ##  Clear the render texture
      ##  Draw a rectangle in shader mode to be used as shader canvas
      ##  NOTE: Rectangle uses font White character texture coordinates,
      ##  so shader can not be applied here directly because input vertexTexCoord
      ##  do not represent full screen coordinates (space where want to apply shader)
      drawRectangle(0, 0, getScreenWidth(), getScreenHeight(), Black)
    ##  Draw the saved texture and rendeRed julia set with shader
    ##  NOTE: We do not invert texture on Y, already consideRed inside shader
    beginShaderMode(shader):
      drawTexture(target.texture, 0, 0, White)
    if showControls:
      drawText("Press Mouse buttons right/left to zoom in/out and move", 10, 15,
               10, Raywhite)
      drawText("Press KEY_F1 to toggle these controls", 10, 30, 10, Raywhite)
      drawText("Press KEYS [1 - 6] to change point of interest", 10, 45, 10,
               Raywhite)
      drawText("Press KEY_LEFT | KEY_RIGHT to change speed", 10, 60, 10, Raywhite)
      drawText("Press KEY_SPACE to pause movement animation", 10, 75, 10, Raywhite)
## ----------------------------------------------------------------------------------
##  De-Initialization
## --------------------------------------------------------------------------------------
unloadShader(shader)
##  Unload shader
unloadRenderTexture(target)
##  Unload render texture
closeWindow()
##  Close window and OpenGL context
## --------------------------------------------------------------------------------------
