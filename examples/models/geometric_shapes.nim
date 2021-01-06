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

import ../../src/nimraylib_now/raylib


#  Initialization
# --------------------------------------------------------------------------------------
const screenWidth = 800
const screenHeight = 450

initWindow screenWidth, screenHeight, "raylib [models] example - geometric shapes"

#  Define the camera to look into our 3d world
var camera = Camera()
camera.position = Vector3(x: 0.0f, y: 10.0f, z: 10.0f)
camera.target   = Vector3(x: 0.0f, y: 0.0f, z: 0.0f)
camera.up       = Vector3(x: 0.0f, y: 1.0f, z: 0.0f)
camera.fovy     = 45.0f
camera.`type`   = PERSPECTIVE

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

    drawCube Vector3(x: -4.0f, y: 0.0f, z: 2.0f), 2.0f, 5.0f, 2.0f, RED
    drawCubeWires Vector3(x: -4.0f, y: 0.0f, z: 2.0f), 2.0f, 5.0f, 2.0f, GOLD
    drawCubeWires Vector3(x: -4.0f, y: 0.0f, z: -2.0f), 3.0f, 6.0f, 2.0f, MAROON

    drawSphere Vector3(x: -1.0f, y: 0.0f, z: -2.0f), 1.0f, GREEN
    drawSphereWires Vector3(x: 1.0f, y: 0.0f, z: 2.0f), 2.0f, 16, 16, LIME

    drawCylinder Vector3(x: 4.0f, y: 0.0f, z: -2.0f), 1.0f, 2.0f, 3.0f, 4, SKYBLUE
    drawCylinderWires Vector3(x: 4.0f, y: 0.0f, z: -2.0f), 1.0f, 2.0f, 3.0f, 4, DARKBLUE
    drawCylinderWires Vector3(x: 4.5f, y: -1.0f, z: 2.0f), 1.0f, 1.0f, 2.0f, 6, BROWN

    drawCylinder Vector3(x: 1.0f, y: 0.0f, z: -4.0f), 0.0f, 1.5f, 3.0f, 8, GOLD
    drawCylinderWires Vector3(x: 1.0f, y: 0.0f, z: -4.0f), 0.0f, 1.5f, 3.0f, 8, PINK

    drawGrid 10, 1.0f         #  Draw a grid

    endMode3D()

    drawFPS 10, 10

    endDrawing()
    # ----------------------------------------------------------------------------------

#  De-Initialization
# --------------------------------------------------------------------------------------
closeWindow()        #  Close window and OpenGL context
# --------------------------------------------------------------------------------------
