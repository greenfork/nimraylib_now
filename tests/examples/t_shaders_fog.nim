discard """
  action: "compile"
  joinable: false
  matrix: "; -d:release; --gc:orc -d:release"
"""

# ******************************************************************************************
#
#    raylib [shaders] example - fog
#
#    NOTE: This example requires raylib OpenGL 3.3 or ES2 versions for shaders support,
#          OpenGL 1.1 does not support shaders, recompile raylib to OpenGL 3.3 version.
#
#    NOTE: Shaders used in this example are #version 330 (OpenGL 3.3).
#
#    This example has been created using raylib 2.5 (www.raylib.com)
#    raylib is licensed under an unmodified zlib/libpng license (View raylib.h for details)
#
#    Example contributed by Chris Camacho (@chriscamacho) and reviewed by Ramon Santamaria (@raysan5)
#
#    Chris Camacho (@chriscamacho -  http://bedroomcoders.co.uk/) notes:
#
#    This is based on the PBR lighting example, but greatly simplified to aid learning...
#    actually there is very little of the PBR example left!
#    When I first looked at the bewildering complexity of the PBR example I feaRed
#    I would never understand how I could do simple lighting with raylib however its
#    a testement to the authors of raylib (including rlights.h) that the example
#    came together fairly quickly.
#
#    Copyright (c) 2019 Chris Camacho (@chriscamacho) and Ramon Santamaria (@raysan5)
#    Converted in 2021 by greenfork
#
# ******************************************************************************************

import ../../src/nimraylib_now
import ./rlights

const GLSL_VERSION = 330

##  Initialization
## --------------------------------------------------------------------------------------
var screenWidth = 800
var screenHeight = 450
setConfigFlags(Msaa_4x_Hint)
##  Enable Multi Sampling Anti Aliasing 4x (if available)
initWindow(screenWidth, screenHeight, "raylib [shaders] example - fog")
##  Define the camera to look into our 3d world
var camera = Camera(
  position: (2.0, 2.0, 6.0),
  target: (0.0, 0.5, 0.0),
  up: (0.0, 1.0, 0.0),
  fovy: 45.0,
  projection: Perspective
)
##  Load models and texture
var modelA: Model = loadModelFromMesh(genMeshTorus(0.4, 1.0, 16, 32))
var modelB: Model = loadModelFromMesh(genMeshCube(1.0, 1.0, 1.0))
var modelC: Model = loadModelFromMesh(genMeshSphere(0.5, 32, 32))
var texture: Texture = loadTexture("resources/texel_checker.png")
##  Assign texture to default model material
modelA.materials[0].maps[int(Albedo)].texture = texture
modelB.materials[0].maps[int(Albedo)].texture = texture
modelC.materials[0].maps[int(Albedo)].texture = texture
##  Load shader and set up some uniforms
var shader: Shader = loadShader(textFormat(
    "resources/shaders/glsl%i/base_lighting.vs", GLSL_VERSION), textFormat(
    "resources/shaders/glsl%i/fog.fs", GLSL_VERSION))
shader.locs[int(Matrix_Model)] = getShaderLocation(shader, "matModel")
shader.locs[int(Vector_View)] = getShaderLocation(shader, "viewPos")
##  Ambient light level
var ambientLoc = getShaderLocation(shader, "ambient")
var shaderPosition = [0.2.cfloat, 0.2, 0.2, 1.0]
setShaderValue(shader, ambientLoc, shaderPosition.addr, VEC4)
var fogDensity: cfloat = 0.15
var fogDensityLoc = getShaderLocation(shader, "fogDensity")
setShaderValue(shader, fogDensityLoc, addr(fogDensity), Float)
##  NOTE: All models share the same shader
modelA.materials[0].shader = shader
modelB.materials[0].shader = shader
modelC.materials[0].shader = shader
##  Using just 1 point lights
discard createLight(LightType.Point, (0.0, 2.0, 6.0), vector3Zero(), White, shader)
setCameraMode(camera, Orbital)
##  Set an orbital camera mode
setTargetFPS(60)
##  Set our game to run at 60 frames-per-second
## --------------------------------------------------------------------------------------
##  Main game loop
while not windowShouldClose(): ##  Detect window close button or ESC key
  ##  Update
  ## ----------------------------------------------------------------------------------
  updateCamera(addr(camera))
  ##  Update camera
  if isKeyDown(Up):
    fogDensity += 0.001
    if fogDensity > 1.0:
      fogDensity = 1.0
  if isKeyDown(Down):
    fogDensity -= 0.001
    if fogDensity < 0.0:
      fogDensity = 0.0
  setShaderValue(shader, fogDensityLoc, addr(fogDensity), Float)
  ##  Rotate the torus
  modelA.transform = modelA.transform * rotateX(-0.025)
  modelA.transform = modelA.transform * rotateZ(0.012)
  ##  Update the light shader with the camera view position
  setShaderValue(shader, shader.locs[int(Vector_View)], addr(camera.position.x), Vec3)
  ## ----------------------------------------------------------------------------------
  ##  Draw
  ## ----------------------------------------------------------------------------------
  beginDrawing:
    clearBackground(Gray)
    beginMode3D(camera):
      ##  Draw the three models
      drawModel(modelA, vector3Zero(), 1.0, White)
      drawModel(modelB, (-2.6, 0.0, 0.0), 1.0, White)
      drawModel(modelC, (2.6, 0.0, 0.0), 1.0, White)
      var i = -20
      while i < 20:
        drawModel(modelA, (i.float, 0.0, 2.0), 1.0, White)
        inc(i, 2)
    drawText(textFormat("Use KEY_UP/KEY_DOWN to change fog density [%.2f]",
                        fogDensity), 10, 10, 20, Raywhite)
## ----------------------------------------------------------------------------------
##  De-Initialization
## --------------------------------------------------------------------------------------
unloadModel(modelA)
##  Unload the model A
unloadModel(modelB)
##  Unload the model B
unloadModel(modelC)
##  Unload the model C
unloadTexture(texture)
##  Unload the texture
unloadShader(shader)
##  Unload shader
closeWindow()
##  Close window and OpenGL context
## --------------------------------------------------------------------------------------
