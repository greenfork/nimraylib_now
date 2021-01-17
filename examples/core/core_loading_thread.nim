# ******************************************************************************************
#
#    raylib example - loading thread
#
#    NOTE: This example requires linking with pthreads library,
#    on MinGW, it can be accomplished passing -static parameter to compiler
#
#    This example has been created using raylib 2.5 (www.raylib.com)
#    raylib is licensed under an unmodified zlib/libpng license (View raylib.h for details)
#
#    Copyright (c) 2014-2019 Ramon Santamaria (@raysan5)
#    Converted in 2021 by greenfork
#
# ******************************************************************************************

# WARNING: compile with --threads:on switch!
# nim c --threads:on <file>

import times, atomics
import ../../src/nimraylib_now/raylib

type State {.pure.} = enum
  Waiting, Loading, Finished

var dataLoaded: Atomic[bool]  ##  Data Loaded completion indicator
dataLoaded.store(false)
proc loadDataThread() {.thread.} ##  Loading data thread function declaration
var dataProgress: int32 = 0 ##  Data progress accumulator
var state = State.Waiting

##  Initialization
## --------------------------------------------------------------------------------------
var screenWidth: int32 = 800
var screenHeight: int32 = 450
initWindow(screenWidth, screenHeight, "raylib [core] example - loading thread")
var threadId: Thread[void] ##  Loading data thread id
var framesCounter: int32 = 0
setTargetFPS(60)
##  Set our game to run at 60 frames-per-second
## --------------------------------------------------------------------------------------
##  Main game loop
while not windowShouldClose(): ##  Detect window close button or ESC key
  ##  Update
  ## ----------------------------------------------------------------------------------
  case state
  of Waiting:
    if isKeyPressed(Enter):
      createThread(threadId, loadDataThread)
      traceLog(Info, "Loading thread initialized successfully")
      state = Loading
  of Loading:
    inc(framesCounter)
    if dataLoaded.load:
      framesCounter = 0
      state = Finished
  of Finished:
    if isKeyPressed(Enter):
      ##  Reset everything to launch again
      dataLoaded.store(false)
      dataProgress = 0
      state = Waiting
  ## ----------------------------------------------------------------------------------
  ##  Draw
  ## ----------------------------------------------------------------------------------
  beginDrawing()
  clearBackground(Raywhite)
  case state
  of Waiting:
    drawText("PRESS ENTER to START LOADING DATA", 150, 170, 20, Darkgray)
  of Loading:
    drawRectangle(150, 200, dataProgress, 60, Skyblue)
    if (framesCounter div 15) mod 2 == 1:
      drawText("LOADING DATA...", 240, 210, 40, Darkblue)
  of Finished:
    drawRectangle(150, 200, 500, 60, Lime)
    drawText("DATA LOADED!", 250, 210, 40, Green)
  drawRectangleLines(150, 200, 500, 60, Darkgray)
  endDrawing()
## ----------------------------------------------------------------------------------
##  De-Initialization
## --------------------------------------------------------------------------------------
closeWindow()
##  Close window and OpenGL context
## --------------------------------------------------------------------------------------

##  Loading data thread function definition

proc loadDataThread() {.thread.} =
  var timeCounter: int32 = 0 ##  Time counted in ms
  var prevTime = cpuTime() ##  Previous time
  ##  We simulate data loading with a time counter for 5 seconds
  while timeCounter < 5000:
    var currentTime = cpuTime() - prevTime
    timeCounter = (int32)currentTime * 1000
    ##  We accumulate time over a global variable to be used in
    ##  main thread as a progress bar
    dataProgress = timeCounter div 10
  ##  When data has finished loading, we set global variable
  dataLoaded.store(true)
