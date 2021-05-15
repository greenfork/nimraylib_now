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


proc main() =
  while not windowShouldClose():
      beginDrawing:
        clearBackground( RAYWHITE)
        if isGamepadAvailable( 0):
          let gamepad_name = getGamePadName( 0)
          drawText( "GP1: " & $gamepad_name, 10, 10, 10, BLACK);

          case $gamepad_name:
            of XBOX360_NAME_ID, XBOX360_LEGACY_NAME_ID:
              drawTexture( texs[XboxPad], 0, 0, DARKGRAY)
            of PS3_NAME_ID:
              drawTexture( texs[Ps3Pad], 0, 0, DARKGRAY)
            else:
              # well … for me it's a PS pad view as a « USB Gamepad »
              drawTexture( texs[Ps3Pad], 0, 0, DARKGRAY)


proc finish() =
  for t in texs:
    unloadTexture( t)
  closeWindow()


init()
main()
finish()
