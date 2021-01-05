#*******************************************************************************************
#
#   raylib [shapes] example - bouncing ball
#
#   This example has been created using raylib 1.0 (www.raylib.com)
#   raylib is licensed under an unmodified zlib/libpng license (View raylib.h for details)
#
#   Copyright (c) 2013 Ramon Santamaria (@raysan5)
#   /Converted in 2*20 by Guevara-chan.
#
#*******************************************************************************************

import raylib, lenientops

#  Initialization
# ---------------------------------------------------------
const screenWidth = 800
const screenHeight = 450

InitWindow screenWidth, screenHeight, "raylib [shapes] example - bouncing ball"

var
    ballPosition = Vector2(x: GetScreenWidth()/2, y: GetScreenHeight()/2)
    ballSpeed = Vector2(x: 5.0f, y: 4.0f)
    ballRadius = 20.0

    pause = false
    framesCounter = 0

SetTargetFPS(60);               #  Set our game to run at 60 frames-per-second
# ----------------------------------------------------------

#  Main game loop
while not WindowShouldClose():  #  Detect window close button or ESC key
    #  Update
    # -----------------------------------------------------
    if KEY_SPACE.IsKeyPressed: pause = not pause

    if not pause:
        ballPosition.x += ballSpeed.x
        ballPosition.y += ballSpeed.y

        #  Check walls collision for bouncing
        if (ballPosition.x >= (GetScreenWidth() - ballRadius)) or (ballPosition.x <= ballRadius):  ballSpeed.x *= -1.0f
        if (ballPosition.y >= (GetScreenHeight() - ballRadius)) or (ballPosition.y <= ballRadius): ballSpeed.y *= -1.0f
    else: framesCounter.inc
    # -----------------------------------------------------

    #  Draw
    # -----------------------------------------------------
    BeginDrawing()

    ClearBackground RAYWHITE

    DrawCircleV ballPosition, ballRadius, MAROON
    DrawText "PRESS SPACE to PAUSE BALL MOVEMENT", 10, GetScreenHeight() - 25, 20, LIGHTGRAY

    #  On pause, we draw a blinking message
    if pause and ((framesCounter div 30) %% 2).bool: DrawText "PAUSED", 350, 200, 30, GRAY

    DrawFPS 10, 10

    EndDrawing()
    # -----------------------------------------------------

#  De-Initialization
# ---------------------------------------------------------
CloseWindow()         #  Close window and OpenGL context
# ---------------------------------------------------------