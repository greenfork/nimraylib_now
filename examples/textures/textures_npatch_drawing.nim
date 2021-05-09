# ******************************************************************************************
#
#    raylib [textures] example - N-patch drawing
#
#    NOTE: Images are loaded in CPU memory (RAM); textures are loaded in GPU memory (VRAM)
#
#    This example has been created using raylib 2.0 (www.raylib.com)
#    raylib is licensed under an unmodified zlib/libpng license (View raylib.h for details)
#
#    Example contributed by Jorge A. Gomes (@overdev) and reviewed by Ramon Santamaria (@raysan5)
#
#    Copyright (c) 2018 Jorge A. Gomes (@overdev) and Ramon Santamaria (@raysan5)
#    Converted in 2021 by greenfork
#
# ******************************************************************************************

import ../../src/nimraylib_now/raylib

##  Initialization
## --------------------------------------------------------------------------------------
var screenWidth = 800
var screenHeight = 450
initWindow(screenWidth, screenHeight,
           "raylib [textures] example - N-patch drawing")
##  NOTE: Textures MUST be loaded after Window initialization (OpenGL context is requiRed)
var nPatchTexture: Texture2D = loadTexture("resources/ninepatch_button.png")
var mousePosition: Vector2
var origin: Vector2
##  Position and size of the n-patches
var dstRec1: Rectangle = (480.0, 160.0, 32.0, 32.0)
var dstRec2: Rectangle = (160.0, 160.0, 32.0, 32.0)
var dstRecH: Rectangle = (160.0, 93.0, 32.0, 32.0)
var dstRecV: Rectangle = (92.0, 160.0, 32.0, 32.0)
##  A 9-patch (NPT_9PATCH) changes its sizes in both axis
var ninePatchInfo1: NPatchInfo = NPatchInfo(
  source: (0.0, 0.0, 64.0, 64.0),
  left: 12,
  top: 40,
  right: 12,
  bottom: 12,
  layout: NINE_PATCH
)
var ninePatchInfo2: NPatchInfo = NPatchInfo(
  source: (0.0, 128.0, 64.0, 64.0),
  left: 16,
  top: 16,
  right: 16,
  bottom: 16,
  layout: NINE_PATCH
)
##  A horizontal 3-patch (NPT_3PATCH_HORIZONTAL) changes its sizes along the x axis only
var h3PatchInfo: NPatchInfo = NPatchInfo(
  source: (0.0, 64.0, 64.0, 64.0),
  left: 8,
  top: 8,
  right: 8,
  bottom: 8,
  layout: THREE_PATCH_HORIZONTAL
)
##  A vertical 3-patch (NPT_3PATCH_VERTICAL) changes its sizes along the y axis only
var v3PatchInfo: NPatchInfo = NPatchInfo(
  source: (0.0, 192.0, 64.0, 64.0),
  left: 6,
  top: 6,
  right: 6,
  bottom: 6,
  layout: THREE_PATCH_VERTICAL
)
setTargetFPS(60)
## ---------------------------------------------------------------------------------------
##  Main game loop
while not windowShouldClose(): ##  Detect window close button or ESC key
  ##  Update
  ## ----------------------------------------------------------------------------------
  mousePosition = getMousePosition()
  ##  Resize the n-patches based on mouse position
  dstRec1.width = mousePosition.x - dstRec1.x
  dstRec1.height = mousePosition.y - dstRec1.y
  dstRec2.width = mousePosition.x - dstRec2.x
  dstRec2.height = mousePosition.y - dstRec2.y
  dstRecH.width = mousePosition.x - dstRecH.x
  dstRecV.height = mousePosition.y - dstRecV.y
  ##  Set a minimum width and/or height
  if dstRec1.width < 1.0:
    dstRec1.width = 1.0
  if dstRec1.width > 300.0:
    dstRec1.width = 300.0
  if dstRec1.height < 1.0:
    dstRec1.height = 1.0
  if dstRec2.width < 1.0:
    dstRec2.width = 1.0
  if dstRec2.width > 300.0:
    dstRec2.width = 300.0
  if dstRec2.height < 1.0:
    dstRec2.height = 1.0
  if dstRecH.width < 1.0:
    dstRecH.width = 1.0
  if dstRecV.height < 1.0:
    dstRecV.height = 1.0
  beginDrawing()
  clearBackground(Raywhite)
  ##  Draw the n-patches
  drawTextureNPatch(nPatchTexture, ninePatchInfo2, dstRec2, origin, 0.0, White)
  drawTextureNPatch(nPatchTexture, ninePatchInfo1, dstRec1, origin, 0.0, White)
  drawTextureNPatch(nPatchTexture, h3PatchInfo, dstRecH, origin, 0.0, White)
  drawTextureNPatch(nPatchTexture, v3PatchInfo, dstRecV, origin, 0.0, White)
  ##  Draw the source texture
  drawRectangleLines(5, 88, 74, 266, Blue)
  drawTexture(nPatchTexture, 10, 93, White)
  drawText("TEXTURE", 15, 360, 10, Darkgray)
  drawText("Move the mouse to stretch or shrink the n-patches", 10, 20, 20,
           Darkgray)
  endDrawing()
## ----------------------------------------------------------------------------------
##  De-Initialization
## --------------------------------------------------------------------------------------
unloadTexture(nPatchTexture)
##  Texture unloading
closeWindow()
##  Close window and OpenGL context
## --------------------------------------------------------------------------------------
