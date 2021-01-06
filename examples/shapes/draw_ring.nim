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

import ../../src/nimraylib_now/[raylib, raygui]

#  Initialization
# --------------------------------------------------------------------------------------
const screenWidth = 800
const screenHeight = 450

initWindow screenWidth, screenHeight, "raylib [shapes] example - draw ring"

var
    center = Vector2(x: (getScreenWidth() - 300) / 2, y: getScreenHeight() / 2)

    innerRadius = 80.0f
    outerRadius = 190.0f

    startAngle = 0.0
    endAngle = 360.0
    segments = 0.int32

    doDrawRing = true
    doDrawRingLines = false
    doDrawCircleLines = false

60.setTargetFPS                 #  Set our game to run at 60 frames-per-second
# --------------------------------------------------------------------------------------

#  Main game loop
while not windowShouldClose():  #  Detect window close button or ESC key
    #  Update
    # ----------------------------------------------------------------------------------
    #  NOTE: All variables update happens inside GUI control functions
    # ----------------------------------------------------------------------------------

    #  Draw
    # ----------------------------------------------------------------------------------
    beginDrawing()

    clearBackground RAYWHITE

    drawLine 500, 0, 500, getScreenHeight(), fade(LIGHTGRAY, 0.6f)
    drawRectangle 500, 0, getScreenWidth() - 500, getScreenHeight(), fade(LIGHTGRAY, 0.3f)

    if doDrawRing:
      drawRing(center, innerRadius, outerRadius, startAngle.int32, endAngle.int32, segments, fade(MAROON, 0.3f))
    if doDrawRingLines:
      drawRingLines(center, innerRadius, outerRadius, startAngle.int32, endAngle.int32, segments, fade(BLACK, 0.4))
    if doDrawCircleLines:
      drawCircleSectorLines(center, outerRadius, startAngle.int32, endAngle.int32, segments, fade(BLACK, 0.4))

    #  Draw GUI controls
    # ------------------------------------------------------------------------------
    startAngle = sliderBar(Rectangle(x: 600, y: 40, width: 120, height: 20), "StartAngle", "", startAngle, -450,450)
    endAngle = sliderBar(Rectangle(x: 600, y: 70, width: 120, height: 20), "EndAngle", "", endAngle, -450,450)

    innerRadius = sliderBar(Rectangle(x: 600, y: 140, width: 120, height: 20), "InnerRadius", "", innerRadius, 0,100)
    outerRadius = sliderBar(Rectangle(x: 600, y: 170, width: 120, height: 20), "OuterRadius", "", outerRadius, 0,200)

    segments = sliderBar(Rectangle(x: 600, y: 240, width: 120, height: 20), "Segments", "", segments.float, 0,100).int32

    doDrawRing = checkBox(Rectangle(x: 600, y: 320, width: 20, height: 20), "Draw Ring", doDrawRing)
    doDrawRingLines = checkBox(Rectangle(x: 600, y: 350, width: 20, height: 20), "Draw RingLines", doDrawRingLines)
    doDrawCircleLines = checkBox(Rectangle(x: 600, y: 380, width: 20, height: 20), "Draw CircleLines", doDrawCircleLines)
    # ------------------------------------------------------------------------------

    drawText textFormat("MODE: %s", (if segments >= 4: "MANUAL" else: "AUTO")), 600, 270, 10,
        (if segments >= 4: MAROON else: DARKGRAY)

    drawFPS 10, 10

    endDrawing()
    # ----------------------------------------------------------------------------------

#  De-Initialization
# --------------------------------------------------------------------------------------
closeWindow()         #  Close window and OpenGL context
# --------------------------------------------------------------------------------------
