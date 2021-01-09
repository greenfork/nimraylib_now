# Developed in 2021 by greenfork

import math
import ../../src/nimraylib_now/raylib

const
  nimFg: Color = (0xff, 0xc2, 0x00) # use this shortcut with alpha = 255!
  nimBg: Color = (0x17, 0x18, 0x1f)

# Let's draw a Nim crown!
const
  crownSides = 8                             # low-polygon version
  centerAngle = 2.0 * PI / crownSides.float  # angle from the center of a circle
  lowerRadius = 2.0                          # lower crown circle
  upperRadius = lowerRadius * 1.4            # upper crown circle
  mainHeight = lowerRadius * 0.8             # height without teeth
  toothHeight = mainHeight * 1.3             # height with teeth
  toothSkew = 1.2                            # little angle for teeth

var
  lowerPoints, upperPoints: array[crownSides, tuple[x, y: float]]

# Get evenly spaced points on the lower and upper circles,
# use Nim's math module for that
for i in 0..<crownSides:
  let multiplier = i.float
  # Formulas are for 2D space, good enough for 3D since height is always same
  lowerPoints[i] = (
    lowerRadius * cos(centerAngle * multiplier),
    lowerRadius * sin(centerAngle * multiplier),
  )
  upperPoints[i] = (
    upperRadius * cos(centerAngle * multiplier),
    upperRadius * sin(centerAngle * multiplier),
  )

initWindow(800, 600, "[nim]RaylibNow!") # open window

var camera = Camera(
  position: (5.0, 8.0, 10.0),  # Camera position
  target: (0.0, 0.0, 0.0),     # Camera target it looks-at
  up: (0.0, 1.0, 0.0),         # Camera up vector (rotation over its axis)
  fovy: 45.0,                  # Camera field-of-view apperture in Y (degrees)
                               # in Perspective, used as near plane width
                               # in Orthographic
  `type`: Perspective          # Camera type, defines projection type:
                               # Perspective or Orthographic
)
camera.setCameraMode(Orbital)  # Several modes available, see CameraMode

setTargetFPS(60)

# Wait for Esc key press or when the window is closed
while not windowShouldClose():
  camera.addr.updateCamera     # rotate camera

  beginDrawing:                # use this sugar to insert endDrawing() automatically!
    clearBackground(RayWhite)  # set background color

    beginMode3D(camera):
      drawGrid(10, 1.0)

      for i in 0..<crownSides:
        # Define 5 points:
        # - Current lower circle point
        # - Current upper circle point
        # - Next lower circle point
        # - Next upper circle point
        # - Point for crown tooth
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
        drawLine3D(lowerCur, upperCur, fade(nimFg, 0.8))

        # Crown tooth front triangle (clockwise order)
        drawTriangle3D(upperCur, tooth, upperNext, nimFg)

        # Crown tooth back triangle (counter-clockwise order)
        drawTriangle3D(upperNext, tooth, upperCur, nimBg)

    block text:
      let verticalPos = (getScreenHeight().float * 0.5).int
      block:
        let
          text = "I AM NIM"
          fontSize = 60
          textWidth = measureText(text, fontSize)
        drawText(
          text,
          (getScreenWidth() - textWidth) div 2,  # center
          # Minus double `fontSize` for spacing for the next text
          (getScreenHeight() - fontSize - fontSize + verticalPos) div 2,
          fontSize,
          Black
        )
      block:
        let
          text = "OBEY"
          fontSize = 60
          textWidth = measureText(text, fontSize)
        drawText(
          text,
          (getScreenWidth() - textWidth) div 2,
          (getScreenHeight() + verticalPos) div 2,
          fontSize,
          Black
        )

closeWindow()
