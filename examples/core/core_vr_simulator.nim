# ******************************************************************************************
#
#    raylib [core] example - VR Simulator (Oculus Rift CV1 parameters)
#
#    This example has been created using raylib 1.7 (www.raylib.com)
#    raylib is licensed under an unmodified zlib/libpng license (View raylib.h for details)
#
#    Copyright (c) 2017 Ramon Santamaria (@raysan5)
#    Converted in 2021 by greenfork
#
# ******************************************************************************************

import ../../src/nimraylib_now/raylib

# Change GLSL this version to see different effects!
const
  GLSL_VERSION* = 330
  # GLSL_VERSION* = 100

##  Initialization
## --------------------------------------------------------------------------------------
var screenWidth: int32 = 800
var screenHeight: int32 = 450
##  NOTE: screenWidth/screenHeight should match VR device aspect ratio
setConfigFlags(Msaa4xHint)
initWindow(screenWidth, screenHeight, "raylib [core] example - vr simulator")
##  Init VR simulator (Oculus Rift CV1 parameters)
initVrSimulator()
var hmd = VrDeviceInfo()

##  VR device parameters (head-mounted-device)
##  Oculus Rift CV1 parameters for simulator
hmd.hResolution = 2160 ##  HMD horizontal resolution in pixels
hmd.vResolution = 1200 ##  HMD vertical resolution in pixels
hmd.hScreenSize = 0.133793 ##  HMD horizontal size in meters
hmd.vScreenSize = 0.0669 ##  HMD vertical size in meters
hmd.vScreenCenter = 0.04678 ##  HMD screen center in meters
hmd.eyeToScreenDistance = 0.041 ##  HMD distance between eye and display in meters
hmd.lensSeparationDistance = 0.07f ##  HMD lens separation distance in meters
hmd.interpupillaryDistance = 0.07f ##  HMD IPD (distance between pupils) in meters

## NOTE: CV1 uses a Fresnel-hybrid-asymmetric lenses with specific distortion compute shaders.
## Following parameters are an approximation to distortion stereo rendering
## but results differ from actual device.
hmd.lensDistortionValues[0] = 1.0 ##  HMD lens distortion constant parameter 0
hmd.lensDistortionValues[1] = 0.22 ##  HMD lens distortion constant parameter 1
hmd.lensDistortionValues[2] = 0.24 ##  HMD lens distortion constant parameter 2
hmd.lensDistortionValues[3] = 0.0 ##  HMD lens distortion constant parameter 3
hmd.chromaAbCorrection[0] = 0.996 ##  HMD chromatic aberration correction parameter 0
hmd.chromaAbCorrection[1] = -0.004 ##  HMD chromatic aberration correction parameter 1
hmd.chromaAbCorrection[2] = 1.014 ##  HMD chromatic aberration correction parameter 2
hmd.chromaAbCorrection[3] = 0.0 ##  HMD chromatic aberration correction parameter 3

##  Distortion shader (uses device lens distortion and chroma)
var distortion: Shader = loadShader("", textFormat("resources/distortion%i.fs", GlslVersion))
setVrConfiguration(hmd, distortion)
##  Set Vr device parameters for stereo rendering
##  Define the camera to look into our 3d world
var camera = Camera()
camera.position = (5.0f, 2.0f, 5.0f)    # Camera position
camera.target = (0.0f, 2.0f, 0.0f)      # Camera looking at point
camera.up = (0.0f, 1.0f, 0.0f)          # Camera up vector (rotation towards target)
camera.fovy = 60.0
##  Camera field-of-view Y
camera.`type` = Perspective
##  Camera type
var cubePosition: Vector3 = (0.0, 0.0, 0.0)
setCameraMode(camera, FirstPerson)
##  Set first person camera mode
setTargetFPS(90)
##  Set our game to run at 90 frames-per-second
## --------------------------------------------------------------------------------------
##  Main game loop
while not windowShouldClose(): ##  Detect window close button or ESC key
  ##  Update
  ## ----------------------------------------------------------------------------------
  updateCamera(addr(camera))
  ##  Update camera (simulator mode)
  if isKeyPressed(Space):
    toggleVrMode()
  beginDrawing()
  clearBackground(Raywhite)
  beginVrDrawing()
  beginMode3D(camera)
  drawCube(cubePosition, 2.0, 2.0, 2.0, Red)
  drawCubeWires(cubePosition, 2.0, 2.0, 2.0, Maroon)
  drawGrid(40, 1.0)
  endMode3D()
  endVrDrawing()
  drawFPS(10, 10)
  endDrawing()
## ----------------------------------------------------------------------------------
##  De-Initialization
## --------------------------------------------------------------------------------------
unloadShader(distortion)
##  Unload distortion shader
closeVrSimulator()
##  Close VR simulator
closeWindow()
##  Close window and OpenGL context
## --------------------------------------------------------------------------------------
