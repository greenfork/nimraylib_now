#[
*
*   raylib [core] example - Gamepad input
*
*   NOTE: This example requires a Gamepad connected to the system
*         raylib is configured to work with the following gamepads:
*                - Xbox 360 Controller (Xbox 360, Xbox One)
*                - PLAYSTATION(R)3 Controller
*         Check raylib.h for buttons configuration
*
*   This example has been created using raylib 2.5 (www.raylib.com)
*   raylib is licensed under an unmodified zlib/libpng license (View raylib.h for details)
*
*   Copyright (c) 2013-2019 Ramon Santamaria (@raysan5)
*   Adapted in 2021 by jseb
*
********************************************************************************************]#

import nimraylib_now

# NOTE: Gamepad name ID depends on drivers and OS
when defined(PLATFORM_RPI):
  const XBOX360_NAME_ID = "Microsoft X-Box 360 pad"
else:
  const XBOX360_NAME_ID = "Xbox 360 Controller"

const
  PS3_NAME_ID = "PLAYSTATION(R)3 Controller"
  XBOX360_LEGACY_NAME_ID = "Xbox Controller"
  screenWidth = 800
  screenHeight = 450

type tex_names = enum PS3Pad, XboxPad
var texs:array[tex_names,Texture2D]


proc init() =
  setConfigFlags(MSAA_4X_HINT)  # Set MSAA 4X hint before windows creation

  initWindow(screenWidth, screenHeight, "raylib [core] example - gamepad input")

  texs[Ps3Pad] = loadTexture("resources/ps3.png")
  texs[XboxPad] = loadTexture("resources/xbox.png")

  setTargetFPS( 60)

proc pad_draw_xbox
proc pad_draw_psx


proc main() =
  while not windowShouldClose():
      beginDrawing:
        clearBackground( RAYWHITE)
        if isGamepadAvailable( 0):
          let gamepad_name = getGamePadName( 0)
          drawText( "GP1: " & $gamepad_name, 10, 10, 10, BLACK);

          case $gamepad_name:
            of XBOX360_NAME_ID, XBOX360_LEGACY_NAME_ID:
              pad_draw_xbox()
            of PS3_NAME_ID:
              pad_draw_psx()
            else:
              # well … for me it will be a PS pad view as a « USB Gamepad »
              pad_draw_psx()

          drawText( "DETECTED AXIS: " & $getGamepadAxisCount(0), 10, 50, 10, MAROON)
          for i in 0..getGamepadAxisCount(0):
            #drawText(TextFormat("AXIS %i: %.02f", i, GetGamepadAxisMovement(0, i)), 20, 70 + 20*i, 10, DARKGRAY);
            drawText( "AXIS " & $i & " : " & $getGamepadAxisMovement(0, i), 20, 70 + 20*i, 10, DARKGRAY)

          if (getGamepadButtonPressed() != -1):
            drawText( "DETECTED BUTTON: " & $getGamepadButtonPressed(), 10, 430, 10, RED)
          else:
            drawText("DETECTED BUTTON: NONE", 10, 430, 10, GRAY)

        else:
          drawText("GP1: NOT DETECTED", 10, 10, 10, GRAY);
          drawTexture(texs[XboxPad], 0, 0, LIGHTGRAY);


proc finish() =
  for t in texs:
    unloadTexture( t)
  closeWindow()


proc pad_draw_xbox() =
  drawTexture( texs[XboxPad], 0, 0, DARKGRAY)
  # draw buttons: xbox home
  if (isGamepadButtonDown(0, BUTTON_MIDDLE)): drawCircle(394, 89, 19, YELLOW)

  # draw buttons: basic
  if (isGamepadButtonDown(0, BUTTON_MIDDLE_RIGHT)): drawCircle(436, 150, 9, YELLOW)
  if (isGamepadButtonDown(0, BUTTON_MIDDLE_LEFT)): drawCircle(352, 150, 9, YELLOW)
  if (isGamepadButtonDown(0, BUTTON_RIGHT_FACE_LEFT)): drawCircle(501, 151, 15, BLUE)
  if (isGamepadButtonDown(0, BUTTON_RIGHT_FACE_DOWN)): drawCircle(536, 187, 15, LIME)
  if (isGamepadButtonDown(0, BUTTON_RIGHT_FACE_RIGHT)): drawCircle(572, 151, 15, MAROON)
  if (isGamepadButtonDown(0, BUTTON_RIGHT_FACE_UP)): drawCircle(536, 115, 15, GOLD)

  # draw buttons: d-pad
  drawRectangle(317, 202, 19, 71, BLACK)
  drawRectangle(293, 228, 69, 19, BLACK)
  if (isGamepadButtonDown(0, BUTTON_LEFT_FACE_UP)): drawRectangle(317, 202, 19, 26, YELLOW)
  if (isGamepadButtonDown(0, BUTTON_LEFT_FACE_DOWN)): drawRectangle(317, 202 + 45, 19, 26, YELLOW)
  if (isGamepadButtonDown(0, BUTTON_LEFT_FACE_LEFT)): drawRectangle(292, 228, 25, 19, YELLOW)
  if (isGamepadButtonDown(0, BUTTON_LEFT_FACE_RIGHT)): drawRectangle(292 + 44, 228, 26, 19, YELLOW)

  # draw buttons: left-right back
  if (isGamepadButtonDown(0, BUTTON_LEFT_TRIGGER_1)): drawCircle(259, 61, 20, YELLOW)
  if (isGamepadButtonDown(0, BUTTON_RIGHT_TRIGGER_1)): drawCircle(536, 61, 20, YELLOW)

  # draw axis: left joystick
  drawCircle(259, 152, 39, BLACK)
  drawCircle(259, 152, 34, LIGHTGRAY)
  drawCircle(259 + ((int)getGamepadAxisMovement(0, AXIS_LEFT_X)*20),
             152 + ((int)getGamepadAxisMovement(0, AXIS_LEFT_Y)*20), 25, BLACK)

  # draw axis: right joystick
  drawCircle(461, 237, 38, BLACK)
  drawCircle(461, 237, 33, LIGHTGRAY)
  drawCircle(461 + ((int)getGamepadAxisMovement(0, AXIS_RIGHT_X)*20),
             237 + ((int)getGamepadAxisMovement(0, AXIS_RIGHT_Y)*20), 25, BLACK)

  # draw axis: left-right triggers
  drawRectangle(170, 30, 15, 70, GRAY)
  drawRectangle(604, 30, 15, 70, GRAY)
  drawRectangle(170, 30, 15, (((1 + getGamepadAxisMovement(0, AXIS_LEFT_TRIGGER))/2)*70).int, YELLOW)
  drawRectangle(604, 30, 15, (((1 + getGamepadAxisMovement(0, AXIS_RIGHT_TRIGGER))/2)*70).int, YELLOW)


