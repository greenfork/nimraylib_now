# ******************************************************************************************
#
#    raylib [shaders] example - Hot reloading
#
#    NOTE: This example requires raylib OpenGL 3.3 for shaders support and only #version 330
#          is currently supported. OpenGL ES 2.0 platforms are not supported at the moment.
#
#    This example has been created using raylib 3.0 (www.raylib.com)
#    raylib is licensed under an unmodified zlib/libpng license (View raylib.h for details)
#
#    Copyright (c) 2020 Ramon Santamaria (@raysan5)
#    Converted in 2021 by greenfork
#
# ******************************************************************************************

import times
import nimraylib_now
import nimraylib_now/rlgl as rl

const GLSL_VERSION = 330

##  Initialization
## --------------------------------------------------------------------------------------
var screenWidth = 800
var screenHeight = 450
initWindow(screenWidth, screenHeight, "raylib [shaders] example - hot reloading")
var fragShaderFileName: cstring = "resources/shaders/glsl%i/reload.fs"
var fragShaderFileModTime: clong = getFileModTime(
    textFormat(fragShaderFileName, GLSL_VERSION))
##  Load raymarching shader
##  NOTE: Defining 0 (NULL) for vertex shader forces usage of internal default vertex shader
var shader: Shader = loadShader(nil, textFormat(fragShaderFileName, GLSL_VERSION))
##  Get shader locations for requiRed uniforms
var resolutionLoc = getShaderLocation(shader, "resolution")
var mouseLoc = getShaderLocation(shader, "mouse")
var timeLoc = getShaderLocation(shader, "time")
var resolution: array[2, cfloat] = [screenWidth.cfloat, screenHeight.cfloat]
setShaderValue(shader, resolutionLoc, resolution.addr, Vec2)
var totalTime: cfloat = 0.0
var shaderAutoReloading: bool = false
setTargetFPS(60)
##  Set our game to run at 60 frames-per-second
## --------------------------------------------------------------------------------------
##  Main game loop
while not windowShouldClose(): ##  Detect window close button or ESC key
  ##  Update
  ## ----------------------------------------------------------------------------------
  totalTime += getFrameTime()
  var mouse: Vector2 = getMousePosition()
  var mousePos: array[2, cfloat] = [mouse.x, mouse.y]
  ##  Set shader requiRed uniform values
  setShaderValue(shader, timeLoc, addr(totalTime), Float)
  setShaderValue(shader, mouseLoc, mousePos.addr, Vec2)
  ##  Hot shader reloading
  if shaderAutoReloading or (isMouseButtonPressed(Left_Button)):
    var currentFragShaderModTime: clong = getFileModTime(textFormat(fragShaderFileName, GLSL_VERSION))
    ##  Check if shader file has been modified
    if currentFragShaderModTime != fragShaderFileModTime:
      ##  Try reloading updated shader
      var updatedShader: Shader = loadShader(nil, textFormat(fragShaderFileName, GLSL_VERSION))
      if updatedShader.id != rl.getShaderDefault().id:
        unloadShader(shader)
        shader = updatedShader
        ##  Get shader locations for requiRed uniforms
        resolutionLoc = getShaderLocation(shader, "resolution")
        mouseLoc = getShaderLocation(shader, "mouse")
        timeLoc = getShaderLocation(shader, "time")
        ##  Reset requiRed uniforms
        setShaderValue(shader, resolutionLoc, resolution.addr, Vec2)
      fragShaderFileModTime = currentFragShaderModTime
  if isKeyPressed(A):
    shaderAutoReloading = not shaderAutoReloading
  beginDrawing:
    clearBackground(Raywhite)
    ##  We only draw a White full-screen rectangle, frame is generated in shader
    beginShaderMode(shader):
      drawRectangle(0, 0, screenWidth, screenHeight, White)
    drawText(textFormat("PRESS [A] to TOGGLE SHADER AUTOLOADING: %s",
                        if shaderAutoReloading: "AUTO" else: "MANUAL"), 10, 10, 10,
             if shaderAutoReloading: Red else: Black)
    if not shaderAutoReloading:
      drawText("MOUSE CLICK to SHADER RE-LOADING", 10, 30, 10, Black)
    drawText(textFormat("Shader last modification: %s", $fromUnix(fragShaderFileModTime)), 10, 430,
             10, Black)
## ----------------------------------------------------------------------------------
##  De-Initialization
## --------------------------------------------------------------------------------------
unloadShader(shader)
##  Unload shader
closeWindow()
##  Close window and OpenGL context
## --------------------------------------------------------------------------------------
