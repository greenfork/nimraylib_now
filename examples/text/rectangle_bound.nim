#*******************************************************************************************
#
#   raylib [text] example - Draw text inside a rectangle
#
#   This example has been created using raylib 2.3 (www.raylib.com)
#   raylib is licensed under an unmodified zlib/libpng license (View raylib.h for details)
#
#   Example contributed by Vlad Adrian (@demizdor) and reviewed by Ramon Santamaria (@raysan5)
#
#   Copyright (c) 2018 Vlad Adrian (@demizdor) and Ramon Santamaria (@raysan5)
#   /Converted in 2*20 by Guevara-chan.
#
#*******************************************************************************************

import ../../src/nimraylib_now/raylib

#  Initialization
# --------------------------------------------------------------------------------------
const screenWidth = 800
const screenHeight = 450

initWindow screenWidth, screenHeight, "raylib [text] example - draw text inside a rectangle"

let text = "Text cannot escape\tthis container\t...word wrap also works when active so here's" &
    "a long text for testing.\n\nLorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod" &
    "tempor incididunt ut labore et dolore magna aliqua. Nec ullamcorper sit amet risus nullam eget felis eget."

var
    resizing = false
    wordWrap = true

    container: Rectangle = (x: 25f, y: 25f, width: (float32) screenWidth - 50, height: (float32) screenHeight - 250)
    resizer: Rectangle   = (x: container.x+container.width-17, y: container.y+container.height-17, width: 14f, height: 14f)

#  Minimum width and heigh for the container rectangle
const minWidth  = 60
const minHeight = 60
const maxWidth  = screenWidth - 50
const maxHeight = screenHeight - 160

var
    lastMouse: Vector2 = (x: 0.0f, y: 0.0f) #  Stores last mouse coordinates
    borderColor = MAROON                 #  Container border color
    font = getFontDefault()              #  Get default system font

60.setTargetFPS                       #  Set our game to run at 60 frames-per-second
# --------------------------------------------------------------------------------------

#  Main game loop
while not windowShouldClose():        #  Detect window close button or ESC key
    #  Update
    # ----------------------------------------------------------------------------------
    if isKeyPressed(SPACE): wordWrap = not wordWrap

    let mouse = getMousePosition()

    #  Check if the mouse is inside the container and toggle border color
    if checkCollisionPointRec(mouse, container): borderColor = fade(MAROON, 0.4f)
    elif not resizing: borderColor = MAROON

    #  Container resizing logic
    if resizing:
        if isMouseButtonReleased(LEFT_BUTTON): resizing = false

        let width = container.width + (mouse.x - lastMouse.x)
        container.width = if width > minWidth: (if width < maxWidth: width else: maxWidth) else: minWidth

        let height = container.height + (mouse.y - lastMouse.y)
        container.height = if height > minHeight: (if height < maxHeight: height else: maxHeight) else: minHeight
    else:
        #  Check if we're resizing
        if isMouseButtonDown(LEFT_BUTTON) and checkCollisionPointRec(mouse, resizer): resizing = true

    #  Move resizer rectangle properly
    resizer.x = container.x + container.width - 17
    resizer.y = container.y + container.height - 17

    lastMouse = mouse #  Update mouse
    # ----------------------------------------------------------------------------------

    #  Draw
    # ----------------------------------------------------------------------------------
    beginDrawing()

    clearBackground RAYWHITE

    drawRectangleLinesEx container, 3, borderColor  #  Draw container border

    #  Draw text in container (add some padding)
    drawTextRec font, text,
               (x: container.x + 4, y: container.y + 4, width: container.width-4, height: container.height-4),
               20.0f, 2.0f, wordWrap, GRAY

    drawRectangleRec resizer, borderColor          #  Draw the resize box

    #  Draw bottom info
    drawRectangle 0, screenHeight - 54, screenWidth, 54, GRAY
    drawRectangleRec (x: 382f, y: screenHeight - 34f, width: 12f, height: 12f), MAROON

    drawText "Word Wrap: ", 313, screenHeight-115, 20, BLACK
    if wordWrap: drawText "ON", 447, screenHeight - 115, 20, RED
    else: drawText "OFF", 447, screenHeight - 115, 20, BLACK

    drawText "Press [SPACE] to toggle word wrap", 218, screenHeight - 86, 20, GRAY

    drawText "Click hold & drag the    to resize the container", 155, screenHeight - 38, 20, RAYWHITE

    endDrawing()
    # ----------------------------------------------------------------------------------

#  De-Initialization
# --------------------------------------------------------------------------------------
closeWindow()        #  Close window and OpenGL context
# --------------------------------------------------------------------------------------
