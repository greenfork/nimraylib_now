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

InitWindow screenWidth, screenHeight, "raylib [core] example - keyboard input"

var ballPosition = Vector2(x: screenWidth/2, y: screenHeight/2)

60.SetTargetFPS                   # Set our game to run at 60 frames-per-second
#--------------------------------------------------------------------------------------

# Main game loop
while not WindowShouldClose():    # Detect window close button or ESC key

    #  Update
    # ----------------------------------------------------------------------------------
    if KEY_RIGHT.IsKeyDown: ballPosition.x += 2.0f
    if KEY_LEFT.IsKeyDown:  ballPosition.x -= 2.0f
    if KEY_UP.IsKeyDown:    ballPosition.y -= 2.0f
    if KEY_DOWN.IsKeyDown:  ballPosition.y += 2.0f
    # ----------------------------------------------------------------------------------

    #  Draw
    # ----------------------------------------------------------------------------------
    BeginDrawing()
    ClearBackground RAYWHITE

    DrawText "move the ball with arrow keys", 10, 10, 20, DARKGRAY

    DrawCircleV ballPosition, 50, MAROON

    EndDrawing()
    # ----------------------------------------------------------------------------------

# De-Initialization
# --------------------------------------------------------------------------------------
CloseWindow()        #  Close window and OpenGL context
# --------------------------------------------------------------------------------------
