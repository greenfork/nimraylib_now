discard """
  action: "compile"
  joinable: false
  matrix: "; -d:release; --gc:orc -d:release"
"""

#******************************************************************************************
#
#   raylib [text] example - Input Box
#
#   This example has been created using raylib 1.7 (www.raylib.com)
#   raylib is licensed under an unmodified zlib/libpng license (View raylib.h for details)
#
#   Copyright (c) 2017 Ramon Santamaria (@raysan5)
#   /Converted in 2*20 by Guevara-chan.
#   Adapted in 2021 by greenfork
#
#*******************************************************************************************

import ../../src/nimraylib_now

const MAX_INPUT_CHARS = 9

#  Initialization
# --------------------------------------------------------------------------------------
const screenWidth = 800
const screenHeight = 450

initWindow screenWidth, screenHeight, "raylib [text] example - input box"

var
    name: array[MAX_INPUT_CHARS+1, char] #  NOTE: One extra space required for line ending char '\0'
    letterCount = 0

    textBox: Rectangle = (x: (float) screenWidth/2 - 100, y: 180.0, width: 225.0, height: 50.0)
    mouseOnText = false

    framesCounter = 0

60.setTargetFPS               #  Set our game to run at 60 frames-per-second
# --------------------------------------------------------------------------------------

#  Main game loop
while not windowShouldClose():#  Detect window close button or ESC key
    #  Update
    # ----------------------------------------------------------------------------------
    mouseOnText = checkCollisionPointRec(getMousePosition(), textBox)

    if mouseOnText:
        #  Get pressed key (character) on the queue
        var key = getKeyPressed()

        #  Check if more characters have been pressed on the same frame
        while key > 0:
            #  NOTE: Only allow keys in range [32..125]
            if key >= 32 and key <= 125 and letterCount < MAX_INPUT_CHARS:
                name[letterCount] = key.char
                letterCount.inc
            key = getKeyPressed()  #  Check next character in the queue

        if isKeyPressed(BACKSPACE):
            letterCount.dec
            if letterCount < 0: letterCount = 0
            name[letterCount] = '\0'

    if mouseOnText: framesCounter.inc else: framesCounter = 0
    # ----------------------------------------------------------------------------------
    #  Draw
    # ----------------------------------------------------------------------------------
    beginDrawing()

    clearBackground RAYWHITE

    drawText "PLACE MOUSE OVER INPUT BOX!", 240, 140, 20, GRAY

    drawRectangleRec textBox, LIGHTGRAY
    if mouseOnText: drawRectangleLines textBox.x.int, textBox.y.int, textBox.width.int, textBox.height.int, RED
    else: drawRectangleLines textBox.x.int, textBox.y.int, textBox.width.int, textBox.height.int, DARKGRAY

    let namestr = cast[cstring](addr name[0])
    drawText $namestr, textBox.x.int + 5, textBox.y.int + 8, 40, MAROON

    drawText textFormat("INPUT CHARS: %i/%i", letterCount, MAX_INPUT_CHARS), 315, 250, 20, DARKGRAY

    if mouseOnText:
        if letterCount < MAX_INPUT_CHARS:
            #  Draw blinking underscore char
            if (framesCounter div 20)%%2 == 0:
                drawText "_", textBox.x.int + 8 + measureText(namestr, 40), textBox.y.int + 12, 40, MAROON
        else: drawText "Press BACKSPACE to delete chars...", 230, 300, 20, GRAY

    endDrawing()

# ----------------------------------------------------------------------------------
#  De-Initialization
# --------------------------------------------------------------------------------------
closeWindow()        #  Close window and OpenGL context
# --------------------------------------------------------------------------------------
