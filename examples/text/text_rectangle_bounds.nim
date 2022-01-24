#################################################################################################
##
##   raylib [text] example - Draw text inside a rectangle
##
##   This example has been created using raylib 2.3 (www.raylib.com)
##   raylib is licensed under an unmodified zlib/libpng license (View raylib.h for details)
##
##   Example contributed by Vlad Adrian (@demizdor) and reviewed by Ramon Santamaria (@raysan5)
##
##   Copyright (c) 2018 Vlad Adrian (@demizdor) and Ramon Santamaria (@raysan5)
##   Converted in 2022 by LEPINE Florent @Ryback08
##
##
##   Original C version :
##   https://github.com/raysan5/raylib/blob/master/examples/text/text_rectangle_bounds.c
## 
#################################################################################################

import nimraylib_now

proc drawTextBoxed(font: Font, text: string, rec: Rectangle, fontSize: float, spacing: float, wordWrap: bool, tint: Color) ## Draw text using font inside rectangle limits

proc drawTextBoxedSelectable(font: Font, text: string, rec :Rectangle , fontSize: float, spacing: float, wordWrap: bool, tint: Color, selectStart: int, selectLength: int, selectTint: Color, selectBackTint: Color) ## Draw text using font inside rectangle limits with support for text selection

var
  screenWidth: int = 800
  screenHeight: int = 450

initWindow(screenWidth, screenHeight, "raylib [text] example - draw text inside a rectangle")

var text: string = "Text cannot escape\tthis container\t...word wrap also works when active so here's a long text for testing.\n\nLorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Nec ullamcorper sit amet risus nullam eget felis eget."

var
  resizing: bool = false
  wordWrap: bool = true
  container: Rectangle = (25.0, 25.0, screenWidth.float - 50.0, screenHeight.float - 250.0)
  resizer: Rectangle = (container.x + container.width - 17.0, container.y + container.height - 17.0, 14.0, 14.0)

#Minimum width and heigh for the container rectangle
let
  minWidth: float = 60.0
  minHeight: float = 60.0
  maxWidth: float = screenWidth.float - 50.0
  maxHeight: float = screenHeight.float - 160.0


var
  lastMouse: Vector2 = (x:0.0, y:0.0) ## Stores last mouse coordinates
  borderColor: Color = MAROON         ## Container border color
  font: Font = getFontDefault()       ## Get default system font

setTargetFPS(60)                      # Set our game to run at 60 frames-per-second

# Main game loop
while not windowShouldClose():        # Detect window close button or ESC key
  # Update
  if (isKeyPressed(KeyboardKey.SPACE)):
    wordWrap = not wordWrap
  var mouse: Vector2 = getMousePosition()

  # Check if the mouse is inside the container and toggle border color
  if checkCollisionPointRec(mouse, container):
    borderColor = fade(Maroon, 0.4)
  else:
    if not resizing:
      borderColor = Maroon
  
  if resizing:
    if (isMouseButtonReleased(MouseButton.LEFT)):
      resizing = false
    var width = container.width + (mouse.x - lastMouse.x)
    container.width = if (width > minWidth): (if (width < maxWidth): width else: maxWidth) else: minWidth 
    var height = container.height + (mouse.y - lastMouse.y)
    container.height = if (height > minHeight): (if (height < maxHeight): height else: maxHeight) else: minHeight
  else:
    # Check if we're resizing
    if (isMouseButtonDown(MouseButton.LEFT) and checkCollisionPointRec(mouse, resizer)):
      resizing = true
  
  #Move resizer rectangle properly
  resizer.x = container.x + container.width - 17.0
  resizer.y = container.y + container.height - 17.0

  lastMouse = mouse #  Update mouse

  ## Draw
  beginDrawing():
    clearBackground(RAYWHITE)
    drawRectangleLinesEx(container, 3.0, borderColor)  # Draw container border

    # Draw text in container (add some padding)
    drawTextBoxed(font, text, (container.x + 4.0, container.y + 4.0, container.width - 4.0, container.height - 4.0).Rectangle , 20.0, 2.0, wordWrap, GRAY)
    
    drawRectangleRec(resizer, borderColor) # Draw the resize box

    # Draw bottom info
    drawRectangle(0, screenHeight - 54, screenWidth, 54, GRAY)
    drawRectangleRec((382.0, screenHeight.float - 34.0, 12.0, 12.0).Rectangle, MAROON);

    drawText("Word Wrap: ", 313, screenHeight-115, 20, BLACK)
    if wordWrap:
      drawText("ON", 447, screenHeight - 115, 20, RED)
    else :
      drawText("OFF", 447, screenHeight - 115, 20, BLACK)

    drawText("Press [SPACE] to toggle word wrap", 218, screenHeight - 86, 20, GRAY)
    drawText("Click hold & drag the    to resize the container", 155, screenHeight - 38, 20, RAYWHITE)
  
#De-Initialization
closeWindow() #Close window and OpenGL context


#################################################################################################
## Module function definition
#################################################################################################

# Draw text using font inside rectangle limits
proc drawTextBoxed(font: Font, text: string, rec: Rectangle, fontSize: float, spacing: float, wordWrap: bool, tint: Color) =
  drawTextBoxedSelectable(font, text, rec, fontSize, spacing, wordWrap, tint, 0, 0, WHITE, WHITE)

