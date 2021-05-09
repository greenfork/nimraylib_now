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
  GLSL_VERSION = 330
  # GLSL_VERSION* = 100

##  Initialization
## --------------------------------------------------------------------------------------
var screenWidth = 800
var screenHeight = 450
initWindow(screenWidth, screenHeight, "raylib [core] example - vr simulator")
##  Init VR simulator (Oculus Rift CV1 parameters)
var device = VrDeviceInfo()

##  VR device parameters (head-mounted-device)
##  Oculus Rift CV1 parameters for simulator
device.hResolution = 2160            ## horizontal resolution in pixels
device.vResolution = 1200            ## vertical resolution in pixels
device.hScreenSize = 0.133793        ## horizontal size in meters
device.vScreenSize = 0.0669          ## vertical size in meters
device.vScreenCenter = 0.04678       ## screen center in meters
device.eyeToScreenDistance = 0.041   ## distance between eye and display in meters
device.lensSeparationDistance = 0.07 ## lens separation distance in meters
device.interpupillaryDistance = 0.07 ## IPD (distance between pupils) in meters

## NOTE: CV1 uses a Fresnel-hybrid-asymmetric lenses with specific distortion compute shaders.
## Following parameters are an approximation to distortion stereo rendering
device.lensDistortionValues[0] = 1.0  ## lens distortion constant parameter 0
device.lensDistortionValues[1] = 0.22 ## lens distortion constant parameter 1
device.lensDistortionValues[2] = 0.24 ## lens distortion constant parameter 2
device.lensDistortionValues[3] = 0.0  ## lens distortion constant parameter 3
device.chromaAbCorrection[0] = 0.996  ## chromatic aberration correction parameter 0
device.chromaAbCorrection[1] = -0.004 ## chromatic aberration correction parameter 1
device.chromaAbCorrection[2] = 1.014  ## chromatic aberration correction parameter 2
device.chromaAbCorrection[3] = 0.0    ## chromatic aberration correction parameter 3

## Load VR stereo config for VR device parameteres (Oculus Rift CV1 parameters)
var config = loadVrStereoConfig(device)

##  Distortion shader (uses device lens distortion and chroma)
var distortion: Shader = loadShader("", textFormat("resources/distortion%i.fs", GlslVersion))

## Update distortion shader with lens and distortion-scale parameters
setShaderValue(distortion, getShaderLocation(distortion, "leftLensCenter"),
               cast[pointer](config.leftLensCenter.addr), ShaderUniformDataType.Vec2);
setShaderValue(distortion, getShaderLocation(distortion, "rightLensCenter"),
               cast[pointer](config.rightLensCenter.addr), ShaderUniformDataType.Vec2);
setShaderValue(distortion, getShaderLocation(distortion, "leftScreenCenter"),
               cast[pointer](config.leftScreenCenter.addr), ShaderUniformDataType.Vec2);
setShaderValue(distortion, getShaderLocation(distortion, "rightScreenCenter"),
               cast[pointer](config.rightScreenCenter.addr), ShaderUniformDataType.Vec2);

setShaderValue(distortion, getShaderLocation(distortion, "scale"),
               cast[pointer](config.scale.addr), ShaderUniformDataType.Vec2);
setShaderValue(distortion, getShaderLocation(distortion, "scaleIn"),
               cast[pointer](config.scaleIn.addr), ShaderUniformDataType.Vec2);
setShaderValue(distortion, getShaderLocation(distortion, "deviceWarpParam"),
               cast[pointer](device.lensDistortionValues.addr), ShaderUniformDataType.Vec4);
setShaderValue(distortion, getShaderLocation(distortion, "chromaAbParam"),
               cast[pointer](device.chromaAbCorrection.addr), ShaderUniformDataType.Vec4);

var target = loadRenderTexture(getScreenWidth(), getScreenHeight())

##  Define the camera to look into our 3d world
var camera = Camera()
camera.position = (5.0, 2.0, 5.0)    # Camera position
camera.target = (0.0, 2.0, 0.0)      # Camera looking at point
camera.up = (0.0, 1.0, 0.0)          # Camera up vector
camera.fovy = 60.0
##  Camera field-of-view Y
camera.projection = Perspective
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
  beginDrawing:
    clearBackground(Raywhite)
    beginTextureMode(target):
      clearBackground(Raywhite)
      beginVrStereoMode(config):
        beginMode3D(camera):
          drawCube(cubePosition, 2.0, 2.0, 2.0, Red)
          drawCubeWires(cubePosition, 2.0, 2.0, 2.0, Maroon)
          drawGrid(40, 1.0)
    beginShaderMode(distortion):
      drawTextureRec(
        target.texture,
        Rectangle(width: target.texture.width.cfloat, height: -target.texture.height.cfloat),
        Vector2(),
        White
      )
    drawFPS(10, 10)

## ----------------------------------------------------------------------------------
##  De-Initialization
## --------------------------------------------------------------------------------------
unloadVrStereoConfig(config)
unloadRenderTexture(target)
unloadShader(distortion)
##  Unload distortion shader
##  Close VR simulator
closeWindow()
##  Close window and OpenGL context
## --------------------------------------------------------------------------------------
