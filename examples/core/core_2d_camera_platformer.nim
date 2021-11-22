# ******************************************************************************************
#
#    raylib [core] example - 2d camera platformer
#
#    This example has been created using raylib 2.5 (www.raylib.com)
#    raylib is licensed under an unmodified zlib/libpng license (View raylib.h for details)
#
#    Example contributed by arvyy (@arvyy) and reviewed by Ramon Santamaria (@raysan5)
#
#    Copyright (c) 2019 arvyy (@arvyy)
#    Converted in 2021 by greenfork
#
# ******************************************************************************************

import lenientops
import nimraylib_now

const
  G = 400
  PLAYER_JUMP_SPD = 350.0
  PLAYER_HOR_SPD = 200.0

type
  Player = object
    position: Vector2
    speed: float
    canJump: bool

  EnvItem = object
    rect: Rectangle
    blocking: bool
    color: Color

proc updatePlayer(player: var Player, envItems: var openArray[EnvItem],  delta: float)
proc updateCameraCenter(camera: var Camera2D, player: var Player,
                        envItems: var openArray[EnvItem], delta: float,
                        width: int, height: int)
proc updateCameraCenterInsideMap(camera: var Camera2D, player: var Player,
                                 envItems: var openArray[EnvItem],
                                 delta: float, width: int, height: int)
proc updateCameraCenterSmoothFollow(camera: var Camera2D, player: var Player,
                                    envItems: var openArray[EnvItem],
                                    delta: float, width: int, height: int)
proc updateCameraEvenOutOnLanding(camera: var Camera2D, player: var Player,
                                  envItems: var openArray[EnvItem],
                                  delta: float, width: int, height: int)
proc updateCameraPlayerBoundsPush(camera: var Camera2D, player: var Player,
                                  envItems: var openArray[EnvItem],
                                  delta: float, width: int, height: int)
##  Initialization
## --------------------------------------------------------------------------------------
var screenWidth = 800
var screenHeight = 450
initWindow(screenWidth, screenHeight, "raylib [core] example - 2d camera")
var player = Player()
player.position = (x: 400.0, y: 280.0)
player.speed = 0
player.canJump = false
var envItems = [
  EnvItem(rect: (x: 0.0, y: 0.0, width: 1000.0, height: 400.0), blocking: false, color: Lightgray),
  EnvItem(rect: (x: 0.0, y: 400.0, width: 1000.0, height: 200.0), blocking: true, color: Gray),
  EnvItem(rect: (x: 300.0, y: 200.0, width: 400.0, height: 10.0), blocking: true, color: Gray),
  EnvItem(rect: (x: 250.0, y: 300.0, width: 100.0, height: 10.0), blocking: true, color: Gray),
  EnvItem(rect: (x: 650.0, y: 300.0, width: 100.0, height: 10.0), blocking: true, color: Gray),
]
var camera = Camera2D()
camera.target = player.position
camera.offset = (x: screenWidth/2, y: screenHeight/2)
camera.rotation = 0.0
camera.zoom = 1.0
##  Store multiple update camera functions
let cameraUpdaters = [
  updateCameraCenter,
  updateCameraCenterInsideMap,
  updateCameraCenterSmoothFollow,
  updateCameraEvenOutOnLanding,
  updateCameraPlayerBoundsPush,
]
var cameraOption = 0
var cameraDescriptions = ["Follow player center", "Follow player center, but clamp to map edges",
                          "Follow player center; smoothed", "Follow player center horizontally; updateplayer center vertically after landing", "Player push camera on getting too close to screen edge"]
setTargetFPS(60)
## --------------------------------------------------------------------------------------
##  Main game loop
while not windowShouldClose():
  ##  Update
  ## ----------------------------------------------------------------------------------
  var deltaTime: float = getFrameTime()
  updatePlayer(player, envItems, deltaTime)
  camera.zoom += getMouseWheelMove() * 0.05
  if camera.zoom > 3.0:
    camera.zoom = 3.0
  elif camera.zoom < 0.25:
    camera.zoom = 0.25
  if isKeyPressed(R):
    camera.zoom = 1.0
    player.position = (x: 400.0, y: 280.0)
  if isKeyPressed(C):
    cameraOption = (cameraOption + 1) mod cameraUpdaters.len
  cameraUpdaters[cameraOption](camera, player, envItems,
                               deltaTime, screenWidth,
                               screenHeight)
  ## ----------------------------------------------------------------------------------
  ##  Draw
  ## ----------------------------------------------------------------------------------
  beginDrawing()
  clearBackground(Lightgray)
  beginMode2D(camera)
  var i = 0
  while i < envItems.len:
    drawRectangleRec(envItems[i].rect, envItems[i].color)
    inc(i)
  var playerRect = (x: player.position.x - 20.0, y: player.position.y - 40.0, width: 40.0, height: 40.0)
  drawRectangleRec(playerRect, Red)
  endMode2D()
  drawText("Controls:", 20, 20, 10, Black)
  drawText("- Right/Left to move", 40, 40, 10, Darkgray)
  drawText("- Space to jump", 40, 60, 10, Darkgray)
  drawText("- Mouse Wheel to Zoom in-out, R to reset zoom", 40, 80, 10, Darkgray)
  drawText("- C to change camera mode", 40, 100, 10, Darkgray)
  drawText("Current camera mode:", 20, 120, 10, Black)
  drawText(cameraDescriptions[cameraOption], 40, 140, 10, Darkgray)
  endDrawing()

