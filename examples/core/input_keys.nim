#*******************************************************************************************
#
#   raylib [core] example - Keyboard input
#
#   This example has been created using raylib 1.0 (www.raylib.com)
#   raylib is licensed under an unmodified zlib/libpng license (View raylib.h for details)
#
#   Copyright (c) 2014 Ramon Santamaria (@raysan5)
#   /Converted in 2*20 by Guevara-chan.
#
#*******************************************************************************************

import ../../raylib/raylib
    # Initialization
    #--------------------------------------------------------------------------------------
const screenWidth = 800
const screenHeight = 450

initWindow screenWidth, screenHeight, "raylib [core] example - keyboard input"

var ballPosition = Vector2(x: screenWidth/2, y: screenHeight/2)

60.setTargetFPS                   # Set our game to run at 60 frames-per-second
#--------------------------------------------------------------------------------------

# Main game loop
while not windowShouldClose():    # Detect window close button or ESC key

    #  Update
    # ----------------------------------------------------------------------------------
    if KEY_RIGHT.isKeyDown: ballPosition.x += 2.0f
    if KEY_LEFT.isKeyDown:  ballPosition.x -= 2.0f
    if KEY_UP.isKeyDown:    ballPosition.y -= 2.0f
    if KEY_DOWN.isKeyDown:  ballPosition.y += 2.0f
    # ----------------------------------------------------------------------------------

    #  Draw
    # ----------------------------------------------------------------------------------
    beginDrawing()
    clearBackground RAYWHITE

    drawText "move the ball with arrow keys", 10, 10, 20, DARKGRAY

    drawCircleV ballPosition, 50, MAROON

    endDrawing()
    # ----------------------------------------------------------------------------------

# De-Initialization
# --------------------------------------------------------------------------------------
closeWindow()        #  Close window and OpenGL context
# --------------------------------------------------------------------------------------
