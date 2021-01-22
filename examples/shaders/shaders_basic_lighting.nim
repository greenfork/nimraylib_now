# ******************************************************************************************
#
#    raylib [shaders] example - basic lighting
#
#    NOTE: This example requires raylib OpenGL 3.3 or ES2 versions for shaders support,
#          OpenGL 1.1 does not support shaders, recompile raylib to OpenGL 3.3 version.
#
#    NOTE: Shaders used in this example are #version 330 (OpenGL 3.3).
#
#    This example has been created using raylib 2.5 (www.raylib.com)
#    raylib is licensed under an unmodified zlib/libpng license (View raylib.h for details)
#
#    Example contributed by Chris Camacho (@codifies) and reviewed by Ramon Santamaria (@raysan5)
#
#    Chris Camacho (@codifies -  http://bedroomcoders.co.uk/) notes:
#
#    This is based on the PBR lighting example, but greatly simplified to aid learning...
#    actually there is very little of the PBR example left!
#    When I first looked at the bewildering complexity of the PBR example I feaRed
#    I would never understand how I could do simple lighting with raylib however its
#    a testement to the authors of raylib (including rlights.h) that the example
#    came together fairly quickly.
#
#    Copyright (c) 2019 Chris Camacho (@codifies) and Ramon Santamaria (@raysan5)
#    Converted in 2021 by greenfork
#
# ******************************************************************************************

import math
import ../../src/nimraylib_now/[raylib, raymath]
import rlights

const GLSL_VERSION = 330

##  Initialization
## --------------------------------------------------------------------------------------
var screenWidth = 800
var screenHeight = 450
setConfigFlags(Msaa_4x_Hint)
##  Enable Multi Sampling Anti Aliasing 4x (if available)
initWindow(screenWidth, screenHeight,
           "raylib [shaders] example - basic lighting")
##  Define the camera to look into our 3d world
var camera = Camera()
camera.position = (2.0, 2.0, 6.0) ##  Camera position
camera.target = (0.0, 0.5, 0.0) ##  Camera looking at point
camera.up = (0.0, 1.0, 0.0) ##  Camera up vector (rotation towards target)
camera.fovy = 45.0 ##  Camera field-of-view Y
camera.`type` = Perspective
##  Camera mode type
##  Load models
var modelA: Model = loadModelFromMesh(genMeshTorus(0.4, 1.0, 16, 32))
var modelB: Model = loadModelFromMesh(genMeshCube(1.0, 1.0, 1.0))
var modelC: Model = loadModelFromMesh(genMeshSphere(0.5, 32, 32))

##  Load models texture
var texture: Texture = loadTexture("resources/texel_checker.png")
##  Assign texture to default model material
modelA.materials[0].maps[int(Albedo)].texture = texture
modelB.materials[0].maps[int(Albedo)].texture = texture
modelC.materials[0].maps[int(Albedo)].texture = texture
var shader: Shader = loadShader(textFormat(
    "resources/shaders/glsl%i/base_lighting.vs", GLSL_VERSION), textFormat(
    "resources/shaders/glsl%i/lighting.fs", GLSL_VERSION))
##  Get some shader locations
shader.locs[int(Matrix_Model)] = getShaderLocation(shader, "matModel")
shader.locs[int(Vector_View)] = getShaderLocation(shader, "viewPos")
##  ambient light level
var ambientLoc = getShaderLocation(shader, "ambient")
var uniformLocations = [0.2.cfloat, 0.2, 0.2, 1.0]
setShaderValue(shader, ambientLoc, uniformLocations.addr, VEC4)
var angle = 6.282
##  All models use the same shader
modelA.materials[0].shader = shader
modelB.materials[0].shader = shader
modelC.materials[0].shader = shader
##  Using 4 point lights, White, Red, Green and Blue
var lights: array[MAX_LIGHTS, Light]
lights[0] = createLight(LightType.Point, (4.0, 2.0, 4.0), vector3Zero(), White, shader)
lights[1] = createLight(LightType.Point, (4.0, 2.0, 4.0), vector3Zero(), Red, shader)
lights[2] = createLight(LightType.Point, (0.0, 4.0, 2.0), vector3Zero(), Green, shader)
lights[3] = createLight(LightType.Point, (0.0, 4.0, 2.0), vector3Zero(), Blue, shader)
setCameraMode(camera, Orbital)
##  Set an orbital camera mode
setTargetFPS(60) ##  Set our game to run at 60 frames-per-second

