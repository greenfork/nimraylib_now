# ******************************************************************************************
#
#    raylib [core] example - Input Gestures Detection
#
#    This example has been created using raylib 1.4 (www.raylib.com)
#    raylib is licensed under an unmodified zlib/libpng license (View raylib.h for details)
#
#    Copyright (c) 2016 Ramon Santamaria (@raysan5)
#    Converted in 2021 by greenfork
#
# ******************************************************************************************

import ../../src/nimraylib_now/raylib

const
  MAX_GESTURE_STRINGS = 20

##  Initialization
## --------------------------------------------------------------------------------------
var screenWidth = 800
var screenHeight = 450
initWindow(screenWidth, screenHeight, "raylib [core] example - input gestures")
var touchPosition: Vector2 = (0.0, 0.0)
var touchArea: Rectangle = (220.0, 10.0, (float)screenWidth - 230, (float)screenHeight - 20)
var gesturesCount = 0
var gestureStrings: array[MaxGestureStrings, cstring]
var currentGesture = GestureType.None
var lastGesture = GestureType.None
## SetGesturesEnabled(0b0000000000001001);   // Enable only some gestures to be detected
setTargetFPS(60)
##  Set our game to run at 60 frames-per-second
## --------------------------------------------------------------------------------------
##  Main game loop
while not windowShouldClose(): ##  Detect window close button or ESC key
  ##  Update
  ## ----------------------------------------------------------------------------------
  lastGesture = currentGesture
  currentGesture = getGestureDetected().GestureType
  touchPosition = getTouchPosition(0)
  if checkCollisionPointRec(touchPosition, touchArea) and
      (currentGesture != GestureType.None):
    if currentGesture != lastGesture:
      ##  Store gesture string
      case currentGesture
      of Tap:
        gestureStrings[gesturesCount] = "GESTURE TAP"
      of Doubletap:
        gestureStrings[gesturesCount] = "GESTURE DOUBLETAP"
      of Hold:
        gestureStrings[gesturesCount] = "GESTURE HOLD"
      of Drag:
        gestureStrings[gesturesCount] = "GESTURE DRAG"
      of SwipeRight:
        gestureStrings[gesturesCount] = "GESTURE SWIPE RIGHT"
      of SwipeLeft:
        gestureStrings[gesturesCount] = "GESTURE SWIPE LEFT"
      of SwipeUp:
        gestureStrings[gesturesCount] = "GESTURE SWIPE UP"
      of SwipeDown:
        gestureStrings[gesturesCount] = "GESTURE SWIPE DOWN"
      of PinchIn:
        gestureStrings[gesturesCount] = "GESTURE PINCH IN"
      of PinchOut:
        gestureStrings[gesturesCount] = "GESTURE PINCH OUT"
      else:
        discard
      inc(gesturesCount)
      ##  Reset gestures strings
      if gesturesCount >= MAX_GESTURE_STRINGS:
        var i = 0
        while i < MAX_GESTURE_STRINGS:
          gestureStrings[i] = "\x00"
          inc(i)
        gesturesCount = 0
  beginDrawing()
  clearBackground(Raywhite)
  drawRectangleRec(touchArea, Gray)
  drawRectangle(225, 15, screenWidth - 240, screenHeight - 30, Raywhite)
  drawText("GESTURES TEST AREA", screenWidth - 270, screenHeight - 40, 20,
           fade(Gray, 0.5))
  var i = 0
  while i < gesturesCount:
    if i mod 2 == 0:
      drawRectangle(10, 30 + 20 * i, 200, 20, fade(Lightgray, 0.5))
    else:
      drawRectangle(10, 30 + 20 * i, 200, 20, fade(Lightgray, 0.3))
    if i < gesturesCount - 1:
      drawText(gestureStrings[i], 35, 36 + 20 * i, 10, Darkgray)
    else:
      drawText(gestureStrings[i], 35, 36 + 20 * i, 10, Maroon)
    inc(i)
  drawRectangleLines(10, 29, 200, screenHeight - 50, Gray)
  drawText("DETECTED GESTURES", 50, 15, 10, Gray)
  if currentGesture != GestureType.None:
    drawCircleV(touchPosition, 30, Maroon)
  endDrawing()
## ----------------------------------------------------------------------------------
##  De-Initialization
## --------------------------------------------------------------------------------------
closeWindow()
##  Close window and OpenGL context
## --------------------------------------------------------------------------------------
