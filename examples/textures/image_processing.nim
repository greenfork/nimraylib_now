#*******************************************************************************************
#
#   raylib [textures] example - Image processing
#
#   NOTE: Images are loaded in CPU memory (RAM) textures are loaded in GPU memory (VRAM)
#
#   This example has been created using raylib 1.4 (www.raylib.com)
#   raylib is licensed under an unmodified zlib/libpng license (View raylib.h for details)
#
#   Copyright (c) 2016 Ramon Santamaria (@raysan5)
#   /Converted in 2*20 by Guevara-chan.
#
#*******************************************************************************************

import raylib, system/[ansi_c]

const NUM_PROCESSES = 8

type ImageProcess = enum
    NONE = 0
    COLOR_GRAYSCALE
    COLOR_TINT
    COLOR_INVERT
    COLOR_CONTRAST
    COLOR_BRIGHTNESS
    FLIP_VERTICAL
    FLIP_HORIZONTAL

const processText = [
    "NO PROCESSING",
    "COLOR GRAYSCALE",
    "COLOR TINT",
    "COLOR INVERT",
    "COLOR CONTRAST",
    "COLOR BRIGHTNESS",
    "FLIP VERTICAL",
    "FLIP HORIZONTAL"
]

#  Initialization
# --------------------------------------------------------------------------------------
const screenWidth = 800
const screenHeight = 450

InitWindow screenWidth, screenHeight, "raylib [textures] example - image processing"

#  NOTE: Textures MUST be loaded after Window initialization (OpenGL context is required)

var image = LoadImage("resources/parrots.png") #  Loaded in CPU memory (RAM)
ImageFormat image.addr, UNCOMPRESSED_R8G8B8A8  #  Format image to RGBA 32bit (required for texture update) <-- ISSUE
let texture = LoadTextureFromImage image       #  Image converted to texture, GPU memory (VRAM)

var
    currentProcess = NONE
    textureReload = false
    selectRecs: array[NUM_PROCESSES, Rectangle]

for i in 0..<NUM_PROCESSES:
    selectRecs[i] = Rectangle(x: 40.0f, y: (50 + 32*i).float, width: 150.0f, height: 30.0f)

60.SetTargetFPS
# ---------------------------------------------------------------------------------------

#  Main game loop
while not WindowShouldClose():    #  Detect window close button or ESC key
    #  Update
    # ----------------------------------------------------------------------------------
    if IsKeyPressed(KEY_DOWN):
        currentProcess = (if currentProcess.int == 7: 0 else: currentProcess.int + 1).ImageProcess
        textureReload = true

    elif IsKeyPressed(KEY_UP):
        currentProcess = (if currentProcess.int == 0: 7 else: currentProcess.int - 1).ImageProcess
        textureReload = true

    if textureReload:
        UnloadImage image                          #  Unload current image data
        image = LoadImage("resources/parrots.png") #  Re-load image data

        #  NOTE: Image processing is a costly CPU process to be done every frame,
        #  If image processing is required in a frame-basis, it should be done
        #  with a texture and by shaders
        case currentProcess:
            of COLOR_GRAYSCALE: ImageColorGrayscale image.addr
            of COLOR_TINT:      ImageColorTint image.addr, GREEN
            of COLOR_INVERT:    ImageColorInvert image.addr
            of COLOR_CONTRAST:  ImageColorContrast image.addr, -40
            of COLOR_BRIGHTNESS:ImageColorBrightness image.addr, -80
            of FLIP_VERTICAL:   ImageFlipVertical image.addr
            of FLIP_HORIZONTAL: ImageFlipHorizontal image.addr
            else: discard

        let pixels = GetImageData(image) #  Get pixel data from image (RGBA 32bit)
        UpdateTexture texture, pixels    #  Update texture with new image data
        pixels.c_free                    #  Unload pixels data from RAM

        textureReload = false
    # ----------------------------------------------------------------------------------

    #  Draw
    # ----------------------------------------------------------------------------------
    BeginDrawing()

    ClearBackground RAYWHITE

    DrawText "IMAGE PROCESSING:", 40, 30, 10, DARKGRAY

    #  Draw rectangles
    for i in 0..<NUM_PROCESSES:
        DrawRectangleRec selectRecs[i], (if i == currentProcess.int: SKYBLUE else: LIGHTGRAY)
        DrawRectangleLines selectRecs[i].x.int, selectRecs[i].y.int, selectRecs[i].width.int, 
            selectRecs[i].height.int, (if i == currentProcess.int: BLUE else: GRAY)
        DrawText processText[i], (selectRecs[i].x + selectRecs[i].width/2 - MeasureText(processText[i], 10)/2).int,
            selectRecs[i].y.int + 11, 10, (if i == currentProcess.int: DARKBLUE else: DARKGRAY)

    DrawTexture texture, screenWidth - texture.width - 60, screenHeight div 2 - texture.height div 2, WHITE
    DrawRectangleLines screenWidth - texture.width - 60, screenHeight div 2 - texture.height div 2, texture.width, 
        texture.height, BLACK

    EndDrawing()
    # ----------------------------------------------------------------------------------

#  De-Initialization
# --------------------------------------------------------------------------------------
UnloadTexture texture        #  Unload texture from VRAM
UnloadImage image            #  Unload image from RAM

CloseWindow()                #  Close window and OpenGL context
# --------------------------------------------------------------------------------------