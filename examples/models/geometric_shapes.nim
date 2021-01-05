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

import raylib


#  Initialization
# --------------------------------------------------------------------------------------
const screenWidth = 800
const screenHeight = 450

InitWindow screenWidth, screenHeight, "raylib [models] example - geometric shapes"

#  Define the camera to look into our 3d world
var camera = Camera()
camera.position = Vector3(x: 0.0f, y: 10.0f, z: 10.0f)
camera.target   = Vector3(x: 0.0f, y: 0.0f, z: 0.0f)
camera.up       = Vector3(x: 0.0f, y: 1.0f, z: 0.0f)
camera.fovy     = 45.0f
camera.typex    = CAMERA_PERSPECTIVE

60.SetTargetFPS                #  Set our game to run at 60 frames-per-second
# --------------------------------------------------------------------------------------

#  Main game loop
while not WindowShouldClose(): #  Detect window close button or ESC key
    #  Update
    # ----------------------------------------------------------------------------------
    #  TODO: Update your variables here
    # ----------------------------------------------------------------------------------

    #  Draw
    # ----------------------------------------------------------------------------------
    BeginDrawing()

    ClearBackground RAYWHITE

    BeginMode3D camera 

    DrawCube Vector3(x: -4.0f, y: 0.0f, z: 2.0f), 2.0f, 5.0f, 2.0f, RED
    DrawCubeWires Vector3(x: -4.0f, y: 0.0f, z: 2.0f), 2.0f, 5.0f, 2.0f, GOLD
    DrawCubeWires Vector3(x: -4.0f, y: 0.0f, z: -2.0f), 3.0f, 6.0f, 2.0f, MAROON

    DrawSphere Vector3(x: -1.0f, y: 0.0f, z: -2.0f), 1.0f, GREEN
    DrawSphereWires Vector3(x: 1.0f, y: 0.0f, z: 2.0f), 2.0f, 16, 16, LIME

    DrawCylinder Vector3(x: 4.0f, y: 0.0f, z: -2.0f), 1.0f, 2.0f, 3.0f, 4, SKYBLUE
    DrawCylinderWires Vector3(x: 4.0f, y: 0.0f, z: -2.0f), 1.0f, 2.0f, 3.0f, 4, DARKBLUE
    DrawCylinderWires Vector3(x: 4.5f, y: -1.0f, z: 2.0f), 1.0f, 1.0f, 2.0f, 6, BROWN

    DrawCylinder Vector3(x: 1.0f, y: 0.0f, z: -4.0f), 0.0f, 1.5f, 3.0f, 8, GOLD
    DrawCylinderWires Vector3(x: 1.0f, y: 0.0f, z: -4.0f), 0.0f, 1.5f, 3.0f, 8, PINK

    DrawGrid 10, 1.0f         #  Draw a grid

    EndMode3D()

    DrawFPS 10, 10

    EndDrawing()
    # ----------------------------------------------------------------------------------

#  De-Initialization
# --------------------------------------------------------------------------------------
CloseWindow()        #  Close window and OpenGL context
# --------------------------------------------------------------------------------------