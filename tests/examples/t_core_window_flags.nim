discard """
  action: "compile"
  joinable: false
  matrix: "; -d:release; --gc:orc -d:release"
"""

# ******************************************************************************************
#
#    raylib [core] example - window flags
#
#    This example has been created using raylib 3.5 (www.raylib.com)
#    raylib is licensed under an unmodified zlib/libpng license (View raylib.h for details)
#
#    Copyright (c) 2020 Ramon Santamaria (@raysan5)
#    Converted in 2021 by greenfork
#
# ******************************************************************************************

import lenientops
import ../../src/nimraylib_now

##  Initialization
## ---------------------------------------------------------
var screenWidth = 800
var screenHeight = 450
##  Possible window flags
##
##     FLAG_VSYNC_HINT
##     FLAG_FULLSCREEN_MODE    -> not working properly -> wrong scaling!
##     FLAG_WINDOW_RESIZABLE
##     FLAG_WINDOW_UNDECORATED
##     FLAG_WINDOW_TRANSPARENT
##     FLAG_WINDOW_HIDDEN
##     FLAG_WINDOW_MINIMIZED   -> Not supported on window creation
##     FLAG_WINDOW_MAXIMIZED   -> Not supported on window creation
##     FLAG_WINDOW_UNFOCUSED
##     FLAG_WINDOW_TOPMOST
##     FLAG_WINDOW_HIGHDPI     -> errors after minimize-resize, fb size is recalculated
##     FLAG_WINDOW_ALWAYS_RUN
##     FLAG_MSAA_4X_HINT
##
##  Set configuration flags for window creation
setConfigFlags(VsyncHint or Msaa4xHint or WindowHighdpi)
initWindow(screenWidth, screenHeight, "raylib [core] example - window flags")
var ballPosition: Vector2 = (getScreenWidth().float / 2.0, getScreenHeight().float / 2.0)
var ballSpeed: Vector2 = (5.0, 4.0)
var ballRadius = 20
var framesCounter = 0
setTargetFPS(60)
## ----------------------------------------------------------
##  Main game loop
while not windowShouldClose(): ##  Detect window close button or ESC key
  ##  Update
  ## -----------------------------------------------------
  if isKeyPressed(F):
    toggleFullscreen()
  if isKeyPressed(R):
    if isWindowState(Window_Resizable):
      clearWindowState(Window_Resizable)
    else:
      setWindowState(Window_Resizable)
  if isKeyPressed(D):
    if isWindowState(Window_Undecorated):
      clearWindowState(Window_Undecorated)
    else:
      setWindowState(Window_Undecorated)
  if isKeyPressed(H):
    if not isWindowState(Window_Hidden):
      setWindowState(Window_Hidden)
    framesCounter = 0
  if isWindowState(Window_Hidden):
    inc(framesCounter)
    if framesCounter >= 240:
      clearWindowState(Window_Hidden)
  if isKeyPressed(N):
    if not isWindowState(Window_Minimized):
      minimizeWindow()
    framesCounter = 0
  if isWindowState(Window_Minimized):
    inc(framesCounter)
    if framesCounter >= 240:
      restoreWindow()
  if isKeyPressed(M):
    ##  NOTE: Requires FLAG_WINDOW_RESIZABLE enabled!
    if isWindowState(Window_Maximized):
      restoreWindow()
    else:
      maximizeWindow()
  if isKeyPressed(U):
    if isWindowState(Window_Unfocused):
      clearWindowState(Window_Unfocused)
    else:
      setWindowState(Window_Unfocused)
  if isKeyPressed(T):
    if isWindowState(Window_Topmost):
      clearWindowState(Window_Topmost)
    else:
      setWindowState(Window_Topmost)
  if isKeyPressed(A):
    if isWindowState(Window_Always_Run):
      clearWindowState(Window_Always_Run)
    else:
      setWindowState(Window_Always_Run)
  if isKeyPressed(V):
    if isWindowState(Vsync_Hint):
      clearWindowState(Vsync_Hint)
    else:
      setWindowState(Vsync_Hint)
  ballPosition.x += ballSpeed.x
  ballPosition.y += ballSpeed.y
  if (ballPosition.x >= (getScreenWidth() - ballRadius)) or
      (ballPosition.x <= ballRadius):
    ballSpeed.x = ballSpeed.x * -1.0
  if (ballPosition.y >= (getScreenHeight() - ballRadius)) or
      (ballPosition.y <= ballRadius):
    ballSpeed.y = ballSpeed.y * -1.0
  beginDrawing()
  if isWindowState(Window_Transparent):
    clearBackground(Blank)
  else:
    clearBackground(Raywhite)
  drawCircleV(ballPosition, ballRadius.float, Maroon)
  drawRectangleLinesEx((0.0, 0.0, getScreenWidth().float, getScreenHeight().float), 4, Raywhite)
  drawCircleV(getMousePosition(), 10, Darkblue)
  drawFPS(10, 10)
  drawText(textFormat("Screen Size: [%i, %i]", getScreenWidth(),
                      getScreenHeight()), 10, 40, 10, Green)
  ##  Draw window state info
  drawText("Following flags can be set after window creation:", 10, 60, 10, Gray)
  if isWindowState(Fullscreen_Mode):
    drawText("[F] FLAG_FULLSCREEN_MODE: on", 10, 80, 10, Lime)
  else:
    drawText("[F] FLAG_FULLSCREEN_MODE: off", 10, 80, 10, Maroon)
  if isWindowState(Window_Resizable):
    drawText("[R] FLAG_WINDOW_RESIZABLE: on", 10, 100, 10, Lime)
  else:
    drawText("[R] FLAG_WINDOW_RESIZABLE: off", 10, 100, 10, Maroon)
  if isWindowState(Window_Undecorated):
    drawText("[D] FLAG_WINDOW_UNDECORATED: on", 10, 120, 10, Lime)
  else:
    drawText("[D] FLAG_WINDOW_UNDECORATED: off", 10, 120, 10, Maroon)
  if isWindowState(Window_Hidden):
    drawText("[H] FLAG_WINDOW_HIDDEN: on", 10, 140, 10, Lime)
  else:
    drawText("[H] FLAG_WINDOW_HIDDEN: off", 10, 140, 10, Maroon)
  if isWindowState(Window_Minimized):
    drawText("[N] FLAG_WINDOW_MINIMIZED: on", 10, 160, 10, Lime)
  else:
    drawText("[N] FLAG_WINDOW_MINIMIZED: off", 10, 160, 10, Maroon)
  if isWindowState(Window_Maximized):
    drawText("[M] FLAG_WINDOW_MAXIMIZED: on", 10, 180, 10, Lime)
  else:
    drawText("[M] FLAG_WINDOW_MAXIMIZED: off", 10, 180, 10, Maroon)
  if isWindowState(Window_Unfocused):
    drawText("[G] FLAG_WINDOW_UNFOCUSED: on", 10, 200, 10, Lime)
  else:
    drawText("[U] FLAG_WINDOW_UNFOCUSED: off", 10, 200, 10, Maroon)
  if isWindowState(Window_Topmost):
    drawText("[T] FLAG_WINDOW_TOPMOST: on", 10, 220, 10, Lime)
  else:
    drawText("[T] FLAG_WINDOW_TOPMOST: off", 10, 220, 10, Maroon)
  if isWindowState(Window_Always_Run):
    drawText("[A] FLAG_WINDOW_ALWAYS_RUN: on", 10, 240, 10, Lime)
  else:
    drawText("[A] FLAG_WINDOW_ALWAYS_RUN: off", 10, 240, 10, Maroon)
  if isWindowState(Vsync_Hint):
    drawText("[V] FLAG_VSYNC_HINT: on", 10, 260, 10, Lime)
  else:
    drawText("[V] FLAG_VSYNC_HINT: off", 10, 260, 10, Maroon)
  drawText("Following flags can only be set before window creation:", 10, 300,
           10, Gray)
  if isWindowState(Window_Highdpi):
    drawText("FLAG_WINDOW_HIGHDPI: on", 10, 320, 10, Lime)
  else:
    drawText("FLAG_WINDOW_HIGHDPI: off", 10, 320, 10, Maroon)
  if isWindowState(Window_Transparent):
    drawText("FLAG_WINDOW_TRANSPARENT: on", 10, 340, 10, Lime)
  else:
    drawText("FLAG_WINDOW_TRANSPARENT: off", 10, 340, 10, Maroon)
  if isWindowState(Msaa_4x_Hint):
    drawText("FLAG_MSAA_4X_HINT: on", 10, 360, 10, Lime)
  else:
    drawText("FLAG_MSAA_4X_HINT: off", 10, 360, 10, Maroon)
  endDrawing()
## -----------------------------------------------------
##  De-Initialization
## ---------------------------------------------------------
closeWindow()
##  Close window and OpenGL context
## ----------------------------------------------------------
