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

import ../../src/nimraylib_now/raylib

const MaxColumns = 20

#  Initialization
# --------------------------------------------------------------------------------------
const screenWidth = 800
const screenHeight = 450

initWindow screenWidth, screenHeight, "raylib [core] example - 3d camera first person"

#  Define the camera to look into our 3d world (position, target, up vector)
var camera = Camera()
camera.position = (x: 4.0, y: 2.0, z: 4.0)
camera.target = (x: 0.0, y: 1.8, z: 0.0)
camera.up = (x: 0.0, y: 1.0, z: 0.0)
camera.fovy = 60.0
camera.projection = Perspective

#  Generates some random columns
var
    heights: array[0..MaxColumns, float]
    positions: array[0..MaxColumns, Vector3]
    colors: array[0..MaxColumns, Color]

for i in 0..<MaxColumns:
    heights[i] = getRandomValue(1, 12).float
    positions[i] = (x: getRandomValue(-15, 15).float, y: heights[i]/2, z: getRandomValue(-15, 15).float)
    colors[i] = Color(r: getRandomValue(20, 255).uint8, g: getRandomValue(10, 55).uint8, b: 30.uint8, a: 255.uint8)

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

    drawPlane (x: 0.0, y: 0.0, z: 0.0), (x: 32.0, y: 32.0), Lightgray #  Draw ground
    drawCube (x: -16.0, y: 2.5, z: 0.0), 1.0, 5.0, 32.0, Blue               #  Draw a blue wall
    drawCube (x: 16.0, y: 2.5, z: 0.0), 1.0, 5.0, 32.0, Lime                #  Draw a green wall
    drawCube (x: 0.0, y: 2.5, z: 16.0), 32.0, 5.0, 1.0, Gold                #  Draw a yellow wall

    #  Draw some cubes around
    for i in 0..<MaxColumns:
        drawCube positions[i], 2.0, heights[i], 2.0, colors[i]
        drawCubeWires positions[i], 2.0, heights[i], 2.0, Maroon

    endMode3D()

    drawRectangle 10, 10, 220, 70, fade(Skyblue, 0.5)
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
