#*******************************************************************************************
#
#   raylib [text] example - Text formatting
#
#   This example has been created using raylib 1.1 (www.raylib.com)
#   raylib is licensed under an unmodified zlib/libpng license (View raylib.h for details)
#
#   Copyright (c) 2014 Ramon Santamaria (@raysan5)
#   /Converted in 2*20 by Guevara-chan.
#   Adapted in 2021 by greenfork
#
#*******************************************************************************************

import ../../src/nimraylib_now/raylib

#  Initialization
# --------------------------------------------------------------------------------------
const screenWidth = 800
const screenHeight = 450

initWindow screenWidth, screenHeight, "raylib [text] example - text formatting"

let
    score   = 100020
    hiscore = 200450
    lives   = 5

setTargetFPS(60)               #  Set our game to run at 60 frames-per-second
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

    drawText textFormat("Score: %08i", score), 200, 80, 20, RED

    drawText textFormat("HiScore: %08i", hiscore), 200, 120, 20, GREEN

    drawText textFormat("Lives: %02i", lives), 200, 160, 40, BLUE

    drawText textFormat("Elapsed Time: %02.02f ms", getFrameTime()*1000), 200, 220, 20, BLACK

    endDrawing()
    # ----------------------------------------------------------------------------------

#  De-Initialization
# --------------------------------------------------------------------------------------
closeWindow()        #  Close window and OpenGL context
# --------------------------------------------------------------------------------------
