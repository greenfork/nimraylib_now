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

import lenientops
import ../../src/nimraylib_now/raylib

#  Initialization
# ---------------------------------------------------------
const screenWidth = 800
const screenHeight = 450

initWindow screenWidth, screenHeight, "raylib [shapes] example - bouncing ball"

var
    ballPosition = Vector2(x: getScreenWidth()/2, y: getScreenHeight()/2)
    ballSpeed = Vector2(x: 5.0f, y: 4.0f)
    ballRadius = 20.0

    pause = false
    framesCounter = 0

setTargetFPS(60);               #  Set our game to run at 60 frames-per-second
# ----------------------------------------------------------

#  Main game loop
while not windowShouldClose():  #  Detect window close button or ESC key
    #  Update
    # -----------------------------------------------------
    if isKeyPressed(SPACE): pause = not pause

    if not pause:
        ballPosition.x += ballSpeed.x
        ballPosition.y += ballSpeed.y

        #  Check walls collision for bouncing
        if (ballPosition.x >= (getScreenWidth() - ballRadius)) or (ballPosition.x <= ballRadius):  ballSpeed.x *= -1.0f
        if (ballPosition.y >= (getScreenHeight() - ballRadius)) or (ballPosition.y <= ballRadius): ballSpeed.y *= -1.0f
    else: framesCounter.inc
    # -----------------------------------------------------

    #  Draw
    # -----------------------------------------------------
    beginDrawing()

    clearBackground RAYWHITE

    drawCircleV ballPosition, ballRadius, MAROON
    drawText "PRESS SPACE to PAUSE BALL MOVEMENT", 10, getScreenHeight() - 25, 20, LIGHTGRAY

    #  On pause, we draw a blinking message
    if pause and ((framesCounter div 30) %% 2).bool: drawText "PAUSED", 350, 200, 30, GRAY

    drawFPS 10, 10

    endDrawing()
    # -----------------------------------------------------

#  De-Initialization
# ---------------------------------------------------------
closeWindow()         #  Close window and OpenGL context
# ---------------------------------------------------------
