#*******************************************************************************************
#
#   raylib [audio] example - Music playing (streaming)
#
#   This example has been created using raylib 1.3 (www.raylib.com)
#   raylib is licensed under an unmodified zlib/libpng license (View raylib.h for details)
#
#   Copyright (c) 2015 Ramon Santamaria (@raysan5)
#   /Converted in 2*20 by Guevara-chan.
#
#*******************************************************************************************

import ../../raylib/raylib

#  Initialization
# --------------------------------------------------------------------------------------
const screenWidth = 800
const screenHeight = 450

InitWindow screenWidth, screenHeight, "raylib [audio] example - music playing (streaming)"

InitAudioDevice()      #  Initialize audio device

let music = LoadMusicStream("resources/guitar_noodling.ogg")         #  Load WAV audio file

PlayMusicStream(music)

var
    timePlayed = 0.0
    pause = false

60.SetTargetFPS        #  Set our game to run at 60 frames-per-second
# --------------------------------------------------------------------------------------

#  Main game loop
while not WindowShouldClose():  #  Detect window close button or ESC key
    #  Update
    # ----------------------------------------------------------------------------------
    music.UpdateMusicStream()

    if KEY_SPACE.IsKeyPressed():
        music.StopMusicStream()
        music.PlayMusicStream()

    if KEY_P.IsKeyPressed():
        pause = not pause
        if pause: music.PauseMusicStream()
        else: music.ResumeMusicStream()

    timePlayed = music.GetMusicTimePlayed()/music.GetMusicTimeLength()*400

    if timePlayed > 400: music.StopMusicStream()
    # ----------------------------------------------------------------------------------

    #  Draw
    # ----------------------------------------------------------------------------------
    BeginDrawing()

    ClearBackground(RAYWHITE)

    DrawText("MUSIC SHOULD BE PLAYING!", 255, 150, 20, LIGHTGRAY)

    DrawRectangle(200, 200, 400, 12, LIGHTGRAY)
    DrawRectangle(200, 200, (int32)timePlayed, 12, MAROON)
    DrawRectangleLines(200, 200, 400, 12, GRAY)

    DrawText("PRESS SPACE TO RESTART MUSIC", 215, 250, 20, LIGHTGRAY)
    DrawText("PRESS P TO PAUSE/RESUME MUSIC", 208, 280, 20, LIGHTGRAY)

    EndDrawing()
    # ----------------------------------------------------------------------------------

#  De-Initialization
# --------------------------------------------------------------------------------------

music.UnloadMusicStream() # Unload music stream buffers from RAM

CloseAudioDevice()     #  Close audio device

CloseWindow()          #  Close window and OpenGL context
# --------------------------------------------------------------------------------------
