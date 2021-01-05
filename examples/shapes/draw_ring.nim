#*******************************************************************************************
#
#   raylib [shapes] example - draw ring (with gui options)
#
#   This example has been created using raylib 2.5 (www.raylib.com)
#   raylib is licensed under an unmodified zlib/libpng license (View raylib.h for details)
#
#   Example contributed by Vlad Adrian (@demizdor) and reviewed by Ramon Santamaria (@raysan5)
#
#   Copyright (c) 2018 Vlad Adrian (@demizdor) and Ramon Santamaria (@raysan5)
#   /Converted in 2*20 by Guevara-chan.
#
#*******************************************************************************************

import raylib, raygui

#  Initialization
# --------------------------------------------------------------------------------------
const screenWidth = 800
const screenHeight = 450

InitWindow screenWidth, screenHeight, "raylib [shapes] example - draw ring"

var 
    center = Vector2(x: (GetScreenWidth() - 300) / 2, y: GetScreenHeight() / 2)

    innerRadius = 80.0f
    outerRadius = 190.0f

    startAngle = 0.0
    endAngle = 360.0
    segments = 0

    drawRing = true
    drawRingLines = false
    drawCircleLines = false

60.SetTargetFPS                 #  Set our game to run at 60 frames-per-second
# --------------------------------------------------------------------------------------

#  Main game loop
while not WindowShouldClose():  #  Detect window close button or ESC key
    #  Update
    # ----------------------------------------------------------------------------------
    #  NOTE: All variables update happens inside GUI control functions
    # ----------------------------------------------------------------------------------

    #  Draw
    # ----------------------------------------------------------------------------------
    BeginDrawing()

    ClearBackground RAYWHITE

    DrawLine 500, 0, 500, GetScreenHeight(), Fade(LIGHTGRAY, 0.6f)
    DrawRectangle 500, 0, GetScreenWidth() - 500, GetScreenHeight(), Fade(LIGHTGRAY, 0.3f)

    if drawRing: DrawRing center,innerRadius,outerRadius,startAngle.int,endAngle.int,segments,Fade(MAROON, 0.3)
    if drawRingLines: DrawRingLines center,innerRadius,outerRadius,startAngle.int,endAngle.int,segments,Fade(BLACK, 0.4)
    if drawCircleLines: DrawCircleSectorLines center,outerRadius,startAngle.int,endAngle.int,segments,Fade(BLACK, 0.4)

    #  Draw GUI controls
    # ------------------------------------------------------------------------------
    startAngle = GuiSliderBar(Rectangle(x: 600, y: 40, width: 120, height: 20), "StartAngle", "", startAngle, -450,450)
    endAngle = GuiSliderBar(Rectangle(x: 600, y: 70, width: 120, height: 20), "EndAngle", "", endAngle, -450,450)

    innerRadius = GuiSliderBar(Rectangle(x: 600, y: 140, width: 120, height: 20), "InnerRadius", "", innerRadius, 0,100)
    outerRadius = GuiSliderBar(Rectangle(x: 600, y: 170, width: 120, height: 20), "OuterRadius", "", outerRadius, 0,200)

    segments = GuiSliderBar(Rectangle(x: 600, y: 240, width: 120, height: 20), "Segments", "", segments.float, 0,100).int

    drawRing = GuiCheckBox(Rectangle(x: 600, y: 320, width: 20, height: 20), "Draw Ring", drawRing)
    drawRingLines = GuiCheckBox(Rectangle(x: 600, y: 350, width: 20, height: 20), "Draw RingLines", drawRingLines)
    drawCircleLines = GuiCheckBox(Rectangle(x: 600, y: 380, width: 20, height: 20), "Draw CircleLines", drawCircleLines)
    # ------------------------------------------------------------------------------

    DrawText TextFormat("MODE: %s", (if segments >= 4: "MANUAL" else: "AUTO")), 600, 270, 10,
        (if segments >= 4: MAROON else: DARKGRAY)

    DrawFPS 10, 10

    EndDrawing()
    # ----------------------------------------------------------------------------------

#  De-Initialization
# --------------------------------------------------------------------------------------
CloseWindow()         #  Close window and OpenGL context
# --------------------------------------------------------------------------------------