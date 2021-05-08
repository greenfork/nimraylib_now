# ******************************************************************************************
#
#    raylib [shaders] example - Apply a postprocessing shader and connect a custom uniform variable
#
#    NOTE: This example requires raylib OpenGL 3.3 or ES2 versions for shaders support,
#          OpenGL 1.1 does not support shaders, recompile raylib to OpenGL 3.3 version.
#
#    NOTE: Shaders used in this example are #version 330 (OpenGL 3.3), to test this example
#          on OpenGL ES 2.0 platforms (Android, Raspberry Pi, HTML5), use #version 100 shaders
#          raylib comes with shaders ready for both versions, check raylib/shaders install folder
#
#    This example has been created using raylib 1.3 (www.raylib.com)
#    raylib is licensed under an unmodified zlib/libpng license (View raylib.h for details)
#
#    Copyright (c) 2015 Ramon Santamaria (@raysan5)
#    Converted in 2021 by greenfork
#
# ******************************************************************************************

import ../../src/nimraylib_now/raylib

const GLSL_VERSION = 330

##  Initialization
## --------------------------------------------------------------------------------------
var screenWidth = 800
var screenHeight = 450
setConfigFlags(Msaa_4x_Hint)
##  Enable Multi Sampling Anti Aliasing 4x (if available)
initWindow(screenWidth, screenHeight,
           "raylib [shaders] example - custom uniform variable")
##  Define the camera to look into our 3d world
var camera = Camera()
camera.position = (8.0, 8.0, 8.0)
camera.target = (0.0, 1.5, 0.0)
camera.up = (0.0, 1.0, 0.0)
camera.fovy = 45.0
camera.projection = Perspective
var model: Model = loadModel("resources/models/barracks.obj")
##  Load OBJ model
var texture: Texture2D = loadTexture("resources/models/barracks_diffuse.png")
##  Load model texture (diffuse map)
model.materials[0].maps[int(Albedo)].texture = texture
##  Set model diffuse texture
var position = Vector3()
##  Set model position
##  Load postprocessing shader
##  NOTE: Defining 0 (NULL) for vertex shader forces usage of internal default vertex shader
var shader: Shader = loadShader(nil, textFormat("resources/shaders/glsl%i/swirl.fs",
    GLSL_VERSION))
##  Get variable (uniform) location on the shader to connect with the program
##  NOTE: If uniform variable could not be found in the shader, function returns -1
var swirlCenterLoc = getShaderLocation(shader, "center")
var swirlCenter: array[2, cfloat] = [(screenWidth div 2).cfloat, (screenHeight div 2).cfloat]
##  Create a RenderTexture2D to be used for render to texture
var target: RenderTexture2D = loadRenderTexture(screenWidth, screenHeight)
##  Setup orbital camera
setCameraMode(camera, Orbital)
##  Set an orbital camera mode
setTargetFPS(60)
##  Set our game to run at 60 frames-per-second
## --------------------------------------------------------------------------------------
##  Main game loop
while not windowShouldClose(): ##  Detect window close button or ESC key
  ##  Update
  ## ----------------------------------------------------------------------------------
  var mousePosition: Vector2 = getMousePosition()
  swirlCenter[0] = mousePosition.x
  swirlCenter[1] = screenHeight.float - mousePosition.y
  ##  Send new value to the shader to be used on drawing
  setShaderValue(shader, swirlCenterLoc, swirlCenter.addr, Vec2)
  updateCamera(addr(camera))
  ##  Update camera
  ## ----------------------------------------------------------------------------------
  ##  Draw
  ## ----------------------------------------------------------------------------------
  beginDrawing:
    clearBackground(Raywhite)
    beginTextureMode(target): ##  Enable drawing to texture
      clearBackground(Raywhite) ##  Clear texture background
      beginMode3D(camera): ##  Begin 3d mode drawing
        drawModel(model, position, 0.5, White) ##  Draw 3d model with texture
        drawGrid(10, 1.0) ##  Draw a grid
      ##  End 3d mode drawing, returns to orthographic 2d mode
      drawText("TEXT DRAWN IN RENDER TEXTURE", 200, 10, 30, Red)
    ##  End drawing to texture (now we have a texture available for next passes)
    beginShaderMode(shader):
      # NOTE: Render texture must be y-flipped due to default OpenGL coordinates (left-bottom)
      drawTextureRec(
        target.texture,
        Rectangle(x: 0, y: 0, width: target.texture.width.float, height: -target.texture.height.float),
        Vector2(x: 0, y: 0),
        White
      )
    ##  Draw some 2d text over drawn texture
    drawText("(c) Barracks 3D model by Alberto Cano", screenWidth - 220,
             screenHeight - 20, 10, Gray)
    drawFPS(10, 10)
## ----------------------------------------------------------------------------------
##  De-Initialization
## --------------------------------------------------------------------------------------
unloadShader(shader)
##  Unload shader
unloadTexture(texture)
##  Unload texture
unloadModel(model)
##  Unload model
unloadRenderTexture(target)
##  Unload render texture
closeWindow()
##  Close window and OpenGL context
## --------------------------------------------------------------------------------------
