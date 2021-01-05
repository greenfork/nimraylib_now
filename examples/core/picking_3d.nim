#*******************************************************************************************
#
#   raylib [core] example - Picking in 3d mode
#
#   This example has been created using raylib 1.3 (www.raylib.com)
#   raylib is licensed under an unmodified zlib/libpng license (View raylib.h for details)
#
#   Copyright (c) 2015 Ramon Santamaria (@raysan5)
#   /Converted in 2*20 by Guevara-chan.
#
#*******************************************************************************************

import ../../raylib/raylib

#  Initialization
# --------------------------------------------------------------------------------------
const screenWidth = 800
const screenHeight = 450

InitWindow(screenWidth, screenHeight, "raylib [core] example - 3d picking");

#  Define the camera to look into our 3d world
var camera = Camera()
camera.position = Vector3(x: 10.0f, y: 10.0f, z: 10.0f)    #  Camera position
camera.target = Vector3(x: 0.0f, y: 0.0f, z: 0.0f)         #  Camera looking at point
camera.up = Vector3(x: 0.0f, y: 1.0f, z: 0.0f)             #  Camera up vector (rotation towards target)
camera.fovy = 45.0f                                        #  Camera field-of-view Y
camera.`type` = CAMERA_PERSPECTIVE                          #  Camera mode type

var
    cubePosition = Vector3(x: 0.0f, y: 1.0f, z: 0.0f)
    cubeSize = Vector3(x: 2.0f, y: 2.0f, z: 2.0f)

    ray = Ray()                     #  Picking line ray

    collision = false

camera.SetCameraMode CAMERA_FREE    #  Set a free camera mode

SetTargetFPS(60);                   #  Set our game to run at 60 frames-per-second
# --------------------------------------------------------------------------------------

#  Main game loop
while not WindowShouldClose():      #  Detect window close button or ESC key
    #  Update
    # ----------------------------------------------------------------------------------
    camera.addr.UpdateCamera        #  Update camera

    if MOUSE_LEFT_BUTTON.IsMouseButtonPressed():
        if not collision:
            let ray = GetMouseRay(GetMousePosition(), camera);

            #  Check collision between ray and box
            collision = CheckCollisionRayBox(ray,
                        BoundingBox(min: Vector3(x: cubePosition.x - cubeSize.x/2, y: cubePosition.y - cubeSize.y/2,
                                        z: cubePosition.z - cubeSize.z/2),
                                    max: Vector3(x: cubePosition.x + cubeSize.x/2, y: cubePosition.y + cubeSize.y/2,
                                        z: cubePosition.z + cubeSize.z/2)))
        else: collision = false
    # ----------------------------------------------------------------------------------

    #  Draw
    # ----------------------------------------------------------------------------------
    BeginDrawing()

    ClearBackground RAYWHITE

    BeginMode3D camera

    if collision:
        DrawCube(cubePosition, cubeSize.x, cubeSize.y, cubeSize.z, RED)
        DrawCubeWires(cubePosition, cubeSize.x, cubeSize.y, cubeSize.z, MAROON)

        DrawCubeWires(cubePosition, cubeSize.x + 0.2f, cubeSize.y + 0.2f, cubeSize.z + 0.2f, GREEN)
    else:
        DrawCube(cubePosition, cubeSize.x, cubeSize.y, cubeSize.z, GRAY)
        DrawCubeWires(cubePosition, cubeSize.x, cubeSize.y, cubeSize.z, DARKGRAY)

    DrawRay(ray, MAROON)
    DrawGrid(10, 1.0f)

    EndMode3D()

    DrawText("Try selecting the box with mouse!", 240, 10, 20, DARKGRAY)

    if collision: DrawText("BOX SELECTED", (screenWidth - MeasureText("BOX SELECTED", 30)) div 2, 
        (screenHeight * 0.1f).int32, 30, GREEN)

    DrawFPS(10, 10)

    EndDrawing()
    # ----------------------------------------------------------------------------------

#  De-Initialization
# --------------------------------------------------------------------------------------
CloseWindow()         #  Close window and OpenGL context
# --------------------------------------------------------------------------------------
