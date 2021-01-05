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

import ../../src/nimraylib_now

const MaxColumns = 20

#  Initialization
# --------------------------------------------------------------------------------------
const screenWidth = 800
const screenHeight = 450

initWindow screenWidth, screenHeight, "raylib [core] example - 3d camera first person"

#  Define the camera to look into our 3d world (position, target, up vector)
var camera = Camera()
camera.position = Vector3(x: 4.0f, y: 2.0f, z: 4.0f)
camera.target = Vector3(x: 0.0f, y: 1.8f, z: 0.0f)
camera.up = Vector3(x: 0.0f, y: 1.0f, z: 0.0f)
camera.fovy = 60.0f
camera.`type` = Perspective

#  Generates some random columns
var
    heights: array[0..MaxColumns, float]
    positions: array[0..MaxColumns, Vector3]
    colors: array[0..MaxColumns, Color]

for i in 0..<MaxColumns:
    heights[i] = getRandomValue(1, 12).float
    positions[i] = Vector3(x: getRandomValue(-15, 15).float, y: heights[i]/2, z: getRandomValue(-15, 15).float)
    colors[i] = Color(r: getRandomValue(20, 255).uint8, g: getRandomValue(10, 55).uint8, b: 30, a: 255)

camera.setCameraMode FirstPerson    #  Set a first person camera mode

setTargetFPS 60                             #  Set our game to run at 60 frames-per-second
# --------------------------------------------------------------------------------------

#  Main game loop
while not windowShouldClose():              #  Detect window close button or ESC key
    #  Update
    # ----------------------------------------------------------------------------------
    camera.addr.updateCamera                #  Update camera
    # ----------------------------------------------------------------------------------

    #  Draw
    # ----------------------------------------------------------------------------------
    beginDrawing()

    clearBackground RayWhite

    beginMode3D camera

    drawPlane Vector3(x: 0.0f, y: 0.0f, z: 0.0f), Vector2(x: 32.0f, y: 32.0f), Lightgray #  Draw ground
    drawCube Vector3(x: -16.0f, y: 2.5f, z: 0.0f), 1.0f, 5.0f, 32.0f, Blue               #  Draw a blue wall
    drawCube Vector3(x: 16.0f, y: 2.5f, z: 0.0f), 1.0f, 5.0f, 32.0f, Lime                #  Draw a green wall
    drawCube Vector3(x: 0.0f, y: 2.5f, z: 16.0f), 32.0f, 5.0f, 1.0f, Gold                #  Draw a yellow wall

    #  Draw some cubes around
    for i in 0..<MaxColumns:
        drawCube positions[i], 2.0f, heights[i], 2.0f, colors[i]
        drawCubeWires positions[i], 2.0f, heights[i], 2.0f, Maroon

    endMode3D()

    drawRectangle 10, 10, 220, 70, fade(Skyblue, 0.5f)
    drawRectangleLines 10, 10, 220, 70, Blue

    drawText "First person camera default controls:", 20, 20, 10, Black
    drawText "- Move with keys: W, A, S, D", 40, 40, 10, Darkgray
    drawText "- Mouse move to look around", 40, 60, 10, Darkgray

    endDrawing()
    # ----------------------------------------------------------------------------------

#  De-Initialization
# --------------------------------------------------------------------------------------
closeWindow()         #  Close window and OpenGL context
# --------------------------------------------------------------------------------------
