#*******************************************************************************************
#
#   raylib [models] example - Waving cubes
#
#   This example has been created using raylib 2.5 (www.raylib.com)
#   raylib is licensed under an unmodified zlib/libpng license (View raylib.h for details)
#
#   Example contributed by Codecat (@codecat) and reviewed by Ramon Santamaria (@raysan5)
#
#   Copyright (c) 2019 Codecat (@codecat) and Ramon Santamaria (@raysan5)
#   /Converted in 2*20 by Guevara-chan.
#
#*******************************************************************************************

import math, lenientops
import ../../src/nimraylib_now/raylib

#  Initialization
# --------------------------------------------------------------------------------------
const screenWidth = 800
const screenHeight = 450

initWindow screenWidth, screenHeight, "raylib [models] example - waving cubes"

#  Initialize the camera
var camera      = Camera3D()
camera.position = (x: 30.0f, y: 20.0f, z: 30.0f)
camera.target   = (x: 0.0f, y: 0.0f, z: 0.0f)
camera.up       = (x: 0.0f, y: 1.0f, z: 0.0f)
camera.fovy     = 70.0f
camera.`type`   = PERSPECTIVE

#  Specify the amount of blocks in each direction
const numBlocks = 15

60.setTargetFPS
# --------------------------------------------------------------------------------------

#  Main game loop
while not windowShouldClose():    #  Detect window close button or ESC key

    #  Update
    # ----------------------------------------------------------------------------------
    let
        time = getTime()

        #  Calculate time scale for cube position and size
        scale = (2.0f + sin(time))*0.7f

        #  Move camera around the scene
        cameraTime = time*0.3
    camera.position.x = cos(cameraTime)*40.0f
    camera.position.z = sin(cameraTime)*40.0f
    # ----------------------------------------------------------------------------------

    #  Draw
    # ----------------------------------------------------------------------------------
    beginDrawing()

    RAYWHITE.clearBackground

    beginMode3D camera

    drawGrid 10, 5.0f

    for x in 0..<numBlocks:
        for y in 0..<numBlocks:
            for z in 0..<numBlocks:
                #  Scale of the blocks depends on x/y/z positions
                let
                    blockScale = (x + y + z)/30.0f

                    #  Scatter makes the waving effect by adding blockScale over time
                    scatter = sin(blockScale*20.0f + (time*4.0f))

                    #  Calculate the cube position
                    cubePos = (
                        x: (x - numBlocks/2)*(scale*3.0f) + scatter,
                        y: (y - numBlocks/2)*(scale*2.0f) + scatter,
                        z: (z - numBlocks/2)*(scale*3.0f) + scatter)

                    #  Pick a color with a hue depending on cube position for the rainbow color effect
                    cubeColor = colorFromHSV((((x + y + z)*18)%%360)/1.0, 0.75f, 0.9f)

                    #  Calculate cube size
                    cubeSize = (2.4f - scale)*blockScale;

                #  And finally, draw the cube!
                drawCube cubePos, cubeSize, cubeSize, cubeSize, cubeColor

    endMode3D()

    drawFPS 10, 10

    endDrawing()
# ----------------------------------------------------------------------------------

#  De-Initialization
# --------------------------------------------------------------------------------------
closeWindow()        #  Close window and OpenGL context
# --------------------------------------------------------------------------------------
