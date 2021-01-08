#*******************************************************************************************
#
#   raylib [audio] example - Music playing (streaming)
#
#   This example has been created using raylib 1.3 (www.raylib.com)
#   raylib is licensed under an unmodified zlib/libpng license (View raylib.h for details)
#
#   Copyright (c) 2015 Ramon Santamaria (@raysan5)
#   /Converted in 2*20 by Guevara-chan.
#   Adapted in 2021 by greenfork
#
#*******************************************************************************************

import ../../src/nimraylib_now/raylib

#  Initialization
# --------------------------------------------------------------------------------------
const screenWidth = 800
const screenHeight = 450

initWindow screenWidth, screenHeight, "raylib [audio] example - music playing (streaming)"

initAudioDevice()      #  Initialize audio device

let music = loadMusicStream("resources/guitar_noodling.ogg")         #  Load WAV audio file

playMusicStream(music)

var
    timePlayed = 0.0
    pause = false

60.setTargetFPS        #  Set our game to run at 60 frames-per-second
# --------------------------------------------------------------------------------------

#  Main game loop
while not windowShouldClose():  #  Detect window close button or ESC key
    #  Update
    # ----------------------------------------------------------------------------------
    music.updateMusicStream()

    if isKeyPressed(SPACE):
        music.stopMusicStream()
        music.playMusicStream()

    if isKeyPressed(P):
        pause = not pause
        if pause: music.pauseMusicStream()
        else: music.resumeMusicStream()

    timePlayed = music.getMusicTimePlayed()/music.getMusicTimeLength()*400

    if timePlayed > 400: music.stopMusicStream()
    # ----------------------------------------------------------------------------------

    #  Draw
    # ----------------------------------------------------------------------------------
    beginDrawing()

    clearBackground(RAYWHITE)

    drawText("MUSIC SHOULD BE PLAYING!", 255, 150, 20, LIGHTGRAY)

    drawRectangle(200, 200, 400, 12, LIGHTGRAY)
    drawRectangle(200, 200, (int32)timePlayed, 12, MAROON)
    drawRectangleLines(200, 200, 400, 12, GRAY)

    drawText("PRESS SPACE TO RESTART MUSIC", 215, 250, 20, LIGHTGRAY)
    drawText("PRESS P TO PAUSE/RESUME MUSIC", 208, 280, 20, LIGHTGRAY)

    endDrawing()
    # ----------------------------------------------------------------------------------

#  De-Initialization
# --------------------------------------------------------------------------------------

music.unloadMusicStream() # Unload music stream buffers from RAM

closeAudioDevice()     #  Close audio device

closeWindow()          #  Close window and OpenGL context
# --------------------------------------------------------------------------------------
