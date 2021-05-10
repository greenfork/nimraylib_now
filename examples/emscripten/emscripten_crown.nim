# Developed in 2021 by greenfork
# Adapted for emscripten in 2021 by balenamiaa

import math
import nimraylib_now

const
  nimFg: Color = (0xff, 0xc2, 0x00)          # Use this shortcut with alpha = 255!
  nimBg: Color = (0x17, 0x18, 0x1f)

const
  crownSides = 8                             # Low-polygon version
  centerAngle = 2.0 * PI / crownSides.float  # Angle from the center of a circle
  lowerRadius = 2.0                          # Lower crown circle
  upperRadius = lowerRadius * 1.4            # Upper crown circle
  mainHeight = lowerRadius * 0.8             # Height without teeth
  toothHeight = mainHeight * 1.3             # Height with teeth
  toothSkew = 1.2                            # Little angle for teeth

var
  lowerPoints, upperPoints: array[crownSides, tuple[x, y: float]]
  camera = Camera(
    position: (5.0, 8.0, 10.0),  # Camera position
    target: (0.0, 0.0, 0.0),     # Camera target it looks-at
    up: (0.0, 1.0, 0.0),         # Camera up vector (rotation over its axis)
    fovy: 45.0,                  # Camera field-of-view apperture in Y (degrees)
    projection: Perspective      # Defines projection type, see CameraProjection
  )
  pause = false # Pausing the game will stop animation

camera.setCameraMode(Orbital)  # Several modes available, see CameraMode

proc UpdateGameWindow() {.cdecl.} =
  if not pause:
    camera.addr.updateCamera   # Rotate camera

  if isKeyPressed(Space):      # Pressing Space will stop/resume animation
    pause = not pause

  beginDrawing:                # Use drawing functions inside this block
    clearBackground(RayWhite)  # Set background color

    beginMode3D(camera):       # Use 3D drawing functions inside this block
      drawGrid(10, 1.0)

      for i in 0..<crownSides:
        # Define 5 points:
        # - Current lower circle point
        # - Current upper circle point
        # - Next lower circle point
        # - Next upper circle point
        # - Point for peak of crown tooth
        let
          nexti = if i == crownSides - 1: 0 else: i + 1
          lowerCur: Vector3 = (lowerPoints[i].x, 0.0, lowerPoints[i].y)
          upperCur: Vector3 = (upperPoints[i].x, mainHeight, upperPoints[i].y)
          lowerNext: Vector3 = (lowerPoints[nexti].x, 0.0, lowerPoints[nexti].y)
          upperNext: Vector3 = (upperPoints[nexti].x, mainHeight, upperPoints[nexti].y)
          tooth: Vector3 = (
            (upperCur.x + upperNext.x) / 2.0 * toothSkew,
            toothHeight,
            (upperCur.z + upperNext.z) / 2.0 * toothSkew
          )

        # Front polygon (clockwise order)
        drawTriangle3D(lowerCur, upperCur, upperNext, nimFg)
        drawTriangle3D(lowerCur, upperNext, lowerNext, nimFg)

        # Back polygon (counter-clockwise order)
        drawTriangle3D(lowerCur, upperNext, upperCur, nimBg)
        drawTriangle3D(lowerCur, lowerNext, upperNext, nimBg)

        # Wire line for polygons
        drawLine3D(lowerCur, upperCur, Gray)

        # Crown tooth front triangle (clockwise order)
        drawTriangle3D(upperCur, tooth, upperNext, nimFg)

        # Crown tooth back triangle (counter-clockwise order)
        drawTriangle3D(upperNext, tooth, upperCur, nimBg)

    block text:
      block:
        let
          text = "I AM NIM"
          fontSize = 60
          textWidth = measureText(text, fontSize)
          verticalPos = (getScreenHeight().float * 0.4).int
        drawText(
          text,
          (getScreenWidth() - textWidth) div 2,  # center
          (getScreenHeight() + verticalPos) div 2,
          fontSize,
          Black
        )
      block:
        let text =
          if pause: "Press Space to continue"
          else: "Press Space to pause"
        drawText(text, 10, 10, 20, Black)

proc main() =
  # Get evenly spaced points on the lower and upper circles,
  # use Nim's math module for that
  for i in 0..<crownSides:
    let multiplier = i.float
    # Formulas are for 2D space, good enough for 3D since height is always same
    lowerPoints[i] = (
      x: lowerRadius * cos(centerAngle * multiplier),
      y: lowerRadius * sin(centerAngle * multiplier),
    )
    upperPoints[i] = (
      x: upperRadius * cos(centerAngle * multiplier),
      y: upperRadius * sin(centerAngle * multiplier),
    )

  initWindow(800, 600, "[nim]RaylibNow!") # Open window

  emscriptenSetMainLoop(UpdateGameWindow, 0, 1)

  closeWindow()

when isMainModule: main()