proc pad_draw_psx() =
  drawTexture( texs[Ps3Pad], 0, 0, DARKGRAY)
  # Draw buttons: ps
  if ( isGamepadButtonDown( 0, BUTTON_MIDDLE)): drawCircle(396, 222, 13, YELLOW)

  # Draw buttons: basic
  if (isGamepadButtonDown(0, BUTTON_MIDDLE_LEFT)): drawRectangle(328, 170, 32, 13, YELLOW)
  if (isGamepadButtonDown(0, BUTTON_MIDDLE_RIGHT)): drawTriangle( Vector2(x:436, y:168 ), Vector2( x:436, y:185), Vector2( x:464, y:177 ), YELLOW)
  if (isGamepadButtonDown(0, BUTTON_RIGHT_FACE_UP)): drawCircle(557, 144, 13, LIME)
  if (isGamepadButtonDown(0, BUTTON_RIGHT_FACE_RIGHT)): drawCircle(586, 173, 13, YELLOW)
  if (isGamepadButtonDown(0, BUTTON_RIGHT_FACE_DOWN)): drawCircle(557, 203, 13, VIOLET)
  if (isGamepadButtonDown(0, BUTTON_RIGHT_FACE_LEFT)): drawCircle(527, 173, 13, PINK)

  # draw buttons: d-pad
  drawRectangle(225, 132, 24, 84, BLACK)
  drawRectangle(195, 161, 84, 25, BLACK)
  if (isGamepadButtonDown(0, BUTTON_LEFT_FACE_UP)): drawRectangle(225, 132, 24, 29, YELLOW)
  if (isGamepadButtonDown(0, BUTTON_LEFT_FACE_DOWN)): drawRectangle(225, 132 + 54, 24, 30, YELLOW)
  if (isGamepadButtonDown(0, BUTTON_LEFT_FACE_LEFT)): drawRectangle(195, 161, 30, 25, YELLOW)
  if (isGamepadButtonDown(0, BUTTON_LEFT_FACE_RIGHT)): drawRectangle(195 + 54, 161, 30, 25, YELLOW)

  # draw buttons: left-right back buttons
  if (isGamepadButtonDown(0, BUTTON_LEFT_TRIGGER_1)): drawCircle(239, 82, 20, YELLOW)
  if (isGamepadButtonDown(0, BUTTON_RIGHT_TRIGGER_1)): drawCircle(557, 82, 20, YELLOW)

  # draw axis: left joystick
  drawCircle(319, 255, 35, BLACK)
  drawCircle(319, 255, 31, LIGHTGRAY)
  drawCircle(319 + ((int)getGamepadAxisMovement(0, AXIS_LEFT_X) * 20),
             255 + ((int)getGamepadAxisMovement(0, AXIS_LEFT_Y) * 20), 25, BLACK)

  # draw axis: right joystick
  drawCircle(475, 255, 35, BLACK)
  drawCircle(475, 255, 31, LIGHTGRAY)
  drawCircle(475 + ((int)getGamepadAxisMovement(0, AXIS_RIGHT_X)*20),
             255 + ((int)getGamepadAxisMovement(0, AXIS_RIGHT_Y)*20), 25, BLACK)

  # draw axis: left-right triggers
  drawRectangle(169, 48, 15, 70, GRAY)
  drawRectangle(611, 48, 15, 70, GRAY)
  drawRectangle(169, 48, 15, (((1 - getGamepadAxisMovement(0, AXIS_LEFT_TRIGGER)) / 2) * 70).int, YELLOW)
  drawRectangle(611, 48, 15, (((1 - getGamepadAxisMovement(0, AXIS_RIGHT_TRIGGER)) / 2) * 70).int, YELLOW)


init()
main()
finish()
