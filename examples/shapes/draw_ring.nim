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
    center = (x: (getScreenWidth() - 300) / 2, y: getScreenHeight() / 2)

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
    startAngle = sliderBar((x: 600f, y: 40f, width: 120f, height: 20f), "StartAngle", "", startAngle, -450,450)
    endAngle = sliderBar((x: 600f, y: 70f, width: 120f, height: 20f), "EndAngle", "", endAngle, -450,450)

    innerRadius = sliderBar((x: 600f, y: 140f, width: 120f, height: 20f), "InnerRadius", "", innerRadius, 0,100)
    outerRadius = sliderBar((x: 600f, y: 170f, width: 120f, height: 20f), "OuterRadius", "", outerRadius, 0,200)

    segments = sliderBar((x: 600f, y: 240f, width: 120f, height: 20f), "Segments", "", segments.float, 0,100).int32

    doDrawRing = checkBox((x: 600f, y: 320f, width: 20f, height: 20f), "Draw Ring", doDrawRing)
    doDrawRingLines = checkBox((x: 600f, y: 350f, width: 20f, height: 20f), "Draw RingLines", doDrawRingLines)
    doDrawCircleLines = checkBox((x: 600f, y: 380f, width: 20f, height: 20f), "Draw CircleLines", doDrawCircleLines)
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