## --------------------------------------------------------------------------------------
##  Main game loop

while not windowShouldClose(): ##  Detect window close button or ESC key
  ##  Update
  ## ----------------------------------------------------------------------------------
  if isKeyPressed(W):
    lights[0].enabled = not lights[0].enabled
  if isKeyPressed(R):
    lights[1].enabled = not lights[1].enabled
  if isKeyPressed(G):
    lights[2].enabled = not lights[2].enabled
  if isKeyPressed(B):
    lights[3].enabled = not lights[3].enabled
  updateCamera(addr(camera))
  ##  Update camera
  ##  Make the lights do differing orbits
  angle -= 0.02
  lights[0].position.x = cos(angle) * 4.0
  lights[0].position.z = sin(angle) * 4.0
  lights[1].position.x = cos(-(angle * 0.6)) * 4.0
  lights[1].position.z = sin(-(angle * 0.6)) * 4.0
  lights[2].position.y = cos(angle * 0.2) * 4.0
  lights[2].position.z = sin(angle * 0.2) * 4.0
  lights[3].position.y = cos(-(angle * 0.35)) * 4.0
  lights[3].position.z = sin(-(angle * 0.35)) * 4.0
  updateLightValues(shader, lights[0])
  updateLightValues(shader, lights[1])
  updateLightValues(shader, lights[2])
  updateLightValues(shader, lights[3])
  ##  Rotate the torus
  modelA.transform = modelA.transform * rotateX(-0.025)
  modelA.transform = modelA.transform * rotateZ(0.012)
  ##  Update the light shader with the camera view position
  var cameraPos: array[3, cfloat] = [camera.position.x, camera.position.y,
                                camera.position.z]
  setShaderValue(shader, shader.locs[int(Vector_View)], cameraPos.addr, VEC3)
  ## ----------------------------------------------------------------------------------
  ##  Draw
  ## ----------------------------------------------------------------------------------
  beginDrawing:
    clearBackground(Raywhite)
    beginMode3D(camera):
      ##  Draw the three models
      drawModel(modelA, vector3Zero(), 1.0, White)
      drawModel(modelB, (-1.6, 0.0, 0.0), 1.0, White)
      drawModel(modelC, (1.6, 0.0, 0.0), 1.0, White)
      ##  Draw markers to show where the lights are
      if lights[0].enabled:
        drawSphereEx(lights[0].position, 0.2, 8, 8, White)
      if lights[1].enabled:
        drawSphereEx(lights[1].position, 0.2, 8, 8, Red)
      if lights[2].enabled:
        drawSphereEx(lights[2].position, 0.2, 8, 8, Green)
      if lights[3].enabled:
        drawSphereEx(lights[3].position, 0.2, 8, 8, Blue)
      drawGrid(10, 1.0)
    drawFPS(10, 10)
    drawText("Use keys RGBW to toggle lights", 10, 30, 20, Darkgray)

## ----------------------------------------------------------------------------------
##  De-Initialization
## --------------------------------------------------------------------------------------
unloadModel(modelA)
##  Unload the modelA
unloadModel(modelB)
##  Unload the modelB
unloadModel(modelC)
##  Unload the modelC
unloadTexture(texture)
##  Unload the texture
unloadShader(shader)
##  Unload shader
closeWindow()
##  Close window and OpenGL context
## --------------------------------------------------------------------------------------
