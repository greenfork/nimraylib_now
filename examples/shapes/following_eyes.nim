#*******************************************************************************************
#
#   raylib [shapes] example - following eyes
#
#   This example has been created using raylib 2.5 (www.raylib.com)
#   raylib is licensed under an unmodified zlib/libpng license (View raylib.h for details)
#
#   Copyright (c) 2013-2019 Ramon Santamaria (@raysan5)
#   /Converted in 2*20 by Guevara-chan.
#
#*******************************************************************************************

import math
import ../../src/nimraylib_now/raylib

#  Initialization
# --------------------------------------------------------------------------------------
const screenWidth = 800
const screenHeight = 450

initWindow screenWidth, screenHeight, "raylib [shapes] example - following eyes"

var
  scleraLeftPosition = (x: getScreenWidth()/2 - 100, y: getScreenHeight()/2).Vector2
  scleraRightPosition = (x: getScreenWidth()/2 + 100, y: getScreenHeight()/2).Vector2
  scleraRadius = 80.0

  irisLeftPosition = (x: getScreenWidth()/2 - 100, y: getScreenHeight()/2).Vector2
  irisRightPosition = (x: getScreenWidth()/2 + 100, y: getScreenHeight()/2).Vector2
  irisRadius = 24.0

  angle = 0.0f
  dx = 0.0f
  dy = 0.0f
  dxx = 0.0f
  dyy = 0.0f

setTargetFPS 60                 #  Set our game to run at 60 frames-per-second
# --------------------------------------------------------------------------------------

#  Main game loop
while not windowShouldClose():  #  Detect window close button or ESC key
    #  Update
    # ----------------------------------------------------------------------------------
    irisLeftPosition = getMousePosition()
    irisRightPosition = getMousePosition()

    #  Check not inside the left eye sclera
    if not checkCollisionPointCircle(irisLeftPosition, scleraLeftPosition, scleraRadius - 20):
        dx = irisLeftPosition.x - scleraLeftPosition.x;
        dy = irisLeftPosition.y - scleraLeftPosition.y;

        angle = arctan2(dy, dx)

        dxx = (scleraRadius - irisRadius)*angle.cos
        dyy = (scleraRadius - irisRadius)*angle.sin

        irisLeftPosition.x = scleraLeftPosition.x + dxx
        irisLeftPosition.y = scleraLeftPosition.y + dyy

    #  Check not inside the right eye sclera
    if not checkCollisionPointCircle(irisRightPosition, scleraRightPosition, scleraRadius - 20):
        dx = irisRightPosition.x - scleraRightPosition.x
        dy = irisRightPosition.y - scleraRightPosition.y

        angle = arctan2(dy, dx)

        dxx = (scleraRadius - irisRadius)*angle.cos
        dyy = (scleraRadius - irisRadius)*angle.sin

        irisRightPosition.x = scleraRightPosition.x + dxx
        irisRightPosition.y = scleraRightPosition.y + dyy
    # ----------------------------------------------------------------------------------

    #  Draw
    # ----------------------------------------------------------------------------------
    beginDrawing()

    clearBackground RAYWHITE

    drawCircleV scleraLeftPosition, scleraRadius, LIGHTGRAY
    drawCircleV irisLeftPosition, irisRadius, BROWN
    drawCircleV irisLeftPosition, 10, BLACK

    drawCircleV scleraRightPosition, scleraRadius, LIGHTGRAY
    drawCircleV irisRightPosition, irisRadius, DARKGREEN
    drawCircleV irisRightPosition, 10, BLACK

    drawFPS 10, 10

    endDrawing()
    # ----------------------------------------------------------------------------------

#  De-Initialization
# --------------------------------------------------------------------------------------
closeWindow()         #  Close window and OpenGL context
# --------------------------------------------------------------------------------------
