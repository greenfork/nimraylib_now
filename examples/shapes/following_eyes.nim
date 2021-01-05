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

import raylib, math

#  Initialization
# --------------------------------------------------------------------------------------
const screenWidth = 800
const screenHeight = 450

InitWindow screenWidth, screenHeight, "raylib [shapes] example - following eyes"

var
    scleraLeftPosition = Vector2(x: GetScreenWidth()/2 - 100, y: GetScreenHeight()/2)
    scleraRightPosition = Vector2(x: GetScreenWidth()/2 + 100, y: GetScreenHeight()/2)
    scleraRadius = 80.0

    irisLeftPosition = Vector2(x: GetScreenWidth()/2 - 100, y: GetScreenHeight()/2)
    irisRightPosition = Vector2(x: GetScreenWidth()/2 + 100, y: GetScreenHeight()/2)
    irisRadius = 24.0

    angle = 0.0f
    dx = 0.0f
    dy = 0.0f
    dxx = 0.0f
    dyy = 0.0f

SetTargetFPS 60                 #  Set our game to run at 60 frames-per-second
# --------------------------------------------------------------------------------------

#  Main game loop
while not WindowShouldClose():  #  Detect window close button or ESC key
    #  Update
    # ----------------------------------------------------------------------------------
    irisLeftPosition = GetMousePosition() 
    irisRightPosition = GetMousePosition() 

    #  Check not inside the left eye sclera
    if not CheckCollisionPointCircle(irisLeftPosition, scleraLeftPosition, scleraRadius - 20):
        dx = irisLeftPosition.x - scleraLeftPosition.x;
        dy = irisLeftPosition.y - scleraLeftPosition.y;

        angle = arctan2(dy, dx)

        dxx = (scleraRadius - irisRadius)*angle.cos
        dyy = (scleraRadius - irisRadius)*angle.sin

        irisLeftPosition.x = scleraLeftPosition.x + dxx
        irisLeftPosition.y = scleraLeftPosition.y + dyy

    #  Check not inside the right eye sclera
    if not CheckCollisionPointCircle(irisRightPosition, scleraRightPosition, scleraRadius - 20):
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
    BeginDrawing() 

    ClearBackground RAYWHITE

    DrawCircleV scleraLeftPosition, scleraRadius, LIGHTGRAY
    DrawCircleV irisLeftPosition, irisRadius, BROWN
    DrawCircleV irisLeftPosition, 10, BLACK

    DrawCircleV scleraRightPosition, scleraRadius, LIGHTGRAY
    DrawCircleV irisRightPosition, irisRadius, DARKGREEN
    DrawCircleV irisRightPosition, 10, BLACK

    DrawFPS 10, 10

    EndDrawing() 
    # ----------------------------------------------------------------------------------

#  De-Initialization
# --------------------------------------------------------------------------------------
CloseWindow()         #  Close window and OpenGL context
# --------------------------------------------------------------------------------------