#*******************************************************************************************
#
#   raylib [audio] example - Raw audio streaming
#
#   This example has been created using raylib 1.6 (www.raylib.com)
#   raylib is licensed under an unmodified zlib/libpng license (View raylib.h for details)
#
#   Example created by Ramon Santamaria (@raysan5) and reviewed by James Hofmann (@triplefox)
#
#   Copyright (c) 2015-2019 Ramon Santamaria (@raysan5) and James Hofmann (@triplefox)
#   /Converted in 2*20 by Guevara-chan.
#
#*******************************************************************************************

import ../../raylib/raylib, math, lenientops

const MAX_SAMPLES            = 512
const MAX_SAMPLES_PER_UPDATE = 4096

#  Initialization
# --------------------------------------------------------------------------------------
const screenWidth = 800
const screenHeight = 450

InitWindow screenWidth, screenHeight, "raylib [audio] example - raw audio streaming"

InitAudioDevice()              #  Initialize audio device

#  Init raw audio stream (sample rate: 22050, sample size: 16bit-short, channels: 1-mono)
let stream = InitAudioStream(22050, 16, 1)

#  Buffer for the single cycle waveform we are synthesizing
var data: array[MAX_SAMPLES, uint16]

#  Frame buffer, describing the waveform when repeated over the course of a frame
var writeBuf: array[MAX_SAMPLES_PER_UPDATE, uint16]

PlayAudioStream stream         #  Start processing stream buffer (no data loaded currently)

#  Position read in to determine next frequency
var mousePosition = Vector2(x: -100.0f, y: -100.0f)

#  Cycles per second (hz)
var frequency = 440.0f

#  Previous value, used to test if sine needs to be rewritten, and to smoothly modulate frequency
var oldFrequency = 1.0f

#  Cursor to read and copy the samples of the sine wave buffer
var readCursor = 0

#  Computed size in samples of the sine wave
var waveLength = 1

var position = Vector2()

30.SetTargetFPS                 #  Set our game to run at 30 frames-per-second
# --------------------------------------------------------------------------------------

#  Main game loop
while not WindowShouldClose():  #  Detect window close button or ESC key
    #  Update
    # ----------------------------------------------------------------------------------

    #  Sample mouse input.
    mousePosition = GetMousePosition()

    if IsMouseButtonDown(MOUSE_LEFT_BUTTON): frequency = 40.0f + (mousePosition.y).float

    #  Rewrite the sine wave.
    #  Compute two cycles to allow the buffer padding, simplifying any modulation, resampling, etc.
    if frequency != oldFrequency:
        #  Compute wavelength. Limit size in both directions.
        let oldWavelength = waveLength
        waveLength = (22050/frequency).int
        if waveLength > MAX_SAMPLES div 2: waveLength = MAX_SAMPLES div 2
        if waveLength < 1: waveLength = 1

        #  Write sine wave.
        for i in 0..<waveLength*2:
            data[i] = (sin(((2*PI*i.float/waveLength)))*32000).uint16

        #  Scale read cursor's position to minimize transition artifacts
        readCursor = (readCursor * (waveLength / oldWavelength)).int
        oldFrequency = frequency

    #  Refill audio stream if required
    if IsAudioStreamProcessed(stream):
        #  Synthesize a buffer that is exactly the requested size
        var writeCursor = 0

        while writeCursor < MAX_SAMPLES_PER_UPDATE:
            #  Start by trying to write the whole chunk at once
            var writeLength = MAX_SAMPLES_PER_UPDATE-writeCursor;

            #  Limit to the maximum readable size
            let readLength = waveLength-readCursor;

            if writeLength > readLength: writeLength = readLength

            #  Write the slice
            echo writeCursor
            copyMem cast[pointer](cast[int](writeBuf.addr)+writeCursor), cast[pointer](cast[int](data.addr)+readCursor),
                 writeLength*sizeof(uint16)

            #  Update cursors and loop audio
            readCursor = (readCursor + writeLength) %% waveLength

            writeCursor += writeLength

        #  Copy finished frame to audio stream
        UpdateAudioStream stream, writeBuf.addr, MAX_SAMPLES_PER_UPDATE
    # ----------------------------------------------------------------------------------

    #  Draw
    # ----------------------------------------------------------------------------------
    BeginDrawing()

    ClearBackground RAYWHITE

    DrawText TextFormat("sine frequency: %i",(int)frequency), GetScreenWidth() - 220, 10, 20, RED
    DrawText "click mouse button to change frequency", 10, 10, 20, DARKGRAY

    #  Draw the current buffer state proportionate to the screen
    for i in 0..<screenWidth:
        position.x = i.float
        position.y = 250 + 50 * data[i*MAX_SAMPLES div screenWidth].float / 32000
        DrawPixelV position, RED

    EndDrawing()
    # ----------------------------------------------------------------------------------

#  De-Initialization
# --------------------------------------------------------------------------------------
CloseAudioStream stream    #  Close raw audio stream and delete buffers from RAM
CloseAudioDevice()         #  Close audio device (music streaming is automatically stopped)

CloseWindow()              #  Close window and OpenGL context
# --------------------------------------------------------------------------------------
