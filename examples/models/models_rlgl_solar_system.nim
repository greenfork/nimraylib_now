#******************************************************************************************
#
#   raylib [models] example - gl module usage with push/pop matrix transformations
#
#   This example uses [gl] module funtionality (pseudo-OpenGL 1.1 style coding)
#
#   This example has been created using raylib 2.5 (www.raylib.com)
#   raylib is licensed under an unmodified zlib/libpng license (View raylib.h for details)
#
#   Copyright (c) 2018 Ramon Santamaria (@raysan5)
#   /Converted in 2*20 by Guevara-chan.
#   Adapted in 2021 by greenfork
#
#*******************************************************************************************

import math, lenientops
import ../../src/nimraylib_now/raylib
from ../../src/nimraylib_now/rlgl as rl import nil

# ------------------------------------------------------------------------------------
#  Module Functions Declaration
# ------------------------------------------------------------------------------------
proc drawSphereBasic(color: Color) #  Draw sphere without any matrix transformation

# ------------------------------------------------------------------------------------
#  Program main entry point
# ------------------------------------------------------------------------------------

#  Initialization
# --------------------------------------------------------------------------------------
const
  screenWidth      = 800
  screenHeight     = 450

  sunRadius        = 4.0
  earthRadius      = 0.6
  earthOrbitRadius = 8.0
  moonRadius       = 0.16
  moonOrbitRadius  = 1.5

initWindow screenWidth, screenHeight, "raylib [models] example - gl module usage with push/pop matrix transformations"

#  Define the camera to look into our 3d world
var camera      = Camera()
camera.position = (x: 16.0, y: 16.0, z: 16.0)
camera.target   = (x: 0.0, y: 0.0, z: 0.0)
camera.up       = (x: 0.0, y: 1.0, z: 0.0)
camera.fovy     = 45.0
camera.projection    = Perspective

camera.setCameraMode Free

var
  rotationSpeed = 0.2          #  General system rotation speed

  earthRotation      = 0.0     #  Rotation of earth around itself (days) in degrees
  earthOrbitRotation = 0.0     #  Rotation of earth around the Sun (years) in degrees
  moonRotation       = 0.0     #  Rotation of moon around itself
  moonOrbitRotation  = 0.0     #  Rotation of moon around earth in degrees

60.setTargetFPS                   #  Set our game to run at 60 frames-per-second
# --------------------------------------------------------------------------------------

#  Main game loop
while not windowShouldClose():    #  Detect window close button or ESC key
  #  Update
  # ----------------------------------------------------------------------------------
  camera.addr.updateCamera

  earthRotation += (5.0*rotationSpeed)
  earthOrbitRotation += (365/360.0*(5.0*rotationSpeed)*rotationSpeed)
  moonRotation += (2.0*rotationSpeed)
  moonOrbitRotation += (8.0*rotationSpeed)
  # ----------------------------------------------------------------------------------

  #  Draw
  # ----------------------------------------------------------------------------------
  beginDrawing:

    clearBackground Raywhite

    beginMode3D(camera):

      rl.pushMatrix()
      rl.scalef sunRadius, sunRadius, sunRadius           #  Scale Sun
      Gold.drawSphereBasic                                #  Draw the Sun
      rl.popMatrix()

      rl.pushMatrix()
      rl.rotatef earthOrbitRotation, 0.0, 1.0, 0.0        #  Rotation for Earth orbit around Sun
      rl.translatef earthOrbitRadius, 0.0, 0.0            #  Translation for Earth orbit
      rl.rotatef -earthOrbitRotation, 0.0, 1.0, 0.0       #  Rotation for Earth orbit around Sun inverted

      rl.pushMatrix()
      rl.rotatef earthRotation, 0.25, 1.0, 0.0            #  Rotation for Earth itself
      rl.scalef earthRadius, earthRadius, earthRadius     #  Scale Earth
      Blue.drawSphereBasic                                #  Draw the Earth
      rl.popMatrix()

      rl.rotatef moonOrbitRotation, 0.0, 1.0, 0.0         #  Rotation for Moon orbit around Earth
      rl.translatef moonOrbitRadius, 0.0, 0.0             #  Translation for Moon orbit
      rl.rotatef -moonOrbitRotation, 0.0, 1.0, 0.0        #  Rotation for Moon orbit around Earth inverted
      rl.rotatef moonRotation, 0.0, 1.0, 0.0              #  Rotation for Moon itself
      rl.scalef moonRadius, moonRadius, moonRadius        #  Scale Moon

      Lightgray.drawSphereBasic                           #  Draw the Moon
      rl.popMatrix()

      #  Some reference elements (not affected by previous matrix transformations)
      drawCircle3D (x: 0.0, y: 0.0, z: 0.0), earthOrbitRadius, (x: 1.0, y: 0.0, z: 0.0), 90.0, fade(RED, 0.5)
      drawGrid 20, 1.0

    drawText "EARTH ORBITING AROUND THE SUN!", 400, 10, 20, MAROON
    drawFPS 10, 10
# ----------------------------------------------------------------------------------

#  De-Initialization
# --------------------------------------------------------------------------------------
closeWindow()        #  Close window and OpenGL context
# --------------------------------------------------------------------------------------

# --------------------------------------------------------------------------------------------
#  Module Functions Definitions (local)
# --------------------------------------------------------------------------------------------

#  Draw sphere without any matrix transformation
#  NOTE: Sphere is drawn in world position ( 0, 0, 0 ) with radius 1.0
proc drawSphereBasic(color: Color) =
    const
        rings = 16
        slices = 16

    rl.begin(rl.Triangles):
      rl.color4ub color.r, color.g, color.b, color.a

      for i in 0..<rings+2:
        for j in 0..<slices:
          rl.vertex3f(cos(degToRad(270+(180/(rings + 1))*i))*sin(degToRad(j*360/slices)),
                     sin(degToRad(270+(180/(rings + 1))*i)),
                     cos(degToRad(270+(180/(rings + 1))*i))*cos(degToRad(j*360/slices)))
          rl.vertex3f(cos(degToRad(270+(180/(rings + 1))*(i+1)))*sin(degToRad((j+1)*360/slices)),
                     sin(degToRad(270+(180/(rings + 1))*(i+1))),
                     cos(degToRad(270+(180/(rings + 1))*(i+1)))*cos(degToRad((j+1)*360/slices)))
          rl.vertex3f(cos(degToRad(270+(180/(rings + 1))*(i+1)))*sin(degToRad(j*360/slices)),
                     sin(degToRad(270+(180/(rings + 1))*(i+1))),
                     cos(degToRad(270+(180/(rings + 1))*(i+1)))*cos(degToRad(j*360/slices)))

          rl.vertex3f(cos(degToRad(270+(180/(rings + 1))*i))*sin(degToRad(j*360/slices)),
                     sin(degToRad(270+(180/(rings + 1))*i)),
                     cos(degToRad(270+(180/(rings + 1))*i))*cos(degToRad(j*360/slices)))
          rl.vertex3f(cos(degToRad(270+(180/(rings + 1))*(i)))*sin(degToRad((j+1)*360/slices)),
                     sin(degToRad(270+(180/(rings + 1))*(i))),
                     cos(degToRad(270+(180/(rings + 1))*(i)))*cos(degToRad((j+1)*360/slices)))
          rl.vertex3f(cos(degToRad(270+(180/(rings + 1))*(i+1)))*sin(degToRad((j+1)*360/slices)),
                     sin(degToRad(270+(180/(rings + 1))*(i+1))),
                     cos(degToRad(270+(180/(rings + 1))*(i+1)))*cos(degToRad((j+1)*360/slices)))
