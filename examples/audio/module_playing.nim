#*******************************************************************************************
#
#   raylib [audio] example - Module playing (streaming)
#
#   This example has been created using raylib 1.5 (www.raylib.com)
#   raylib is licensed under an unmodified zlib/libpng license (View raylib.h for details)
#
#   Copyright (c) 2016 Ramon Santamaria (@raysan5)
#   /Converted in 2*20 by Guevara-chan.
#
#*******************************************************************************************

import ../../src/nimraylib_now/raylib, lenientops

const MAX_CIRCLES = 64

type CircleWave = object
    position:   Vector2
    radius:     float
    alpha:      float
    speed:      float
    color:      Color

#  Initialization
# --------------------------------------------------------------------------------------
const screenWidth = 800
const screenHeight = 450

setConfigFlags MSAA_4X_HINT #  NOTE: Try to enable MSAA 4X

initWindow screenWidth, screenHeight, "raylib [audio] example - module playing (streaming)"

initAudioDevice()                  #  Initialize audio device

let colors = [ORANGE, RED, GOLD, LIME, BLUE, VIOLET, BROWN, LIGHTGRAY, PINK, YELLOW, GREEN, SKYBLUE, PURPLE, BEIGE]

#  Creates ome circles for visual effect
var circles: array[MAX_CIRCLES, CircleWave]

for i in (MAX_CIRCLES-1).countdown 0:
    circles[i].alpha = 0.0f;
    circles[i].radius = getRandomValue(10, 40).float
    circles[i].position.x = getRandomValue(circles[i].radius.int32, screenWidth - circles[i].radius.int32).float
    circles[i].position.y = getRandomValue(circles[i].radius.int32, screenHeight - circles[i].radius.int32).float
    circles[i].speed = (float)getRandomValue(1, 100)/2000.0f
    circles[i].color = colors[getRandomValue(0, 13)]

let music = loadMusicStream("./resources/mini1111.xm")

playMusicStream music

var
    timePlayed = 0.0f
    pause = false

60.setTargetFPS                 #  Set our game to run at 60 frames-per-second
# --------------------------------------------------------------------------------------

#  Main game loop
while not windowShouldClose():    #  Detect window close button or ESC key

    #  Update
    # ----------------------------------------------------------------------------------
    updateMusicStream music       #  Update music buffer with new stream data

    #  Restart music playing (stop and play)
    if isKeyPressed(SPACE):
        stopMusicStream music
        playMusicStream music

    #  Pause/Resume music playing
    if isKeyPressed(P):
        pause = not pause
        if pause: pauseMusicStream music
        else: resumeMusicStream music

    #  Get timePlayed scaled to bar dimensions
    timePlayed = getMusicTimePlayed(music)/getMusicTimeLength(music)*(screenWidth - 40)

    #  Color circles animation
    for i in (MAX_CIRCLES-1).countdown 0:
        if pause: break
        circles[i].alpha += circles[i].speed;
        circles[i].radius += circles[i].speed*10.0f;

        if circles[i].alpha > 1.0f: circles[i].speed *= -1

        if (circles[i].alpha <= 0.0f):
            circles[i].alpha = 0.0f;
            circles[i].radius = getRandomValue(10, 40).float
            circles[i].position.x = getRandomValue(circles[i].radius.int32, screenWidth - circles[i].radius.int32).float
            circles[i].position.y = getRandomValue(circles[i].radius.int32, screenHeight - circles[i].radius.int32).float
            circles[i].color = colors[getRandomValue(0, 13)];
            circles[i].speed = (float)getRandomValue(1, 100)/2000.0f;
    # ----------------------------------------------------------------------------------

    #  Draw
    # ----------------------------------------------------------------------------------
    beginDrawing()

    clearBackground(RAYWHITE)

    for i in (MAX_CIRCLES-1).countdown 0:
        drawCircleV circles[i].position, circles[i].radius, fade(circles[i].color, circles[i].alpha)

    #  Draw time bar
    drawRectangle 20, screenHeight - 20 - 12, screenWidth - 40, 12, LIGHTGRAY
    drawRectangle 20, screenHeight - 20 - 12, timePlayed.int32, 12, MAROON
    drawRectangleLines 20, screenHeight - 20 - 12, screenWidth - 40, 12, GRAY

    endDrawing()
    # ----------------------------------------------------------------------------------

#  De-Initialization
# --------------------------------------------------------------------------------------
unloadMusicStream music           #  Unload music stream buffers from RAM

closeAudioDevice()     #  Close audio device (music streaming is automatically stopped)

closeWindow()          #  Close window and OpenGL context
# --------------------------------------------------------------------------------------
