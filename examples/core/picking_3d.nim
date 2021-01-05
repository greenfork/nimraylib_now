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

initWindow(screenWidth, screenHeight, "raylib [core] example - 3d picking");

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

camera.setCameraMode CAMERA_FREE    #  Set a free camera mode

setTargetFPS(60);                   #  Set our game to run at 60 frames-per-second
# --------------------------------------------------------------------------------------

#  Main game loop
while not windowShouldClose():      #  Detect window close button or ESC key
    #  Update
    # ----------------------------------------------------------------------------------
    camera.addr.updateCamera        #  Update camera

    if MOUSE_LEFT_BUTTON.isMouseButtonPressed():
        if not collision:
            let ray = getMouseRay(getMousePosition(), camera);

            #  Check collision between ray and box
            collision = checkCollisionRayBox(ray,
                        BoundingBox(min: Vector3(x: cubePosition.x - cubeSize.x/2, y: cubePosition.y - cubeSize.y/2,
                                        z: cubePosition.z - cubeSize.z/2),
                                    max: Vector3(x: cubePosition.x + cubeSize.x/2, y: cubePosition.y + cubeSize.y/2,
                                        z: cubePosition.z + cubeSize.z/2)))
        else: collision = false
    # ----------------------------------------------------------------------------------

    #  Draw
    # ----------------------------------------------------------------------------------
    beginDrawing()

    clearBackground RAYWHITE

    beginMode3D camera

    if collision:
        drawCube(cubePosition, cubeSize.x, cubeSize.y, cubeSize.z, RED)
        drawCubeWires(cubePosition, cubeSize.x, cubeSize.y, cubeSize.z, MAROON)

        drawCubeWires(cubePosition, cubeSize.x + 0.2f, cubeSize.y + 0.2f, cubeSize.z + 0.2f, GREEN)
    else:
        drawCube(cubePosition, cubeSize.x, cubeSize.y, cubeSize.z, GRAY)
        drawCubeWires(cubePosition, cubeSize.x, cubeSize.y, cubeSize.z, DARKGRAY)

    drawRay(ray, MAROON)
    drawGrid(10, 1.0f)

    endMode3D()

    drawText("Try selecting the box with mouse!", 240, 10, 20, DARKGRAY)

    if collision:
      drawText("BOX SELECTED", (screenWidth - measureText("BOX SELECTED", 30)) div 2,
        (screenHeight * 0.1f).int32, 30, GREEN)

    drawFPS(10, 10)

    endDrawing()
    # ----------------------------------------------------------------------------------

#  De-Initialization
# --------------------------------------------------------------------------------------
closeWindow()         #  Close window and OpenGL context
# --------------------------------------------------------------------------------------
