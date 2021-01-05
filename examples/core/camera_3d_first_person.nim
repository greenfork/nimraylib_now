#*******************************************************************************************
#
#   raylib [core] example - 3d camera first person
#
#   This example has been created using raylib 1.3 (www.raylib.com)
#   raylib is licensed under an unmodified zlib/libpng license (View raylib.h for details)
#
#   Copyright (c) 2015 Ramon Santamaria (@raysan5)
#   /Converted in 2*20 by Guevara-chan.
#
#*******************************************************************************************

import ../../raylib/raylib

const MAX_COLUMNS = 20

#  Initialization
# --------------------------------------------------------------------------------------
const screenWidth = 800
const screenHeight = 450

InitWindow screenWidth, screenHeight, "raylib [core] example - 3d camera first person"

#  Define the camera to look into our 3d world (position, target, up vector)
var camera = Camera()
camera.position = Vector3(x: 4.0f, y: 2.0f, z: 4.0f)
camera.target = Vector3(x: 0.0f, y: 1.8f, z: 0.0f)
camera.up = Vector3(x: 0.0f, y: 1.0f, z: 0.0f)
camera.fovy = 60.0f
camera.`type` = CAMERA_PERSPECTIVE

#  Generates some random columns
var
    heights: array[0..MAX_COLUMNS, float]
    positions: array[0..MAX_COLUMNS, Vector3]
    colors: array[0..MAX_COLUMNS, Color]

for i in 0..<MAX_COLUMNS:
    heights[i] = GetRandomValue(1, 12).float
    positions[i] = Vector3(x: GetRandomValue(-15, 15).float, y: heights[i]/2, z: GetRandomValue(-15, 15).float)
    colors[i] = Color(r: GetRandomValue(20, 255).uint8, g: GetRandomValue(10, 55).uint8, b: 30, a: 255)

camera.SetCameraMode CAMERA_FIRST_PERSON    #  Set a first person camera mode

SetTargetFPS 60                             #  Set our game to run at 60 frames-per-second
# --------------------------------------------------------------------------------------

#  Main game loop
while not WindowShouldClose():              #  Detect window close button or ESC key
    #  Update
    # ----------------------------------------------------------------------------------
    camera.addr.UpdateCamera                #  Update camera
    # ----------------------------------------------------------------------------------

    #  Draw
    # ----------------------------------------------------------------------------------
    BeginDrawing()

    ClearBackground RAYWHITE

    BeginMode3D camera

    DrawPlane Vector3(x: 0.0f, y: 0.0f, z: 0.0f), Vector2(x: 32.0f, y: 32.0f), LIGHTGRAY #  Draw ground
    DrawCube Vector3(x: -16.0f, y: 2.5f, z: 0.0f), 1.0f, 5.0f, 32.0f, BLUE               #  Draw a blue wall
    DrawCube Vector3(x: 16.0f, y: 2.5f, z: 0.0f), 1.0f, 5.0f, 32.0f, LIME                #  Draw a green wall
    DrawCube Vector3(x: 0.0f, y: 2.5f, z: 16.0f), 32.0f, 5.0f, 1.0f, GOLD                #  Draw a yellow wall

    #  Draw some cubes around
    for i in 0..<MAX_COLUMNS:
        DrawCube positions[i], 2.0f, heights[i], 2.0f, colors[i]
        DrawCubeWires positions[i], 2.0f, heights[i], 2.0f, MAROON

    EndMode3D()

    DrawRectangle 10, 10, 220, 70, Fade(SKYBLUE, 0.5f)
    DrawRectangleLines 10, 10, 220, 70, BLUE

    DrawText "First person camera default controls:", 20, 20, 10, BLACK
    DrawText "- Move with keys: W, A, S, D", 40, 40, 10, DARKGRAY
    DrawText "- Mouse move to look around", 40, 60, 10, DARKGRAY

    EndDrawing()
    # ----------------------------------------------------------------------------------

#  De-Initialization
# --------------------------------------------------------------------------------------
CloseWindow()         #  Close window and OpenGL context
# --------------------------------------------------------------------------------------
