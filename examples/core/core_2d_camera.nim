#*******************************************************************************************
#
#   raylib [core] example - 2d camera
#
#   This example has been created using raylib 1.5 (www.raylib.com)
#   raylib is licensed under an unmodified zlib/libpng license (View raylib.h for details)
#
#   Copyright (c) 2016 Ramon Santamaria (@raysan5)
#   Converted in 2020 by bones527
#
#*******************************************************************************************/

import ../../src/nimraylib_now/raylib

const
    MaxBuildings = 100
    screenWidth   = 800
    screenHeight  = 450

initWindow(screenWidth, screenHeight, "Camera 2D")

var
    player: Rectangle  = (x: 400.0, y: 280.0, width: 40.0, height: 40.0)
    buildings:   array[MAX_BUILDINGS, Rectangle]
    buildColors: array[MAX_BUILDINGS, Color]
    spacing = 0

for i in 0..<MAX_BUILDINGS:
    buildings[i].width  = getRandomValue(50, 200).float
    buildings[i].height = getRandomValue(100, 800).float
    buildings[i].y = screenHeight - 130 - buildings[i].height
    buildings[i].x = -6000 + spacing.float

    spacing += buildings[i].width.int

    buildColors[i] = (
      r: getRandomValue(200, 240).uint8,
      g: getRandomValue(200, 240).uint8,
      b: getRandomValue(200, 240).uint8,
      a: 255.uint8
    )
var camera = Camera2D()
camera.target = (x: player.x + 20, y: player.y + 20)
camera.offset = (x: screenWidth / 2, y: screenHeight / 2)
camera.rotation = 0.0
camera.zoom = 1.0

60.setTargetFPS

while not windowShouldClose():
    # Update
    #----------------------------------------------------------------------------------
    # Player movement
    if isKeyDown(RIGHT):  player.x += 2
    elif isKeyDown(LEFT): player.x -= 2
    # Camera target follows player
    camera.target = (x: player.x + 20, y: player.y + 20)
    # Camera rotation controls
    if isKeyDown(A):   camera.rotation -= 1
    elif isKeyDown(S): camera.rotation += 1
    # Limit camera rotation to 80 degrees (-40 to 40)
    if camera.rotation > 40:    camera.rotation = 40
    elif camera.rotation < -40: camera.rotation = -40
    # Camera zoom controls
    camera.zoom += getMouseWheelMove().float * 0.05
    if camera.zoom > 3.0:   camera.zoom = 3.0
    elif camera.zoom < 0.1: camera.zoom = 0.1
    # Camera reset (zoom and rotation)
    if isKeyPressed(R):
        camera.zoom     = 1.0
        camera.rotation = 0.0
    #----------------------------------------------------------------------------------
    # Draw
    #----------------------------------------------------------------------------------
    beginDrawing()
    clearBackground Raywhite
    beginMode2D camera
    drawRectangle -6000, 320, 13000, 8000, Darkgray
    for i in 0..<MaxBuildings:
        drawRectangleRec buildings[i], buildColors[i]
    drawRectangleRec player, RED
    drawLine camera.target.x.int32, -screenHeight * 10, camera.target.x.int32, screenHeight * 10, GREEN
    drawLine -screenWidth * 10, camera.target.y.int32, screenWidth * 10, camera.target.y.int32, GREEN
    endMode2D()
    drawText "SCREEN AREA", 640, 10, 20, Red
    drawRectangle 0, 0, screenWidth, 5, Red
    drawRectangle 0, 5, 5, screenHeight - 10, Red
    drawRectangle screenWidth - 5, 5, 5, screenHeight - 10, Red
    drawRectangle 0, screenHeight - 5, screenWidth, 5, Red
    drawRectangle 10, 10, 250, 113, fade(Skyblue, 0.5)
    drawRectangleLines 10, 10, 250, 113, Blue
    drawText "Free 2d camera controls:", 20, 20, 10, Black
    drawText "- Right/Left to move Offset", 40, 40, 10, Darkgray
    drawText "- Mouse Wheel to Zoom in-out", 40, 60, 10, Darkgray
    drawText "- A / S to Rotate", 40, 80, 10, Darkgray
    drawText "- R to reset Zoom and Rotation", 40, 100, 10, Darkgray
    endDrawing()
closeWindow()