# Draw text using font inside rectangle limits with support for text selection
proc drawTextBoxedSelectable(font: Font, text: string, rec :Rectangle , fontSize: float, spacing: float, wordWrap: bool,
                             tint: Color, selectStart: int, selectLength: int, selectTint: Color, selectBackTint: Color) =
  var
    length: int = cast[int](textLength(text)) ## Total length in bytes of the text, scanned by codepoints in loop # cast because return uint
    textOffsetY: float = 0.0                  ## Offset between lines (on line break '\n')
    textOffsetX: float = 0.0                  ## Offset X to next character to draw
    scaleFactor: float = fontSize/(font.baseSize).float ## Character rectangle scaling factor
    selectStart: int = selectStart

  # Word/character wrapping mechanism variables
  let
    MEASURE_STATE: bool = false
    DRAW_STATE: bool = true
  var state = if wordWrap: MEASURE_STATE else: DRAW_STATE

  var
    startLine: int = -1     ## Index where to begin drawing (where a line begins)
    endLine: int = -1       ## Index where to stop drawing (where a line ends)
    lastk: int = -1         ## Holds last value of the character position

  # @ todo : NIM doit etre simplifier.
  var i, k: int = 0
  while i < length:    # for (int i = 0, k = 0; i < length; i++, k++)
    
    # Get next codepoint from byte string and glyph index in font
    var
      codepointByteCount: cint = 0
      codepoint: int = getCodepoint($text[i], codepointByteCount.addr)
      index: int = getGlyphIndex(font, codepoint)

    # NOTE: Normally we exit the decoding sequence as soon as a bad byte is found (and return 0x3f)
    # but we need to draw all of the bad bytes using the '?' symbol moving one byte    

    if (codepoint == 0x3f): codepointByteCount = 1
    i += (codepointByteCount - 1)
    
    var glyphWidth: float = 0.0
    if codepoint != '\n'.int :
      glyphWidth = if (font.glyphs[index].advanceX == 0): font.recs[index].width*scaleFactor else: font.glyphs[index].advanceX.float*scaleFactor
      if (i + 1 < length): glyphWidth = glyphWidth + spacing
    
    ## NOTE: When wordWrap is ON we first measure how much of the text we can draw before going outside of the rec container
    ## We store this info in startLine and endLine, then we change states, draw the text between those two variables
    ## and change states again and again recursively until the end of the text (or until we get outside of the container).
    ## When wordWrap is OFF we don't need the measure state so we go to the drawing state immediately
    ## and begin drawing on the next line before we can get outside the container.
    if (state == MEASURE_STATE):
      # TODO: There are multiple types of spaces in UNICODE, maybe it's a good idea to add support for more
      # Ref: http://jkorpela.fi/chars/spaces.html
      if ((codepoint == ' '.int) or (codepoint == '\t'.int) or (codepoint == '\n'.int)): endLine = i
      
      if ((textOffsetX + glyphWidth) > rec.width):
        endLine = if (endLine < 1): i else: endLine 
        if (i == endLine): endLine -= codepointByteCount
        if ((startLine + codepointByteCount) == endLine): endLine = (i - codepointByteCount)
        state = not state

      elif ((i + 1) == length):
        endLine = i
        state = not state

      elif (codepoint == '\n'.int): state = not state
      
      if (state == DRAW_STATE):
        textOffsetX = 0
        i = startLine
        glyphWidth = 0.0

        #Save character position when we switch states
        var tmp:int = lastk
        lastk = k - 1
        k = tmp
    
    else:
      
      if (codepoint == '\n'.int):
        if not wordWrap:
          textOffsetY += (font.baseSize.float + font.baseSize.float/2.0)*scaleFactor
          textOffsetX = 0.0
      else:
        if (not wordWrap and ((textOffsetX + glyphWidth) > rec.width)):
          textOffsetY += (font.baseSize.float + font.baseSize.float/2.0)*scaleFactor
          textOffsetX = 0.0

        
        # When text overflows rectangle height limit, just stop drawing
        if ((textOffsetY + font.baseSize.float*scaleFactor) > rec.height): break
      
        # Draw selection background
        var isGlyphSelected: bool = false
        if ((selectStart >= 0) and (k >= selectStart) and (k < (selectStart + selectLength))):
          drawRectangleRec((rec.x + textOffsetX - 1.0, rec.y + textOffsetY, glyphWidth, font.baseSize.float*scaleFactor).Rectangle, selectBackTint)
          isGlyphSelected = true

        
        # Draw current character glyph
        if ((codepoint != ' '.int) and (codepoint != '\t'.int)):
          drawTextCodepoint(font, codepoint, (rec.x + textOffsetX, rec.y + textOffsetY).Vector2, fontSize, if isGlyphSelected: selectTint else: tint)
          
    
      if (wordWrap and (i == endLine)):
        textOffsetY += (font.baseSize.float + font.baseSize.float/2.0)*scaleFactor
        textOffsetX = 0.0
        startLine = endLine
        endLine = -1
        glyphWidth = 0.0
        selectStart += lastk - k
        k = lastk

        state = not state
    textOffsetX += glyphWidth
    inc i
    inc k
    
