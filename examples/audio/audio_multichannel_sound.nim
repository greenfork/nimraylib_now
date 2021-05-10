#*******************************************************************************************
#
#   raylib [audio] example - Multichannel sound playing
#
#   This example has been created using raylib 2.6 (www.raylib.com)
#   raylib is licensed under an unmodified zlib/libpng license (View raylib.h for details)
#
#   Example contributed by Chris Camacho (@codifies) and reviewed by Ramon Santamaria (@raysan5)
#
#   Copyright (c) 2019 Chris Camacho (@codifies) and Ramon Santamaria (@raysan5)
#   /Converted in 2*20 by Guevara-chan.
#   Adapted in 2021 by greenfork
#
#*******************************************************************************************

import nimraylib_now

#  Initialization
# --------------------------------------------------------------------------------------
const screenWidth = 800
const screenHeight = 450

initWindow screenWidth, screenHeight, "raylib [audio] example - Multichannel sound playing"

initAudioDevice()      #  Initialize audio device

let
    fxWav = loadSound("resources/sound.wav")         #  Load WAV audio file
    fxOgg = loadSound("resources/tanatana.ogg")      #  Load OGG audio file

setSoundVolume fxWav, 0.2

60.setTargetFPS        #  Set our game to run at 60 frames-per-second
# --------------------------------------------------------------------------------------

#  Main game loop
while not windowShouldClose():  #  Detect window close button or ESC key
    #  Update
    # ----------------------------------------------------------------------------------
    if isKeyPressed(ENTER): playSoundMulti fxWav      #  Play a new wav sound instance
    if isKeyPressed(SPACE): playSoundMulti fxOgg      #  Play a new ogg sound instance
    # ----------------------------------------------------------------------------------

    #  Draw
    # ----------------------------------------------------------------------------------
    beginDrawing()

    clearBackground RAYWHITE

    drawText "MULTICHANNEL SOUND PLAYING", 20, 20, 20, GRAY
    drawText "Press SPACE to play new ogg instance!", 200, 120, 20, LIGHTGRAY
    drawText "Press ENTER to play new wav instance!", 200, 180, 20, LIGHTGRAY

    drawText textFormat("CONCURRENT SOUNDS PLAYING: %02i", getSoundsPlaying()), 220, 280, 20, RED

    endDrawing()
    # ----------------------------------------------------------------------------------

#  De-Initialization
# --------------------------------------------------------------------------------------
stopSoundMulti()       #  We must stop the buffer pool before unloading

unloadSound fxWav      #  Unload sound data
unloadSound fxOgg      #  Unload sound data

closeAudioDevice()     #  Close audio device

closeWindow()          #  Close window and OpenGL context
# --------------------------------------------------------------------------------------