## ----------------------------------------------------------------------------------
##  De-Initialization
## --------------------------------------------------------------------------------------
closeWindow()
##  Close window and OpenGL context
## --------------------------------------------------------------------------------------

proc updatePlayer(player: var Player, envItems: var openArray[EnvItem], delta: float) =
  if isKeyDown(KeyboardKey.Left):
    player.position.x -= PLAYER_HOR_SPD * delta
  if isKeyDown(KeyboardKey.Right):
    player.position.x += PLAYER_JUMP_SPD * delta
  if isKeyDown(Space) and player.canJump:
    player.speed = -PLAYER_JUMP_SPD
    player.canJump = false
  var hitObstacle = 0
  var i = 0
  while i < envItems.len:
    var ei = envItems[i]
    var p = addr(player.position)
    if ei.blocking and ei.rect.x <= p.x and ei.rect.x + ei.rect.width >= p.x and
        ei.rect.y >= p.y and ei.rect.y < p.y + player.speed * delta:
      hitObstacle = 1
      player.speed = 0.0
      p.y = ei.rect.y
    inc(i)
  if hitObstacle == 0:
    player.position.y += player.speed * delta
    player.speed += G * delta
    player.canJump = false
  else:
    player.canJump = true

proc updateCameraCenter(camera: var Camera2D, player: var Player,
                        envItems: var openArray[EnvItem], delta: float,
                        width: int, height: int) =
  camera.offset = (x: width/2, y: height/2)
  camera.target = player.position

proc updateCameraCenterInsideMap(camera: var Camera2D, player: var Player,
                                 envItems: var openArray[EnvItem],
                                 delta: float, width: int, height: int) =
  camera.target = player.position
  camera.offset = (x: width/2, y: height/2)
  var
    minX: float = 1000
    minY: float = 1000
    maxX: float = -1000
    maxY: float = -1000
  var i = 0
  while i < envItems.len:
    var ei = envItems[i]
    minX = min(ei.rect.x, minX)
    maxX = max(ei.rect.x + ei.rect.width, maxX)
    minY = min(ei.rect.y, minY)
    maxY = max(ei.rect.y + ei.rect.height, maxY)
    inc(i)
  let
    maxV = getWorldToScreen2D((x: maxX, y: maxY), camera)
    minV = getWorldToScreen2D((x: minX, y: minY), camera)
  if maxV.x < width:
    camera.offset.x = width - (maxV.x - width div 2)
  if maxV.y < height:
    camera.offset.y = height - (maxV.y - height div 2)
  if minV.x > 0:
    camera.offset.x = width div 2 - minV.x
  if minV.y > 0:
    camera.offset.y = height div 2 - minV.y

proc updateCameraCenterSmoothFollow(camera: var Camera2D, player: var Player,
                                    envItems: var openArray[EnvItem],
                                    delta: float, width: int, height: int) =
  var minSpeed = 30.0
  var minEffectLength = 10.0
  var fractionSpeed = 0.8
  camera.offset = (x: width/2, y: height/2)
  var diff: Vector2 = subtract(player.position, camera.target)
  var length = length(diff)
  if length > minEffectLength:
    var speed = max(fractionSpeed * length, minSpeed)
    camera.target = add(camera.target, scale(diff, speed * delta / length))

var eveningOut = false
var evenOutTarget: float
proc updateCameraEvenOutOnLanding(camera: var Camera2D, player: var Player,
                                  envItems: var openArray[EnvItem],
                                  delta: float, width: int, height: int) =
  var evenOutSpeed = 700.0
  camera.offset = (x: width/2, y: height/2)
  camera.target.x = player.position.x
  if eveningOut:
    if evenOutTarget > camera.target.y:
      camera.target.y += evenOutSpeed * delta
      if camera.target.y > evenOutTarget:
        camera.target.y = evenOutTarget
        eveningOut = false
    else:
      camera.target.y -= evenOutSpeed * delta
      if camera.target.y < evenOutTarget:
        camera.target.y = evenOutTarget
        eveningOut = false
  else:
    if player.canJump and player.speed == 0 and
       player.position.y != camera.target.y:
      eveningOut = true
      evenOutTarget = player.position.y

proc updateCameraPlayerBoundsPush(camera: var Camera2D, player: var Player,
                                  envItems: var openArray[EnvItem],
                                  delta: float, width: int, height: int) =
  var
    bbox = (x: 0.2, y: 0.2)
    bboxWorldMin = getScreenToWorld2D(
      (x: (1 - bbox.x)*0.5f*width, y: (1 - bbox.y)*0.5f*height),
      camera
    )
    bboxWorldMax = getScreenToWorld2D(
      (x: (1 + bbox.x)*0.5f*width, y: (1 + bbox.y)*0.5f*height),
      camera
    )
  camera.offset = (x: (1 - bbox.x)*0.5f * width, y: (1 - bbox.y)*0.5f*height)
  if player.position.x < bboxWorldMin.x:
    camera.target.x = player.position.x
  if player.position.y < bboxWorldMin.y:
    camera.target.y = player.position.y
  if player.position.x > bboxWorldMax.x:
    camera.target.x = bboxWorldMin.x + (player.position.x - bboxWorldMax.x)
  if player.position.y > bboxWorldMax.y:
    camera.target.y = bboxWorldMin.y + (player.position.y - bboxWorldMax.y)
