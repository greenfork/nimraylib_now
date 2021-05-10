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
#   Adapted in 2021 by greenfork
#
#*******************************************************************************************

import nimraylib_now

#  Initialization
# --------------------------------------------------------------------------------------
const screenWidth = 800
const screenHeight = 450

initWindow screenWidth, screenHeight, "raylib [shapes] example - draw ring"

var
    center = (x: (getScreenWidth() - 300) / 2, y: getScreenHeight() / 2)

    innerRadius = 80.0
    outerRadius = 190.0

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

    drawLine 500, 0, 500, getScreenHeight(), fade(LIGHTGRAY, 0.6)
    drawRectangle 500, 0, getScreenWidth() - 500, getScreenHeight(), fade(LIGHTGRAY, 0.3)

    if doDrawRing:
      drawRing(center, innerRadius, outerRadius, startAngle.float32, endAngle.float32, segments, fade(MAROON, 0.3))
    if doDrawRingLines:
      drawRingLines(center, innerRadius, outerRadius, startAngle.float32, endAngle.float32, segments, fade(BLACK, 0.4))
    if doDrawCircleLines:
      drawCircleSectorLines(center, outerRadius, startAngle.float32, endAngle.float32, segments, fade(BLACK, 0.4))

    #  Draw GUI controls
    # ------------------------------------------------------------------------------
    startAngle = sliderBar((x: 600.0, y: 40.0, width: 120.0, height: 20.0), "StartAngle", "", startAngle, -450,450)
    endAngle = sliderBar((x: 600.0, y: 70.0, width: 120.0, height: 20.0), "EndAngle", "", endAngle, -450,450)

    innerRadius = sliderBar((x: 600.0, y: 140.0, width: 120.0, height: 20.0), "InnerRadius", "", innerRadius, 0,100)
    outerRadius = sliderBar((x: 600.0, y: 170.0, width: 120.0, height: 20.0), "OuterRadius", "", outerRadius, 0,200)

    segments = sliderBar((x: 600.0, y: 240.0, width: 120.0, height: 20.0), "Segments", "", segments.float, 0,100).int32

    doDrawRing = checkBox((x: 600.0, y: 320.0, width: 20.0, height: 20.0), "Draw Ring", doDrawRing)
    doDrawRingLines = checkBox((x: 600.0, y: 350.0, width: 20.0, height: 20.0), "Draw RingLines", doDrawRingLines)
    doDrawCircleLines = checkBox((x: 600.0, y: 380.0, width: 20.0, height: 20.0), "Draw CircleLines", doDrawCircleLines)
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
