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

import raylib

#  Initialization
# --------------------------------------------------------------------------------------
const screenWidth = 800
const screenHeight = 450

InitWindow screenWidth, screenHeight, "raylib [text] example - draw text inside a rectangle"

let text = "Text cannot escape\tthis container\t...word wrap also works when active so here's" &
    "a long text for testing.\n\nLorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod" &
    "tempor incididunt ut labore et dolore magna aliqua. Nec ullamcorper sit amet risus nullam eget felis eget."

var
    resizing = false
    wordWrap = true

    container = Rectangle(x: 25, y: 25, width: screenWidth - 50, height: screenHeight - 250)
    resizer   = Rectangle(x: container.x+container.width-17, y: container.y+container.height-17, width: 14, height: 14)

#  Minimum width and heigh for the container rectangle
const minWidth  = 60
const minHeight = 60
const maxWidth  = screenWidth - 50
const maxHeight = screenHeight - 160

var 
    lastMouse = Vector2(x: 0.0f, y: 0.0f) #  Stores last mouse coordinates
    borderColor = MAROON                 #  Container border color
    font = GetFontDefault()              #  Get default system font

60.SetTargetFPS                       #  Set our game to run at 60 frames-per-second
# --------------------------------------------------------------------------------------

#  Main game loop
while not WindowShouldClose():        #  Detect window close button or ESC key
    #  Update
    # ----------------------------------------------------------------------------------
    if IsKeyPressed(KEY_SPACE): wordWrap = not wordWrap

    let mouse = GetMousePosition()

    #  Check if the mouse is inside the container and toggle border color
    if CheckCollisionPointRec(mouse, container): borderColor = Fade(MAROON, 0.4f)
    elif not resizing: borderColor = MAROON

    #  Container resizing logic
    if resizing:
        if IsMouseButtonReleased(MOUSE_LEFT_BUTTON): resizing = false

        let width = container.width + (mouse.x - lastMouse.x)
        container.width = if width > minWidth: (if width < maxWidth: width else: maxWidth) else: minWidth

        let height = container.height + (mouse.y - lastMouse.y)
        container.height = if height > minHeight: (if height < maxHeight: height else: maxHeight) else: minHeight
    else:
        #  Check if we're resizing
        if IsMouseButtonDown(MOUSE_LEFT_BUTTON) and CheckCollisionPointRec(mouse, resizer): resizing = true

    #  Move resizer rectangle properly
    resizer.x = container.x + container.width - 17
    resizer.y = container.y + container.height - 17

    lastMouse = mouse #  Update mouse
    # ----------------------------------------------------------------------------------

    #  Draw
    # ----------------------------------------------------------------------------------
    BeginDrawing()

    ClearBackground RAYWHITE

    DrawRectangleLinesEx container, 3, borderColor  #  Draw container border

    #  Draw text in container (add some padding)
    DrawTextRec font, text,
               Rectangle(x: container.x + 4, y: container.y + 4, width: container.width-4, height: container.height-4),
               20.0f, 2.0f, wordWrap, GRAY

    DrawRectangleRec resizer, borderColor          #  Draw the resize box

    #  Draw bottom info
    DrawRectangle 0, screenHeight - 54, screenWidth, 54, GRAY
    DrawRectangleRec Rectangle(x: 382, y: screenHeight - 34, width: 12, height: 12), MAROON
    
    DrawText "Word Wrap: ", 313, screenHeight-115, 20, BLACK
    if wordWrap: DrawText "ON", 447, screenHeight - 115, 20, RED
    else: DrawText "OFF", 447, screenHeight - 115, 20, BLACK
    
    DrawText "Press [SPACE] to toggle word wrap", 218, screenHeight - 86, 20, GRAY

    DrawText "Click hold & drag the    to resize the container", 155, screenHeight - 38, 20, RAYWHITE
        
    EndDrawing()
    # ----------------------------------------------------------------------------------

#  De-Initialization
# --------------------------------------------------------------------------------------
CloseWindow()        #  Close window and OpenGL context
# --------------------------------------------------------------------------------------