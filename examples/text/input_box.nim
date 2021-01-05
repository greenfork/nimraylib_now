#******************************************************************************************
#
#   raylib [text] example - Input Box
#
#   This example has been created using raylib 1.7 (www.raylib.com)
#   raylib is licensed under an unmodified zlib/libpng license (View raylib.h for details)
#
#   Copyright (c) 2017 Ramon Santamaria (@raysan5)
#   /Converted in 2*20 by Guevara-chan.
#
#*******************************************************************************************

include raylib

const MAX_INPUT_CHARS = 9

#  Initialization
# --------------------------------------------------------------------------------------
const screenWidth = 800
const screenHeight = 450

InitWindow screenWidth, screenHeight, "raylib [text] example - input box"

var
    name: array[MAX_INPUT_CHARS+1, char] #  NOTE: One extra space required for line ending char '\0'
    letterCount = 0

    textBox = Rectangle(x: screenWidth/2 - 100, y: 180, width: 225, height: 50)
    mouseOnText = false

    framesCounter = 0

60.SetTargetFPS               #  Set our game to run at 60 frames-per-second
# --------------------------------------------------------------------------------------

#  Main game loop
while not WindowShouldClose():#  Detect window close button or ESC key
    #  Update
    # ----------------------------------------------------------------------------------
    mouseOnText = CheckCollisionPointRec(GetMousePosition(), textBox)

    if mouseOnText:
        #  Get pressed key (character) on the queue
        var key = GetKeyPressed()

        #  Check if more characters have been pressed on the same frame
        while key > 0:
            #  NOTE: Only allow keys in range [32..125]
            if key >= 32 and key <= 125 and letterCount < MAX_INPUT_CHARS:
                name[letterCount] = key.char
                letterCount.inc
            key = GetKeyPressed()  #  Check next character in the queue

        if KEY_BACKSPACE.IsKeyPressed:
            letterCount.dec
            if letterCount < 0: letterCount = 0
            name[letterCount] = '\0'

    if mouseOnText: framesCounter.inc else: framesCounter = 0
    # ----------------------------------------------------------------------------------

    #  Draw
    # ----------------------------------------------------------------------------------
    BeginDrawing()

    ClearBackground RAYWHITE

    DrawText "PLACE MOUSE OVER INPUT BOX!", 240, 140, 20, GRAY

    DrawRectangleRec textBox, LIGHTGRAY
    if mouseOnText: DrawRectangleLines textBox.x.int, textBox.y.int, textBox.width.int, textBox.height.int, RED
    else: DrawRectangleLines textBox.x.int, textBox.y.int, textBox.width.int, textBox.height.int, DARKGRAY

    let namestr = cast[cstring](addr name[0])
    DrawText $namestr, textBox.x.int + 5, textBox.y.int + 8, 40, MAROON

    DrawText TextFormat("INPUT CHARS: %i/%i", letterCount, MAX_INPUT_CHARS), 315, 250, 20, DARKGRAY

    if mouseOnText:
        if letterCount < MAX_INPUT_CHARS:
            #  Draw blinking underscore char
            if (framesCounter div 20)%%2 == 0:
                DrawText "_", textBox.x.int + 8 + MeasureText(namestr, 40), textBox.y.int + 12, 40, MAROON
        else: DrawText "Press BACKSPACE to delete chars...", 230, 300, 20, GRAY

    EndDrawing()
    # ----------------------------------------------------------------------------------

#  De-Initialization
# --------------------------------------------------------------------------------------
CloseWindow()        #  Close window and OpenGL context
# --------------------------------------------------------------------------------------

#  Check if any key is pressed
#  NOTE: We limit keys check to keys between 32 (KEY_SPACE) and 126
proc IsAnyKeyPressed(): bool =
    var 
        keyPressed = false
        key = GetKeyPressed()

    if key >= 32 and key <= 126: keyPressed = true

    return keyPressed