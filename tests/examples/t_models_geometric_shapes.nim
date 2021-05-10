discard """
  action: "compile"
  joinable: false
  matrix: "; -d:release; --gc:orc -d:release"
"""

#*******************************************************************************************
#
#   raylib [models] example - Draw some basic geometric shapes (cube, sphere, cylinder...)
#
#   This example has been created using raylib 1.0 (www.raylib.com)
#   raylib is licensed under an unmodified zlib/libpng license (View raylib.h for details)
#
#   Copyright (c) 2014 Ramon Santamaria (@raysan5)
#   /Converted in 2*20 by Guevara-chan.
#
#*******************************************************************************************

import ../../src/nimraylib_now


#  Initialization
# --------------------------------------------------------------------------------------
const screenWidth = 800
const screenHeight = 450

initWindow screenWidth, screenHeight, "raylib [models] example - geometric shapes"

#  Define the camera to look into our 3d world
var camera = Camera()
camera.position = (x: 0.0, y: 10.0, z: 10.0)
camera.target   = (x: 0.0, y: 0.0, z: 0.0)
camera.up       = (x: 0.0, y: 1.0, z: 0.0)
camera.fovy     = 45.0
camera.projection   = PERSPECTIVE

60.setTargetFPS                #  Set our game to run at 60 frames-per-second
# --------------------------------------------------------------------------------------

#  Main game loop
while not windowShouldClose(): #  Detect window close button or ESC key
    #  Update
    # ----------------------------------------------------------------------------------
    #  TODO: Update your variables here
    # ----------------------------------------------------------------------------------

    #  Draw
    # ----------------------------------------------------------------------------------
    beginDrawing()

    clearBackground RAYWHITE

    beginMode3D camera

    drawCube (x: -4.0, y: 0.0, z: 2.0), 2.0, 5.0, 2.0, RED
    drawCubeWires (x: -4.0, y: 0.0, z: 2.0), 2.0, 5.0, 2.0, GOLD
    drawCubeWires (x: -4.0, y: 0.0, z: -2.0), 3.0, 6.0, 2.0, MAROON

    drawSphere (x: -1.0, y: 0.0, z: -2.0), 1.0, GREEN
    drawSphereWires (x: 1.0, y: 0.0, z: 2.0), 2.0, 16, 16, LIME

    drawCylinder (x: 4.0, y: 0.0, z: -2.0), 1.0, 2.0, 3.0, 4, SKYBLUE
    drawCylinderWires (x: 4.0, y: 0.0, z: -2.0), 1.0, 2.0, 3.0, 4, DARKBLUE
    drawCylinderWires (x: 4.5, y: -1.0, z: 2.0), 1.0, 1.0, 2.0, 6, BROWN

    drawCylinder (x: 1.0, y: 0.0, z: -4.0), 0.0, 1.5, 3.0, 8, GOLD
    drawCylinderWires (x: 1.0, y: 0.0, z: -4.0), 0.0, 1.5, 3.0, 8, PINK

    drawGrid 10, 1.0         #  Draw a grid

    endMode3D()

    drawFPS 10, 10

    endDrawing()
    # ----------------------------------------------------------------------------------

#  De-Initialization
# --------------------------------------------------------------------------------------
closeWindow()        #  Close window and OpenGL context
# --------------------------------------------------------------------------------------
