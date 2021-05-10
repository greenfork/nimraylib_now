discard """
  action: "compile"
  joinable: false
  matrix: "; -d:release; --gc:orc -d:release"
"""

#*******************************************************************************************
#
#   raylib [shaders] example - Color palette switch
#
#   NOTE: This example requires raylib OpenGL 3.3 or ES2 versions for shaders support,
#         OpenGL 1.1 does not support shaders, recompile raylib to OpenGL 3.3 version.
#
#   NOTE: Shaders used in this example are #version 330 (OpenGL 3.3), to test this example
#         on OpenGL ES 2.0 platforms (Android, Raspberry Pi, HTML5), use #version 100 shaders
#         raylib comes with shaders ready for both versions, check raylib/shaders install folder
#
#   This example has been created using raylib 2.3 (www.raylib.com)
#   raylib is licensed under an unmodified zlib/libpng license (View raylib.h for details)
#
#   Example contributed by Marco Lizza (@MarcoLizza) and reviewed by Ramon Santamaria (@raysan5)
#
#   Copyright (c) 2019 Marco Lizza (@MarcoLizza) and Ramon Santamaria (@raysan5)
#   /Converted in 2*20 by Guevara-chan.
#   Adapted in 2021 by greenfork
#
#*******************************************************************************************

import ../../src/nimraylib_now

const GLSL_VERSION = 330

const MAX_PALETTES       = 3
const COLORS_PER_PALETTE = 8

var palettes = [
    [   #  3-BIT RGB
        0.int32, 0, 0,
        255, 0, 0,
        0, 255, 0,
        0, 0, 255,
        0, 255, 255,
        255, 0, 255,
        255, 255, 0,
        255, 255, 255,
    ],
    [   #  AMMO-8 (GameBoy-like)
        4.int32, 12, 6,
        17, 35, 24,
        30, 58, 41,
        48, 93, 66,
        77, 128, 97,
        137, 162, 87,
        190, 220, 127,
        238, 255, 204,
    ],
    [   #  RKBV (2-strip film)
        21.int32, 25, 26,
        138, 76, 88,
        217, 98, 117,
        230, 184, 193,
        69, 107, 115,
        75, 151, 166,
        165, 189, 194,
        255, 245, 247,
    ],
]
echo palettes

const paletteText = [
    "3-BIT RGB",
    "AMMO-8 (GameBoy-like)",
    "RKBV (2-strip film)"
]


#  Initialization
# --------------------------------------------------------------------------------------
const screenWidth = 800
const screenHeight = 450

initWindow screenWidth, screenHeight, "raylib [shaders] example - color palette switch"

let
  # Load shader to be used on some parts drawing
  # NOTE 1: Using GLSL 330 shader version, on OpenGL ES 2.0 use GLSL 100 shader version
  # NOTE 2: Defining 0 (NULL) for vertex shader forces usage of internal default vertex shader
  shader = loadShader(nil, textFormat("resources/shaders/glsl%i/palette_switch.fs", GLSL_VERSION))
  # Get variable (uniform) location on the shader to connect with the program
  # NOTE: If uniform variable could not be found in the shader, function returns -1
  paletteLoc = getShaderLocation(shader, "palette")

var currentPalette = 0
let lineHeight = screenHeight div COLORS_PER_PALETTE

60.setTargetFPS                        #  Set our game to run at 60 frames-per-second
# --------------------------------------------------------------------------------------

#  Main game loop
while not windowShouldClose():         #  Detect window close button or ESC key
    #  Update
    # ----------------------------------------------------------------------------------
    currentPalette += (if isKeyPressed(RIGHT): 1 elif isKeyPressed(LEFT): -1 else: 0)

    if currentPalette >= MAX_PALETTES: currentPalette = 0
    elif currentPalette < 0: currentPalette = MAX_PALETTES - 1

    #  Send new value to the shader to be used on drawing.
    #  NOTE: We are sending RGB triplets w/o the alpha channel
    setShaderValueV shader, paletteLoc, palettes[currentPalette].addr, IVec3, COLORS_PER_PALETTE
    # ----------------------------------------------------------------------------------

    #  Draw
    # ----------------------------------------------------------------------------------
    beginDrawing:
      clearBackground Raywhite
      beginShaderMode(shader):
        for i in 0..<COLORS_PER_PALETTE:
            #  Draw horizontal screen-wide rectangles with increasing "palette index"
            #  The used palette index is encoded in the RGB components of the pixel
            drawRectangle 0.int32, (int32)lineHeight*i, getScreenWidth(), lineHeight.int32, (r: i, g: i, b: i, a: 255)
      drawText "< >", 10, 10, 30, DARKBLUE
      drawText "CURRENT PALETTE:", 60, 15, 20, RAYWHITE
      drawText paletteText[currentPalette], 300, 15, 20, RED

      drawFPS 700, 15
    # ----------------------------------------------------------------------------------

#  De-Initialization
# --------------------------------------------------------------------------------------
unloadShader shader        #  Unload shader

closeWindow()              #  Close window and OpenGL context
# --------------------------------------------------------------------------------------
