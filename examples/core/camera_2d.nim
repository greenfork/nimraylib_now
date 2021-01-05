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

import ../../raylib/raylib

const
    MAX_BUILDINGS = 100
    screenWidth   = 800
    screenHeight  = 450

InitWindow(screenWidth, screenHeight, "Camera 2D")

var
    player  = Rectangle(x: 400, y: 280, width: 40, height: 40)
    buildings:   array[MAX_BUILDINGS, Rectangle]
    buildColors: array[MAX_BUILDINGS, Color]
    spacing = 0

for i in 0..<MAX_BUILDINGS:
    buildings[i].width  = GetRandomValue(50, 200).float
    buildings[i].height = GetRandomValue(100, 800).float
    buildings[i].y = screenHeight - 130 - buildings[i].height
    buildings[i].x = -6000 + spacing.float

    spacing += buildings[i].width.int

    buildColors[i] = Color(r: GetRandomValue(200, 240).uint8, g: GetRandomValue(200, 240).uint8, 
        b: GetRandomValue(200, 240).uint8, a: 255)
    #buildColors[i] = RED
var camera = Camera2D()
camera.target = Vector2(x: player.x + 20, y: player.y + 20)
camera.offset = Vector2(x: screenWidth / 2, y: screenHeight / 2)
camera.rotation = 0.0
camera.zoom = 1.0

60.SetTargetFPS

while not WindowShouldClose():
    # Update
    #----------------------------------------------------------------------------------
    # Player movement
    if IsKeyDown(KEY_RIGHT):  player.x += 2
    elif IsKeyDown(KEY_LEFT): player.x -= 2
    # Camera target follows player
    camera.target = Vector2(x: player.x + 20, y: player.y + 20)
    # Camera rotation controls
    if IsKeyDown(KEY_A):   camera.rotation -= 1
    elif IsKeyDown(KEY_S): camera.rotation += 1
    # Limit camera rotation to 80 degrees (-40 to 40)
    if camera.rotation > 40:    camera.rotation = 40
    elif camera.rotation < -40: camera.rotation = -40
    # Camera zoom controls
    camera.zoom += GetMouseWheelMove().float * 0.05
    if camera.zoom > 3.0:   camera.zoom = 3.0
    elif camera.zoom < 0.1: camera.zoom = 0.1
    # Camera reset (zoom and rotation)
    if IsKeyPressed(KEY_R):
        camera.zoom     = 1.0
        camera.rotation = 0.0
    #----------------------------------------------------------------------------------
    # Draw
    #----------------------------------------------------------------------------------
    BeginDrawing()
    ClearBackground RAYWHITE
    BeginMode2D camera 
    DrawRectangle -6000, 320, 13000, 8000, DARKGRAY
    for i in 0..<MAX_BUILDINGS: 
        DrawRectangleRec buildings[i], buildColors[i]
    DrawRectangleRec player, RED
    DrawLine camera.target.x.int32, -screenHeight * 10, camera.target.x.int32, screenHeight * 10, GREEN
    DrawLine -screenWidth * 10, camera.target.y.int32, screenWidth * 10, camera.target.y.int32, GREEN
    EndMode2D()
    DrawText "SCREEN AREA", 640, 10, 20, RED
    DrawRectangle 0, 0, screenWidth, 5, RED
    DrawRectangle 0, 5, 5, screenHeight - 10, RED
    DrawRectangle screenWidth - 5, 5, 5, screenHeight - 10, RED
    DrawRectangle 0, screenHeight - 5, screenWidth, 5, RED
    DrawRectangle 10, 10, 250, 113, Fade(SKYBLUE, 0.5)
    DrawRectangleLines 10, 10, 250, 113, BLUE
    DrawText "Free 2d camera controls:", 20, 20, 10, BLACK
    DrawText "- Right/Left to move Offset", 40, 40, 10, DARKGRAY
    DrawText "- Mouse Wheel to Zoom in-out", 40, 60, 10, DARKGRAY
    DrawText "- A / S to Rotate", 40, 80, 10, DARKGRAY
    DrawText "- R to reset Zoom and Rotation", 40, 100, 10, DARKGRAY
    EndDrawing()
CloseWindow()
