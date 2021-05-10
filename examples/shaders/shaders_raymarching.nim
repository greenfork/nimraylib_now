#*******************************************************************************************
#
#   raylib [shaders] example - Raymarching shapes generation
#
#   NOTE: This example requires raylib OpenGL 3.3 or ES2 versions for shaders support,
#         OpenGL 1.1 does not support shaders, recompile raylib to OpenGL 3.3 version.
#
#   NOTE: Shaders used in this example are #version 330 (OpenGL 3.3), to test this example
#         on OpenGL ES 2.0 platforms (Android, Raspberry Pi, HTML5), use #version 100 shaders
#         raylib comes with shaders ready for both versions, check raylib/shaders install folder
#
#   This example has been created using raylib 2.0 (www.raylib.com)
#   raylib is licensed under an unmodified zlib/libpng license (View raylib.h for details)
#
#   Copyright (c) 2018 Ramon Santamaria (@raysan5)
#   /Converted in 2*20 by Guevara-chan.
#   Adapted in 2021 by greenfork
#
#*******************************************************************************************

import nimraylib_now
const GLSL_VERSION = 330

#  Initialization
# --------------------------------------------------------------------------------------
var
  screenWidth = 800
  screenHeight = 450

setConfigFlags WINDOW_RESIZABLE
initWindow screenWidth, screenHeight, "raylib [shaders] example - raymarching shapes"

var camera = Camera()
camera.position = (x: 2.5, y: 2.5, z: 3.0)    #  Camera position
camera.target = (x: 0.0, y: 0.0, z: 0.7)      #  Camera looking at point
camera.up = (x: 0.0, y: 1.0, z: 0.0)          #  Camera up vector (rotation towards target)
camera.fovy = 65.0                                     #  Camera field-of-view Y

setCameraMode camera, Free                       #  Set camera mode

#  Load raymarching shader
#  NOTE: Defining 0 (NULL) for vertex shader forces usage of internal default vertex shader
let
  shader = loadShader(nil, textFormat("resources/shaders/glsl%i/raymarching.fs", GLSL_VERSION))
  # Get shader locations for required uniforms
  viewEyeLoc      = getShaderLocation(shader, "viewEye")
  viewCenterLoc   = getShaderLocation(shader, "viewCenter")
  runTimeLoc      = getShaderLocation(shader, "runTime")
  resolutionLoc   = getShaderLocation(shader, "resolution")

var resolution = [screenWidth.cfloat, screenHeight.cfloat]
setShaderValue shader, resolutionLoc, resolution.addr, VEC2

var runTime: cfloat = 0.0

60.setTargetFPS                         #  Set our game to run at 60 frames-per-second
# --------------------------------------------------------------------------------------

#  Main game loop
while not windowShouldClose():          #  Detect window close button or ESC key
    #  Check if screen is resized
    # ----------------------------------------------------------------------------------
    if isWindowResized():
        screenWidth  = getScreenWidth()
        screenHeight = getScreenHeight()
        resolution   = [screenWidth.cfloat, screenHeight.cfloat]
        setShaderValue shader, resolutionLoc, resolution.addr, VEC2

    #  Update
    # ----------------------------------------------------------------------------------
    camera.addr.updateCamera           #  Update camera

    var
      cameraPos = [camera.position.x, camera.position.y, camera.position.z]
      cameraTarget = [camera.target.x, camera.target.y, camera.target.z]

      deltaTime = getFrameTime()
    runTime += deltaTime

    #  Set shader required uniform values
    setShaderValue shader, viewEyeLoc, cameraPos.addr, VEC3
    setShaderValue shader, viewCenterLoc, cameraTarget.addr, VEC3
    setShaderValue shader, runTimeLoc, runTime.addr, FLOAT
    # ----------------------------------------------------------------------------------

    #  Draw
    # ----------------------------------------------------------------------------------
    beginDrawing:

      clearBackground RAYWHITE

      #  We only draw a white full-screen rectangle,
      #  frame is generated in shader using raymarching
      beginShaderMode(shader):
        drawRectangle 0, 0, screenWidth, screenHeight, WHITE

      drawText "(c) Raymarching shader by Iñigo Quilez. MIT License.", screenWidth - 280, screenHeight - 20, 10, BLACK
    # ----------------------------------------------------------------------------------

#  De-Initialization
# --------------------------------------------------------------------------------------
unloadShader shader            #  Unload shader

closeWindow()                  #  Close window and OpenGL context
# --------------------------------------------------------------------------------------
