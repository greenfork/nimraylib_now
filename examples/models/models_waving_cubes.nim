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
#   Adapted in 2021 by greenfork
#
#*******************************************************************************************

import math, lenientops
import nimraylib_now

#  Initialization
# --------------------------------------------------------------------------------------
const screenWidth = 800
const screenHeight = 450

initWindow screenWidth, screenHeight, "raylib [models] example - waving cubes"

#  Initialize the camera
var camera      = Camera3D()
camera.position = (x: 30.0, y: 20.0, z: 30.0)
camera.target   = (x: 0.0, y: 0.0, z: 0.0)
camera.up       = (x: 0.0, y: 1.0, z: 0.0)
camera.fovy     = 70.0
camera.projection   = PERSPECTIVE

#  Specify the amount of blocks in each direction
const numBlocks = 15

60.setTargetFPS
# --------------------------------------------------------------------------------------

#  Main game loop
while not windowShouldClose():    #  Detect window close button or ESC key

    #  Update
    # ----------------------------------------------------------------------------------
    let
        time = nimraylib_now.getTime()

        #  Calculate time scale for cube position and size
        scale = (2.0 + sin(time))*0.7

        #  Move camera around the scene
        cameraTime = time*0.3
    camera.position.x = cos(cameraTime)*40.0
    camera.position.z = sin(cameraTime)*40.0
    # ----------------------------------------------------------------------------------

    #  Draw
    # ----------------------------------------------------------------------------------
    beginDrawing:

      clearBackground(Raywhite)

      beginMode3D(camera):

        drawGrid 10, 5.0

        for x in 0..<numBlocks:
          for y in 0..<numBlocks:
            for z in 0..<numBlocks:
                #  Scale of the blocks depends on x/y/z positions
                let
                  blockScale = (x + y + z)/30.0

                  #  Scatter makes the waving effect by adding blockScale over time
                  scatter = sin(blockScale*20.0 + (time*4.0))

                  #  Calculate the cube position
                  cubePos = (
                      x: (x - numBlocks/2)*(scale*3.0) + scatter,
                      y: (y - numBlocks/2)*(scale*2.0) + scatter,
                      z: (z - numBlocks/2)*(scale*3.0) + scatter)

                  #  Pick a color with a hue depending on cube position for the rainbow color effect
                  cubeColor = colorFromHSV((((x + y + z)*18)%%360)/1.0, 0.75f, 0.9)

                  #  Calculate cube size
                  cubeSize = (2.4 - scale)*blockScale

                #  And finally, draw the cube!
                drawCube cubePos, cubeSize, cubeSize, cubeSize, cubeColor

      drawFPS 10, 10
# ----------------------------------------------------------------------------------

#  De-Initialization
# --------------------------------------------------------------------------------------
closeWindow()        #  Close window and OpenGL context
# --------------------------------------------------------------------------------------
