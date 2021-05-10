discard """
  action: "compile"
  joinable: false
  matrix: "; -d:release; --gc:orc -d:release"
"""

# ******************************************************************************************
#
#    raylib [core] example - Custom logging
#
#    This example has been created using raylib 2.1 (www.raylib.com)
#    raylib is licensed under an unmodified zlib/libpng license (View raylib.h for details)
#
#    Example contributed by Pablo Marcos Oltra (@pamarcos) and reviewed by Ramon Santamaria (@raysan5)
#
#    Copyright (c) 2018 Pablo Marcos Oltra (@pamarcos) and Ramon Santamaria (@raysan5)
#    Converted in 2021 by greenfork
#
# ******************************************************************************************

import times, strformat
import ../../src/nimraylib_now

##  Custom logging funtion
proc logCustom(msgType: int32; text: cstring; args: va_list) {.cdecl.} =
  var msg: string
  let timeStr = now().format("yyyy-MM-dd hh:mm:ss")
  msg.add fmt"[{timeStr}] "
  case msgType
  of Info: msg.add "[INFO] : "
  of Error: msg.add "[ERROR]: "
  of Warning: msg.add "[WARN] : "
  of Debug: msg.add "[DEBUG]: "
  else: discard
  msg.add text
  msg.add "\n"
  vprintf(msg.cstring, args)

##  Initialization
## --------------------------------------------------------------------------------------
var screenWidth: int32 = 800
var screenHeight: int32 = 450
##  First thing we do is setting our custom logger to ensure everything raylib logs
##  will use our own logger instead of its internal one
setTraceLogCallback(logCustom)
initWindow(screenWidth, screenHeight, "raylib [core] example - custom logging")
setTargetFPS(60)
##  Set our game to run at 60 frames-per-second
## --------------------------------------------------------------------------------------
##  Main game loop
while not windowShouldClose(): ##  Detect window close button or ESC key
  ##  Update
  ## ----------------------------------------------------------------------------------
  ##  TODO: Update your variables here
  ## ----------------------------------------------------------------------------------
  ##  Draw
  ## ----------------------------------------------------------------------------------
  beginDrawing()
  clearBackground(Raywhite)
  drawText("Check out the console output to see the custom logger in action!",
           60, 200, 20, Lightgray)
  endDrawing()
## ----------------------------------------------------------------------------------
##  De-Initialization
## --------------------------------------------------------------------------------------
closeWindow()
##  Close window and OpenGL context
## --------------------------------------------------------------------------------------
