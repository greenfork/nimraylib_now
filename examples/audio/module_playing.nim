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

import raylib, lenientops

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

SetConfigFlags FLAG_MSAA_4X_HINT.uint32 #  NOTE: Try to enable MSAA 4X

InitWindow screenWidth, screenHeight, "raylib [audio] example - module playing (streaming)"

InitAudioDevice()                  #  Initialize audio device

let colors = [ORANGE, RED, GOLD, LIME, BLUE, VIOLET, BROWN, LIGHTGRAY, PINK, YELLOW, GREEN, SKYBLUE, PURPLE, BEIGE]

#  Creates ome circles for visual effect
var circles: array[MAX_CIRCLES, CircleWave]

for i in (MAX_CIRCLES-1).countdown 0:
    circles[i].alpha = 0.0f;
    circles[i].radius = GetRandomValue(10, 40).float
    circles[i].position.x = GetRandomValue(circles[i].radius.int, screenWidth - circles[i].radius.int).float
    circles[i].position.y = GetRandomValue(circles[i].radius.int, screenHeight - circles[i].radius.int).float
    circles[i].speed = (float)GetRandomValue(1, 100)/2000.0f
    circles[i].color = colors[GetRandomValue(0, 13)]

let music = LoadMusicStream("resources/mini1111.xm")

PlayMusicStream music

var
    timePlayed = 0.0f
    pause = false

60.SetTargetFPS                 #  Set our game to run at 60 frames-per-second
# --------------------------------------------------------------------------------------

#  Main game loop
while not WindowShouldClose():    #  Detect window close button or ESC key

    #  Update
    # ----------------------------------------------------------------------------------
    UpdateMusicStream music       #  Update music buffer with new stream data

    #  Restart music playing (stop and play)
    if IsKeyPressed(KEY_SPACE):
        StopMusicStream music
        PlayMusicStream music

    #  Pause/Resume music playing
    if IsKeyPressed(KEY_P):
        pause = not pause
        if pause: PauseMusicStream music
        else: ResumeMusicStream music

    #  Get timePlayed scaled to bar dimensions
    timePlayed = GetMusicTimePlayed(music)/GetMusicTimeLength(music)*(screenWidth - 40)

    #  Color circles animation
    for i in (MAX_CIRCLES-1).countdown 0:
        if pause: break
        circles[i].alpha += circles[i].speed;
        circles[i].radius += circles[i].speed*10.0f;

        if circles[i].alpha > 1.0f: circles[i].speed *= -1

        if (circles[i].alpha <= 0.0f):
            circles[i].alpha = 0.0f;
            circles[i].radius = GetRandomValue(10, 40).float
            circles[i].position.x = GetRandomValue(circles[i].radius.int, screenWidth - circles[i].radius.int).float
            circles[i].position.y = GetRandomValue(circles[i].radius.int, screenHeight - circles[i].radius.int).float
            circles[i].color = colors[GetRandomValue(0, 13)];
            circles[i].speed = (float)GetRandomValue(1, 100)/2000.0f;
    # ----------------------------------------------------------------------------------

    #  Draw
    # ----------------------------------------------------------------------------------
    BeginDrawing()

    ClearBackground(RAYWHITE)

    for i in (MAX_CIRCLES-1).countdown 0:
        DrawCircleV circles[i].position, circles[i].radius, Fade(circles[i].color, circles[i].alpha)

    #  Draw time bar
    DrawRectangle 20, screenHeight - 20 - 12, screenWidth - 40, 12, LIGHTGRAY
    DrawRectangle 20, screenHeight - 20 - 12, timePlayed.int, 12, MAROON
    DrawRectangleLines 20, screenHeight - 20 - 12, screenWidth - 40, 12, GRAY

    EndDrawing()
    # ----------------------------------------------------------------------------------

#  De-Initialization
# --------------------------------------------------------------------------------------
UnloadMusicStream music           #  Unload music stream buffers from RAM

CloseAudioDevice()     #  Close audio device (music streaming is automatically stopped)

CloseWindow()          #  Close window and OpenGL context
# --------------------------------------------------------------------------------------