discard """
  cmd: "nim c -d:nimraylib_now_shared --listCmd $options $file"
  action: "compile"
  joinable: false
  matrix: "; -d:release; --gc:orc -d:release"
  disabled: "win"
"""
import lenientops, math, times, strformat, atomics, system/ansi_c
import ../src/nimraylib_now
from ../src/nimraylib_now/rlgl as rl import nil
import ../examples/shaders/rlights

block audio_module_playing:
  #*******************************************************************************************
  #
  #   raylib [audio] example - Module playing (streaming)
  #
  #   This example has been created using raylib 1.5 (www.raylib.com)
  #   raylib is licensed under an unmodified zlib/libpng license (View raylib.h for details)
  #
  #   Copyright (c) 2016 Ramon Santamaria (@raysan5)
  #   /Converted in 2*20 by Guevara-chan.
  #   Adapted in 2021 by greenfork
  #
  #*******************************************************************************************


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
      circles[i].alpha = 0.0f
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
          circles[i].alpha += circles[i].speed
          circles[i].radius += circles[i].speed*10.0f

          if circles[i].alpha > 1.0f: circles[i].speed *= -1

          if (circles[i].alpha <= 0.0f):
              circles[i].alpha = 0.0f
              circles[i].radius = getRandomValue(10, 40).float
              circles[i].position.x = getRandomValue(circles[i].radius.int32, screenWidth - circles[i].radius.int32).float
              circles[i].position.y = getRandomValue(circles[i].radius.int32, screenHeight - circles[i].radius.int32).float
              circles[i].color = colors[getRandomValue(0, 13)]
              circles[i].speed = (float)getRandomValue(1, 100)/2000.0f
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


block audio_multichannel_sound:
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


block audio_music_stream:
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


block audio_raw_stream:
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
  #   Adapted in 2021 by greenfork
  #
  #*******************************************************************************************


  const MAX_SAMPLES            = 512
  const MAX_SAMPLES_PER_UPDATE = 4096

  #  Initialization
  # --------------------------------------------------------------------------------------
  const screenWidth = 800
  const screenHeight = 450

  initWindow screenWidth, screenHeight, "raylib [audio] example - raw audio streaming"

  initAudioDevice()              #  Initialize audio device

  #  Init raw audio stream (sample rate: 22050, sample size: 16bit-short, channels: 1-mono)
  let stream = initAudioStream(22050, 16, 1)

  #  Buffer for the single cycle waveform we are synthesizing
  var data: array[MAX_SAMPLES, uint16]

  #  Frame buffer, describing the waveform when repeated over the course of a frame
  var writeBuf: array[MAX_SAMPLES_PER_UPDATE, uint16]

  playAudioStream stream         #  Start processing stream buffer (no data loaded currently)

  #  Position read in to determine next frequency
  var mousePosition = Vector2(x: -100.0, y: -100.0)

  #  Cycles per second (hz)
  var frequency = 440.0

  #  Previous value, used to test if sine needs to be rewritten, and to smoothly modulate frequency
  var oldFrequency = 1.0

  #  Cursor to read and copy the samples of the sine wave buffer
  var readCursor = 0

  #  Computed size in samples of the sine wave
  var waveLength = 1

  var position: Vector2

  30.setTargetFPS                 #  Set our game to run at 30 frames-per-second
  # --------------------------------------------------------------------------------------

  #  Main game loop
  while not windowShouldClose():  #  Detect window close button or ESC key
      #  Update
      # ----------------------------------------------------------------------------------

      #  Sample mouse input.
      mousePosition = getMousePosition()

      if isMouseButtonDown(LEFT_BUTTON): frequency = 40.0 + (mousePosition.y).float

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
      if isAudioStreamProcessed(stream):
          #  Synthesize a buffer that is exactly the requested size
          var writeCursor = 0

          while writeCursor < MAX_SAMPLES_PER_UPDATE:
              #  Start by trying to write the whole chunk at once
              var writeLength = MAX_SAMPLES_PER_UPDATE-writeCursor

              #  Limit to the maximum readable size
              let readLength = waveLength-readCursor

              if writeLength > readLength: writeLength = readLength

              #  Write the slice
              echo writeCursor
              copyMem cast[pointer](cast[int](writeBuf.addr)+writeCursor), cast[pointer](cast[int](data.addr)+readCursor),
                   writeLength*sizeof(uint16)

              #  Update cursors and loop audio
              readCursor = (readCursor + writeLength) %% waveLength

              writeCursor += writeLength

          #  Copy finished frame to audio stream
          updateAudioStream stream, writeBuf.addr, MAX_SAMPLES_PER_UPDATE
      # ----------------------------------------------------------------------------------

      #  Draw
      # ----------------------------------------------------------------------------------
      beginDrawing()

      clearBackground RAYWHITE

      drawText textFormat("sine frequency: %i",(int)frequency), getScreenWidth() - 220, 10, 20, RED
      drawText "click mouse button to change frequency", 10, 10, 20, DARKGRAY

      #  Draw the current buffer state proportionate to the screen
      for i in 0..<screenWidth:
          position.x = i.float
          position.y = 250 + 50 * data[i*MAX_SAMPLES div screenWidth].float / 32000
          drawPixelV position, RED

      endDrawing()
      # ----------------------------------------------------------------------------------

  #  De-Initialization
  # --------------------------------------------------------------------------------------
  closeAudioStream stream    #  Close raw audio stream and delete buffers from RAM
  closeAudioDevice()         #  Close audio device (music streaming is automatically stopped)

  closeWindow()              #  Close window and OpenGL context
  # --------------------------------------------------------------------------------------


block core_2d_camera:
  #*******************************************************************************************
  #
  #   raylib [core] example - 2d camera
  #
  #   This example has been created using raylib 1.5 (www.raylib.com)
  #   raylib is licensed under an unmodified zlib/libpng license (View raylib.h for details)
  #
  #   Copyright (c) 2016 Ramon Santamaria (@raysan5)
  #   Converted in 2020 by bones527
  #   Adapted in 2021 by greenfork
  #
  #*******************************************************************************************/


  const
    MaxBuildings = 100
    screenWidth   = 800
    screenHeight  = 450

  initWindow(screenWidth, screenHeight, "Camera 2D")

  var
    player: Rectangle = (x: 400.0, y: 280.0, width: 40.0, height: 40.0)
    buildings:   array[MAX_BUILDINGS, Rectangle]
    buildColors: array[MAX_BUILDINGS, Color]
    spacing = 0

  for i in 0..<MAX_BUILDINGS:
    buildings[i].width  = getRandomValue(50, 200).float
    buildings[i].height = getRandomValue(100, 800).float
    buildings[i].y = screenHeight - 130 - buildings[i].height
    buildings[i].x = -6000 + spacing.float

    spacing += buildings[i].width.int

    buildColors[i] = Color(
      r: getRandomValue(200, 240).uint8,
      g: getRandomValue(200, 240).uint8,
      b: getRandomValue(200, 240).uint8,
      a: 255.uint8
    )
  var camera = Camera2D(
    target: (x: player.x + 20.0, y: player.y + 20.0),
    offset: (x: screenWidth / 2, y: screenHeight / 2),
    rotation: 0.0,
    zoom: 1.0,
  )

  60.setTargetFPS

  while not windowShouldClose():
    # Update
    #----------------------------------------------------------------------------------
    # Player movement
    if isKeyDown(RIGHT):  player.x += 2
    elif isKeyDown(LEFT): player.x -= 2
    # Camera target follows player
    camera.target = (x: player.x + 20.0, y: player.y + 20.0)
    # Camera rotation controls
    if isKeyDown(A):   camera.rotation -= 1
    elif isKeyDown(S): camera.rotation += 1
    # Limit camera rotation to 80 degrees (-40 to 40)
    if camera.rotation > 40:    camera.rotation = 40
    elif camera.rotation < -40: camera.rotation = -40
    # Camera zoom controls
    camera.zoom += getMouseWheelMove().float * 0.05
    if camera.zoom > 3.0:   camera.zoom = 3.0
    elif camera.zoom < 0.1: camera.zoom = 0.1
    # Camera reset (zoom and rotation)
    if isKeyPressed(R):
        camera.zoom     = 1.0
        camera.rotation = 0.0
    #----------------------------------------------------------------------------------
    # Draw
    #----------------------------------------------------------------------------------
    beginDrawing()
    clearBackground Raywhite
    beginMode2D camera
    drawRectangle -6000, 320, 13000, 8000, Darkgray
    for i in 0..<MaxBuildings:
        drawRectangleRec buildings[i], buildColors[i]
    drawRectangleRec player, RED
    drawLine camera.target.x.cint, -screenHeight * 10, camera.target.x.cint, screenHeight * 10, Green
    drawLine -screenWidth * 10, camera.target.y.cint, screenWidth * 10, camera.target.y.cint, Green
    endMode2D()
    drawText "SCREEN AREA", 640, 10, 20, Red
    drawRectangle 0, 0, screenWidth, 5, Red
    drawRectangle 0, 5, 5, screenHeight - 10, Red
    drawRectangle screenWidth - 5, 5, 5, screenHeight - 10, Red
    drawRectangle 0, screenHeight - 5, screenWidth, 5, Red
    drawRectangle 10, 10, 250, 113, fade(Skyblue, 0.5)
    drawRectangleLines 10, 10, 250, 113, Blue
    drawText "Free 2d camera controls:", 20, 20, 10, Black
    drawText "- Right/Left to move Offset", 40, 40, 10, Darkgray
    drawText "- Mouse Wheel to Zoom in-out", 40, 60, 10, Darkgray
    drawText "- A / S to Rotate", 40, 80, 10, Darkgray
    drawText "- R to reset Zoom and Rotation", 40, 100, 10, Darkgray
    endDrawing()
  closeWindow()


block core_2d_camera_platformer:
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
    if isKeyDown(Left):
      player.position.x -= PLAYER_HOR_SPD * delta
    if isKeyDown(Right):
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


block core_3d_camera_first_person:
  #*******************************************************************************************
  #
  #   raylib [core] example - 3d camera first person
  #
  #   This example has been created using raylib 1.3 (www.raylib.com)
  #   raylib is licensed under an unmodified zlib/libpng license (View raylib.h for details)
  #
  #   Copyright (c) 2015 Ramon Santamaria (@raysan5)
  #   /Converted in 2*20 by Guevara-chan.
  #
  #*******************************************************************************************


  const MaxColumns = 20

  #  Initialization
  # --------------------------------------------------------------------------------------
  const screenWidth = 800
  const screenHeight = 450

  initWindow screenWidth, screenHeight, "raylib [core] example - 3d camera first person"

  #  Define the camera to look into our 3d world (position, target, up vector)
  var camera = Camera()
  camera.position = (x: 4.0, y: 2.0, z: 4.0)
  camera.target = (x: 0.0, y: 1.8, z: 0.0)
  camera.up = (x: 0.0, y: 1.0, z: 0.0)
  camera.fovy = 60.0
  camera.projection = Perspective

  #  Generates some random columns
  var
      heights: array[0..MaxColumns, float]
      positions: array[0..MaxColumns, Vector3]
      colors: array[0..MaxColumns, Color]

  for i in 0..<MaxColumns:
      heights[i] = getRandomValue(1, 12).float
      positions[i] = (x: getRandomValue(-15, 15).float, y: heights[i]/2, z: getRandomValue(-15, 15).float)
      colors[i] = Color(r: getRandomValue(20, 255).uint8, g: getRandomValue(10, 55).uint8, b: 30.uint8, a: 255.uint8)

  camera.setCameraMode FirstPerson    #  Set a first person camera mode

  setTargetFPS 60                             #  Set our game to run at 60 frames-per-second
  # --------------------------------------------------------------------------------------

  #  Main game loop
  while not windowShouldClose():              #  Detect window close button or ESC key
      #  Update
      # ----------------------------------------------------------------------------------
      camera.addr.updateCamera                #  Update camera
      # ----------------------------------------------------------------------------------

      #  Draw
      # ----------------------------------------------------------------------------------
      beginDrawing()

      clearBackground RayWhite

      beginMode3D camera

      drawPlane (x: 0.0, y: 0.0, z: 0.0), (x: 32.0, y: 32.0), Lightgray #  Draw ground
      drawCube (x: -16.0, y: 2.5, z: 0.0), 1.0, 5.0, 32.0, Blue               #  Draw a blue wall
      drawCube (x: 16.0, y: 2.5, z: 0.0), 1.0, 5.0, 32.0, Lime                #  Draw a green wall
      drawCube (x: 0.0, y: 2.5, z: 16.0), 32.0, 5.0, 1.0, Gold                #  Draw a yellow wall

      #  Draw some cubes around
      for i in 0..<MaxColumns:
          drawCube positions[i], 2.0, heights[i], 2.0, colors[i]
          drawCubeWires positions[i], 2.0, heights[i], 2.0, Maroon

      endMode3D()

      drawRectangle 10, 10, 220, 70, fade(Skyblue, 0.5)
      drawRectangleLines 10, 10, 220, 70, Blue

      drawText "First person camera default controls:", 20, 20, 10, Black
      drawText "- Move with keys: W, A, S, D", 40, 40, 10, Darkgray
      drawText "- Mouse move to look around", 40, 60, 10, Darkgray

      endDrawing()
      # ----------------------------------------------------------------------------------

  #  De-Initialization
  # --------------------------------------------------------------------------------------
  closeWindow()         #  Close window and OpenGL context
  # --------------------------------------------------------------------------------------


block core_3d_camera_free:
  # ******************************************************************************************
  #
  #    raylib [core] example - Initialize 3d camera free
  #
  #    This example has been created using raylib 1.3 (www.raylib.com)
  #    raylib is licensed under an unmodified zlib/libpng license (View raylib.h for details)
  #
  #    Copyright (c) 2015 Ramon Santamaria (@raysan5)
  #    Converted in 2021 by greenfork
  #
  # ******************************************************************************************


  ##  Initialization
  ## --------------------------------------------------------------------------------------
  var screenWidth = 800
  var screenHeight = 450
  initWindow(screenWidth, screenHeight, "raylib [core] example - 3d camera free")
  ##  Define the camera to look into our 3d world
  var camera = Camera3D()
  camera.position = (10.0, 10.0, 10.0)
  camera.target = (0.0, 0.0, 0.0)      # Camera looking at point
  camera.up = (0.0, 1.0, 0.0)          # Camera up vector (rotation towards target)
  camera.fovy = 45.0
  ##  Camera field-of-view Y
  camera.projection = Perspective
  ##  Camera mode type
  var cubePosition: Vector3 = (0.0, 0.0, 0.0)
  setCameraMode(camera, Free)
  ##  Set a free camera mode
  setTargetFPS(60)
  ##  Set our game to run at 60 frames-per-second
  ## --------------------------------------------------------------------------------------
  ##  Main game loop
  while not windowShouldClose(): ##  Detect window close button or ESC key
    ##  Update
    ## ----------------------------------------------------------------------------------
    updateCamera(addr(camera))
    ##  Update camera
    if isKeyDown(Z):
      camera.target = (0.0, 0.0, 0.0)
    ## ----------------------------------------------------------------------------------
    ##  Draw
    ## ----------------------------------------------------------------------------------
    beginDrawing()
    clearBackground(Raywhite)
    beginMode3D(camera)
    drawCube(cubePosition, 2.0, 2.0, 2.0, Red)
    drawCubeWires(cubePosition, 2.0, 2.0, 2.0, Maroon)
    drawGrid(10, 1.0)
    endMode3D()
    drawRectangle(10, 10, 320, 133, fade(Skyblue, 0.5))
    drawRectangleLines(10, 10, 320, 133, Blue)
    drawText("Free camera default controls:", 20, 20, 10, Black)
    drawText("- Mouse Wheel to Zoom in-out", 40, 40, 10, Darkgray)
    drawText("- Mouse Wheel Pressed to Pan", 40, 60, 10, Darkgray)
    drawText("- Alt + Mouse Wheel Pressed to Rotate", 40, 80, 10, Darkgray)
    drawText("- Alt + Ctrl + Mouse Wheel Pressed for Smooth Zoom", 40, 100, 10,
             Darkgray)
    drawText("- Z to zoom to (0, 0, 0)", 40, 120, 10, Darkgray)
    endDrawing()
  ## ----------------------------------------------------------------------------------
  ##  De-Initialization
  ## --------------------------------------------------------------------------------------
  closeWindow()
  ##  Close window and OpenGL context
  ## --------------------------------------------------------------------------------------


block core_3d_camera_mode:
  # ******************************************************************************************
  #
  #    raylib [core] example - Initialize 3d camera mode
  #
  #    This example has been created using raylib 1.0 (www.raylib.com)
  #    raylib is licensed under an unmodified zlib/libpng license (View raylib.h for details)
  #
  #    Copyright (c) 2014 Ramon Santamaria (@raysan5)
  #    Converted in 2021 by greenfork
  #
  # ******************************************************************************************


  ##  Initialization
  ## --------------------------------------------------------------------------------------
  var screenWidth = 800
  var screenHeight = 450
  initWindow(screenWidth, screenHeight, "raylib [core] example - 3d camera mode")
  ##  Define the camera to look into our 3d world
  var camera = Camera3D()
  camera.position = (0.0, 10.0, 10.0)   # Camera position
  camera.target = (0.0, 0.0, 0.0)       # Camera looking at point
  camera.up = (0.0, 1.0, 0.0)           # Camera up vector (rotation towards target)
  camera.fovy = 45.0
  ##  Camera field-of-view Y
  camera.projection = Perspective
  ##  Camera mode type
  var cubePosition: Vector3 = (0.0, 0.0, 0.0)
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
    beginMode3D(camera)
    drawCube(cubePosition, 2.0, 2.0, 2.0, Red)
    drawCubeWires(cubePosition, 2.0, 2.0, 2.0, Maroon)
    drawGrid(10, 1.0)
    endMode3D()
    drawText("Welcome to the third dimension!", 10, 40, 20, Darkgray)
    drawFPS(10, 10)
    endDrawing()
  ## ----------------------------------------------------------------------------------
  ##  De-Initialization
  ## --------------------------------------------------------------------------------------
  closeWindow()
  ##  Close window and OpenGL context
  ## --------------------------------------------------------------------------------------


block core_3d_picking:
  #*******************************************************************************************
  #
  #   raylib [core] example - Picking in 3d mode
  #
  #   This example has been created using raylib 1.3 (www.raylib.com)
  #   raylib is licensed under an unmodified zlib/libpng license (View raylib.h for details)
  #
  #   Copyright (c) 2015 Ramon Santamaria (@raysan5)
  #   /Converted in 2*20 by Guevara-chan.
  #   Adapted in 2021 by greenfork
  #
  #*******************************************************************************************


  #  Initialization
  # --------------------------------------------------------------------------------------
  const screenWidth = 800
  const screenHeight = 450

  initWindow(screenWidth, screenHeight, "raylib [core] example - 3d picking")

  #  Define the camera to look into our 3d world
  var camera = Camera()
  camera.position = (x: 10.0, y: 10.0, z: 10.0)  #  Camera position
  camera.target = (x: 0.0, y: 0.0, z: 0.0)       #  Camera looking at point
  camera.up = (x: 0.0, y: 1.0, z: 0.0)           #  Camera up vector (rotation towards target)
  camera.fovy = 45.0                             #  Camera field-of-view Y
  camera.projection = Perspective                    #  Camera mode type

  var
    cubePosition = (x: 0.0, y: 1.0, z: 0.0)
    cubeSize = (x: 2.0, y: 2.0, z: 2.0)
    ray = Ray()                                  #  Picking line ray
    collision = false

  camera.setCameraMode Free                      #  Set a free camera mode

  setTargetFPS(60)                               #  Set our game to run at 60 frames-per-second

  #  Main game loop
  while not windowShouldClose():      #  Detect window close button or ESC key
    #  Update
    # ----------------------------------------------------------------------------------
    camera.addr.updateCamera        #  Update camera

    if MouseButton.LeftButton.isMouseButtonPressed():
      if not collision:
        ray = getMouseRay(getMousePosition(), camera)

        #  Check collision between ray and box
        collision = checkCollisionRayBox(
          ray,
          BoundingBox(
            min: (x: cubePosition.x - cubeSize.x/2, y: cubePosition.y - cubeSize.y/2, z: cubePosition.z - cubeSize.z/2),
            max: (x: cubePosition.x + cubeSize.x/2, y: cubePosition.y + cubeSize.y/2, z: cubePosition.z + cubeSize.z/2)
          )
        )
      else: collision = false
    # ----------------------------------------------------------------------------------

    #  Draw
    # ----------------------------------------------------------------------------------
    beginDrawing()

    clearBackground Raywhite

    beginMode3D camera

    if collision:
      drawCube(cubePosition, cubeSize.x, cubeSize.y, cubeSize.z, RED)
      drawCubeWires(cubePosition, cubeSize.x, cubeSize.y, cubeSize.z, MAROON)

      drawCubeWires(cubePosition, cubeSize.x + 0.2, cubeSize.y + 0.2, cubeSize.z + 0.2, GREEN)
    else:
      drawCube(cubePosition, cubeSize.x, cubeSize.y, cubeSize.z, GRAY)
      drawCubeWires(cubePosition, cubeSize.x, cubeSize.y, cubeSize.z, DARKGRAY)

    drawRay(ray, MAROON)
    drawGrid(10, 1.0)

    endMode3D()

    drawText("Try selecting the box with mouse!", 240, 10, 20, DARKGRAY)

    if collision:
      drawText("BOX SELECTED", (screenWidth - measureText("BOX SELECTED", 30)) div 2,
        (screenHeight * 0.1).cint, 30, GREEN)

    drawFPS(10, 10)

    endDrawing()
    # ----------------------------------------------------------------------------------

  #  De-Initialization
  # --------------------------------------------------------------------------------------
  closeWindow()         #  Close window and OpenGL context
  # --------------------------------------------------------------------------------------


block core_basic_window:
  # ******************************************************************************************
  #
  #    raylib [core] example - Basic window
  #
  #    Welcome to raylib!
  #
  #    To test examples, just press F6 and execute raylib_compile_execute script
  #    Note that compiled executable is placed in the same folder as .c file
  #
  #    You can find all basic examples on C:\raylib\raylib\examples folder or
  #    raylib official webpage: www.raylib.com
  #
  #    Enjoy using raylib. :)
  #
  #    This example has been created using raylib 1.0 (www.raylib.com)
  #    raylib is licensed under an unmodified zlib/libpng license (View raylib.h for details)
  #
  #    Copyright (c) 2013-2016 Ramon Santamaria (@raysan5)
  #    Converted in 2021 by greenfork
  #
  # ******************************************************************************************


  ##  Initialization
  ## --------------------------------------------------------------------------------------
  var screenWidth: int32 = 800
  var screenHeight: int32 = 450
  initWindow(screenWidth, screenHeight, "raylib [core] example - basic window")
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
    drawText("Congrats! You created your first window!", 190, 200, 20, Lightgray)
    endDrawing()
    ## ----------------------------------------------------------------------------------
  ##  De-Initialization
  ## --------------------------------------------------------------------------------------
  closeWindow()
  ##  Close window and OpenGL context
  ## --------------------------------------------------------------------------------------


block core_custom_logging:
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


block core_input_gamepad:
  #[
  *
  *   raylib [core] example - Gamepad input
  *
  *   NOTE: This example requires a Gamepad connected to the system
  *         raylib is configured to work with the following gamepads:
  *                - Xbox 360 Controller (Xbox 360, Xbox One)
  *                - PLAYSTATION(R)3 Controller
  *         Check raylib.h for buttons configuration
  *
  *   This example has been created using raylib 2.5 (www.raylib.com)
  *   raylib is licensed under an unmodified zlib/libpng license (View raylib.h for details)
  *
  *   Copyright (c) 2013-2019 Ramon Santamaria (@raysan5)
  *   Adapted in 2021 by jseb
  *
  ********************************************************************************************]#


  # NOTE: Gamepad name ID depends on drivers and OS
  when defined(PLATFORM_RPI):
    const XBOX360_NAME_ID = "Microsoft X-Box 360 pad"
  else:
    const XBOX360_NAME_ID = "Xbox 360 Controller"

  const
    PS3_NAME_ID = "PLAYSTATION(R)3 Controller"
    XBOX360_LEGACY_NAME_ID = "Xbox Controller"
    screenWidth = 800
    screenHeight = 450

  var texPs3Pad,texXboxPad:Texture2D


  proc init() =
    setConfigFlags(MSAA_4X_HINT)  # Set MSAA 4X hint before windows creation

    initWindow(screenWidth, screenHeight, "raylib [core] example - gamepad input")

    texPs3Pad = loadTexture("resources/ps3.png")
    texXboxPad = loadTexture("resources/xbox.png")

    setTargetFPS(60)

  proc padDrawXbox
  proc padDrawPsx


  proc main() =
    while not windowShouldClose():
      beginDrawing:
        clearBackground(RAYWHITE)
        if isGamepadAvailable(0):
          let gamepadName = getGamePadName(0)
          drawText("GP1: {gamepadName}".fmt, 10, 10, 10, BLACK);

          case $gamepadName:
            of XBOX360_NAME_ID, XBOX360_LEGACY_NAME_ID:
              padDrawXbox()
            of PS3_NAME_ID:
              padDrawPsx()
            else:
              # a pad has been detected, but not identified. Fallback is to show PSX pad.
              drawText("GP1: Unidentified (fallback to PSX pad)", 10, 25, 10, BLUE);
              padDrawPsx()

          drawText("DETECTED AXIS: {getGamepadAxisCount(0)}".fmt, 10, 50, 10, MAROON)
          for i in 0..getGamepadAxisCount(0):
            drawText("AXIS {i} : {getGamepadAxisMovement(0, i)}".fmt, 20, 70 + 20*i, 10, DARKGRAY)

          if (getGamepadButtonPressed() != -1):
            drawText("DETECTED BUTTON: {getGamepadButtonPressed()}".fmt, 10, 430, 10, RED)
          else:
            drawText("DETECTED BUTTON: NONE", 10, 430, 10, GRAY)

        else:
          drawText("GP1: NOT DETECTED", 10, 10, 10, GRAY);
          drawTexture(texXboxPad, 0, 0, LIGHTGRAY);


  proc finish() =
    unloadTexture(texPs3Pad)
    unloadTexture(texXboxPad)
    closeWindow()


  proc padDrawXbox() =
    drawTexture(texXboxPad, 0, 0, DARKGRAY)
    # draw buttons: xbox home
    if (isGamepadButtonDown(0, MIDDLE)): drawCircle(394, 89, 19, YELLOW)

    # draw buttons: basic
    if (isGamepadButtonDown(0, MIDDLE_RIGHT)): drawCircle(436, 150, 9, YELLOW)
    if (isGamepadButtonDown(0, MIDDLE_LEFT)): drawCircle(352, 150, 9, YELLOW)
    if (isGamepadButtonDown(0, RIGHT_FACE_LEFT)): drawCircle(501, 151, 15, BLUE)
    if (isGamepadButtonDown(0, RIGHT_FACE_DOWN)): drawCircle(536, 187, 15, LIME)
    if (isGamepadButtonDown(0, RIGHT_FACE_RIGHT)): drawCircle(572, 151, 15, MAROON)
    if (isGamepadButtonDown(0, RIGHT_FACE_UP)): drawCircle(536, 115, 15, GOLD)

    # draw buttons: d-pad
    drawRectangle(317, 202, 19, 71, BLACK)
    drawRectangle(293, 228, 69, 19, BLACK)
    if (isGamepadButtonDown(0, LEFT_FACE_UP)): drawRectangle(317, 202, 19, 26, YELLOW)
    if (isGamepadButtonDown(0, LEFT_FACE_DOWN)): drawRectangle(317, 202 + 45, 19, 26, YELLOW)
    if (isGamepadButtonDown(0, LEFT_FACE_LEFT)): drawRectangle(292, 228, 25, 19, YELLOW)
    if (isGamepadButtonDown(0, LEFT_FACE_RIGHT)): drawRectangle(292 + 44, 228, 26, 19, YELLOW)

    # draw buttons: left-right back
    if (isGamepadButtonDown(0, LEFT_TRIGGER_1)): drawCircle(259, 61, 20, YELLOW)
    if (isGamepadButtonDown(0, RIGHT_TRIGGER_1)): drawCircle(536, 61, 20, YELLOW)

    # draw axis: left joystick
    drawCircle(259, 152, 39, BLACK)
    drawCircle(259, 152, 34, LIGHTGRAY)
    drawCircle(259 + ((int)getGamepadAxisMovement(0, LEFT_X)*20),
               152 + ((int)getGamepadAxisMovement(0, LEFT_Y)*20), 25, BLACK)

    # draw axis: right joystick
    drawCircle(461, 237, 38, BLACK)
    drawCircle(461, 237, 33, LIGHTGRAY)
    drawCircle(461 + ((int)getGamepadAxisMovement(0, RIGHT_X)*20),
               237 + ((int)getGamepadAxisMovement(0, RIGHT_Y)*20), 25, BLACK)

    # draw axis: left-right triggers
    drawRectangle(170, 30, 15, 70, GRAY)
    drawRectangle(604, 30, 15, 70, GRAY)
    drawRectangle(170, 30, 15, (((1 + getGamepadAxisMovement(0, LEFT_TRIGGER))/2)*70).int, YELLOW)
    drawRectangle(604, 30, 15, (((1 + getGamepadAxisMovement(0, RIGHT_TRIGGER))/2)*70).int, YELLOW)


  proc padDrawPsx() =
    drawTexture(texPs3Pad, 0, 0, DARKGRAY)
    # Draw buttons: ps
    if (isGamepadButtonDown(0, MIDDLE)): drawCircle(396, 222, 13, YELLOW)

    # Draw buttons: basic
    if (isGamepadButtonDown(0, MIDDLE_LEFT)): drawRectangle(328, 170, 32, 13, YELLOW)
    if (isGamepadButtonDown(0, MIDDLE_RIGHT)): drawTriangle(Vector2(x:436, y:168 ), Vector2(x:436, y:185), Vector2(x:464, y:177 ), YELLOW)
    if (isGamepadButtonDown(0, RIGHT_FACE_UP)): drawCircle(557, 144, 13, LIME)
    if (isGamepadButtonDown(0, RIGHT_FACE_RIGHT)): drawCircle(586, 173, 13, YELLOW)
    if (isGamepadButtonDown(0, RIGHT_FACE_DOWN)): drawCircle(557, 203, 13, VIOLET)
    if (isGamepadButtonDown(0, RIGHT_FACE_LEFT)): drawCircle(527, 173, 13, PINK)

    # draw buttons: d-pad
    drawRectangle(225, 132, 24, 84, BLACK)
    drawRectangle(195, 161, 84, 25, BLACK)
    if (isGamepadButtonDown(0, LEFT_FACE_UP)): drawRectangle(225, 132, 24, 29, YELLOW)
    if (isGamepadButtonDown(0, LEFT_FACE_DOWN)): drawRectangle(225, 132 + 54, 24, 30, YELLOW)
    if (isGamepadButtonDown(0, LEFT_FACE_LEFT)): drawRectangle(195, 161, 30, 25, YELLOW)
    if (isGamepadButtonDown(0, LEFT_FACE_RIGHT)): drawRectangle(195 + 54, 161, 30, 25, YELLOW)

    # draw buttons: left-right back buttons
    if (isGamepadButtonDown(0, LEFT_TRIGGER_1)): drawCircle(239, 82, 20, YELLOW)
    if (isGamepadButtonDown(0, RIGHT_TRIGGER_1)): drawCircle(557, 82, 20, YELLOW)

    # draw axis: left joystick
    drawCircle(319, 255, 35, BLACK)
    drawCircle(319, 255, 31, LIGHTGRAY)
    drawCircle(319 + ((int)getGamepadAxisMovement(0, LEFT_X) * 20),
               255 + ((int)getGamepadAxisMovement(0, LEFT_Y) * 20), 25, BLACK)

    # draw axis: right joystick
    drawCircle(475, 255, 35, BLACK)
    drawCircle(475, 255, 31, LIGHTGRAY)
    drawCircle(475 + ((int)getGamepadAxisMovement(0, RIGHT_X)*20),
               255 + ((int)getGamepadAxisMovement(0, RIGHT_Y)*20), 25, BLACK)

    # draw axis: left-right triggers
    drawRectangle(169, 48, 15, 70, GRAY)
    drawRectangle(611, 48, 15, 70, GRAY)
    drawRectangle(169, 48, 15, (((1 - getGamepadAxisMovement(0, LEFT_TRIGGER)) / 2) * 70).int, YELLOW)
    drawRectangle(611, 48, 15, (((1 - getGamepadAxisMovement(0, RIGHT_TRIGGER)) / 2) * 70).int, YELLOW)


  init()
  main()
  finish()


block core_input_gestures:
  # ******************************************************************************************
  #
  #    raylib [core] example - Input Gestures Detection
  #
  #    This example has been created using raylib 1.4 (www.raylib.com)
  #    raylib is licensed under an unmodified zlib/libpng license (View raylib.h for details)
  #
  #    Copyright (c) 2016 Ramon Santamaria (@raysan5)
  #    Converted in 2021 by greenfork
  #
  # ******************************************************************************************


  const
    MAX_GESTURE_STRINGS = 20

  ##  Initialization
  ## --------------------------------------------------------------------------------------
  var screenWidth = 800
  var screenHeight = 450
  initWindow(screenWidth, screenHeight, "raylib [core] example - input gestures")
  var touchPosition: Vector2 = (0.0, 0.0)
  var touchArea: Rectangle = (220.0, 10.0, (float)screenWidth - 230, (float)screenHeight - 20)
  var gesturesCount = 0
  var gestureStrings: array[MaxGestureStrings, cstring]
  var currentGesture = Gestures.None
  var lastGesture = Gestures.None
  ## SetGesturesEnabled(0b0000000000001001);   // Enable only some gestures to be detected
  setTargetFPS(60)
  ##  Set our game to run at 60 frames-per-second
  ## --------------------------------------------------------------------------------------
  ##  Main game loop
  while not windowShouldClose(): ##  Detect window close button or ESC key
    ##  Update
    ## ----------------------------------------------------------------------------------
    lastGesture = currentGesture
    currentGesture = getGestureDetected().Gestures
    touchPosition = getTouchPosition(0)
    if checkCollisionPointRec(touchPosition, touchArea) and
        (currentGesture != Gestures.None):
      if currentGesture != lastGesture:
        ##  Store gesture string
        case currentGesture
        of Tap:
          gestureStrings[gesturesCount] = "GESTURE TAP"
        of Doubletap:
          gestureStrings[gesturesCount] = "GESTURE DOUBLETAP"
        of Hold:
          gestureStrings[gesturesCount] = "GESTURE HOLD"
        of Drag:
          gestureStrings[gesturesCount] = "GESTURE DRAG"
        of SwipeRight:
          gestureStrings[gesturesCount] = "GESTURE SWIPE RIGHT"
        of SwipeLeft:
          gestureStrings[gesturesCount] = "GESTURE SWIPE LEFT"
        of SwipeUp:
          gestureStrings[gesturesCount] = "GESTURE SWIPE UP"
        of SwipeDown:
          gestureStrings[gesturesCount] = "GESTURE SWIPE DOWN"
        of PinchIn:
          gestureStrings[gesturesCount] = "GESTURE PINCH IN"
        of PinchOut:
          gestureStrings[gesturesCount] = "GESTURE PINCH OUT"
        else:
          discard
        inc(gesturesCount)
        ##  Reset gestures strings
        if gesturesCount >= MAX_GESTURE_STRINGS:
          var i = 0
          while i < MAX_GESTURE_STRINGS:
            gestureStrings[i] = "\x00"
            inc(i)
          gesturesCount = 0
    beginDrawing()
    clearBackground(Raywhite)
    drawRectangleRec(touchArea, Gray)
    drawRectangle(225, 15, screenWidth - 240, screenHeight - 30, Raywhite)
    drawText("GESTURES TEST AREA", screenWidth - 270, screenHeight - 40, 20,
             fade(Gray, 0.5))
    var i = 0
    while i < gesturesCount:
      if i mod 2 == 0:
        drawRectangle(10, 30 + 20 * i, 200, 20, fade(Lightgray, 0.5))
      else:
        drawRectangle(10, 30 + 20 * i, 200, 20, fade(Lightgray, 0.3))
      if i < gesturesCount - 1:
        drawText(gestureStrings[i], 35, 36 + 20 * i, 10, Darkgray)
      else:
        drawText(gestureStrings[i], 35, 36 + 20 * i, 10, Maroon)
      inc(i)
    drawRectangleLines(10, 29, 200, screenHeight - 50, Gray)
    drawText("DETECTED GESTURES", 50, 15, 10, Gray)
    if currentGesture != Gestures.None:
      drawCircleV(touchPosition, 30, Maroon)
    endDrawing()
  ## ----------------------------------------------------------------------------------
  ##  De-Initialization
  ## --------------------------------------------------------------------------------------
  closeWindow()
  ##  Close window and OpenGL context
  ## --------------------------------------------------------------------------------------


block core_input_keys:
  #*******************************************************************************************
  #
  #   raylib [core] example - Keyboard input
  #
  #   This example has been created using raylib 1.0 (www.raylib.com)
  #   raylib is licensed under an unmodified zlib/libpng license (View raylib.h for details)
  #
  #   Copyright (c) 2014 Ramon Santamaria (@raysan5)
  #   /Converted in 2*20 by Guevara-chan.
  #   Adapted in 2021 by greenfork
  #
  #*******************************************************************************************

  # Initialization
  #--------------------------------------------------------------------------------------
  const screenWidth = 800
  const screenHeight = 450

  initWindow screenWidth, screenHeight, "raylib [core] example - keyboard input"

  var ballPosition: Vector2 = (x: screenWidth/2, y: screenHeight/2)

  60.setTargetFPS                   # Set our game to run at 60 frames-per-second
  #--------------------------------------------------------------------------------------

  # Main game loop
  while not windowShouldClose():    # Detect window close button or ESC key
    #  Update
    # ----------------------------------------------------------------------------------
    if isKeyDown(Right): ballPosition.x += 2.0
    if isKeyDown(Left):  ballPosition.x -= 2.0
    if isKeyDown(Up):    ballPosition.y -= 2.0
    if isKeyDown(Down):  ballPosition.y += 2.0
    # ----------------------------------------------------------------------------------

    #  Draw
    # ----------------------------------------------------------------------------------
    beginDrawing()
    clearBackground RAYWHITE

    drawText "move the ball with arrow keys", 10, 10, 20, DARKGRAY

    drawCircleV ballPosition, 50, MAROON

    endDrawing()
    # ----------------------------------------------------------------------------------
  # De-Initialization
  # --------------------------------------------------------------------------------------
  closeWindow()        #  Close window and OpenGL context
  # --------------------------------------------------------------------------------------


block core_input_mouse:
  # ******************************************************************************************
  #
  #    raylib [core] example - Mouse input
  #
  #    This example has been created using raylib 1.0 (www.raylib.com)
  #    raylib is licensed under an unmodified zlib/libpng license (View raylib.h for details)
  #
  #    Copyright (c) 2014 Ramon Santamaria (@raysan5)
  #    Converted in 2021 by greenfork
  #
  # ******************************************************************************************


  ##  Initialization
  ## --------------------------------------------------------------------------------------
  var screenWidth: int32 = 800
  var screenHeight: int32 = 450
  initWindow(screenWidth, screenHeight, "raylib [core] example - mouse input")
  var ballPosition: Vector2 = (-100.0, -100.0)
  var ballColor: Color = Darkblue
  setTargetFPS(60)
  ##  Set our game to run at 60 frames-per-second
  ## ---------------------------------------------------------------------------------------
  ##  Main game loop
  while not windowShouldClose(): ##  Detect window close button or ESC key
    ##  Update
    ## ----------------------------------------------------------------------------------
    ballPosition = getMousePosition()
    if isMouseButtonPressed(LeftButton):
      ballColor = Maroon
    elif isMouseButtonPressed(MiddleButton):
      ballColor = Lime
    elif isMouseButtonPressed(RightButton):
      ballColor = Darkblue
    ## ----------------------------------------------------------------------------------
    ##  Draw
    ## ----------------------------------------------------------------------------------
    beginDrawing()
    clearBackground(Raywhite)
    drawCircleV(ballPosition, 40, ballColor)
    drawText("move ball with mouse and click mouse button to change color", 10,
             10, 20, Darkgray)
    endDrawing()
  ## ----------------------------------------------------------------------------------
  ##  De-Initialization
  ## --------------------------------------------------------------------------------------
  closeWindow()
  ##  Close window and OpenGL context
  ## --------------------------------------------------------------------------------------


block core_input_mouse_wheel:
  # ******************************************************************************************
  #
  #    raylib [core] examples - Mouse wheel input
  #
  #    This test has been created using raylib 1.1 (www.raylib.com)
  #    raylib is licensed under an unmodified zlib/libpng license (View raylib.h for details)
  #
  #    Copyright (c) 2014 Ramon Santamaria (@raysan5)
  #    Converted in 2021 by greenfork
  #
  # ******************************************************************************************


  ##  Initialization
  ## --------------------------------------------------------------------------------------
  var screenWidth: int32 = 800
  var screenHeight: int32 = 450
  initWindow(screenWidth, screenHeight,
             "raylib [core] example - input mouse wheel")
  var boxPositionY: int32 = screenHeight div 2 - 40
  var scrollSpeed: int32 = 4
  ##  Scrolling speed in pixels
  setTargetFPS(60)
  ##  Set our game to run at 60 frames-per-second
  ## --------------------------------------------------------------------------------------
  ##  Main game loop
  while not windowShouldClose(): ##  Detect window close button or ESC key
    ##  Update
    ## ----------------------------------------------------------------------------------
    inc(boxPositionY, (getMouseWheelMove().int32 * scrollSpeed))
    ## ----------------------------------------------------------------------------------
    ##  Draw
    ## ----------------------------------------------------------------------------------
    beginDrawing()
    clearBackground(Raywhite)
    drawRectangle(screenWidth div 2 - 40, boxPositionY, 80, 80, Maroon)
    drawText("Use mouse wheel to move the cube up and down!", 10, 10, 20, Gray)
    drawText(textFormat("Box position Y: %03i", boxPositionY), 10, 40, 20, Lightgray)
    endDrawing()
  ## ----------------------------------------------------------------------------------
  ##  De-Initialization
  ## --------------------------------------------------------------------------------------
  closeWindow()
  ##  Close window and OpenGL context
  ## --------------------------------------------------------------------------------------


block core_loading_thread:
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


block core_quat_conversion:
  # ******************************************************************************************
  #
  #    raylib [core] example - quat conversions
  #
  #    Generally you should really stick to eulers OR quats...
  #    This tests that various conversions are equivalent.
  #
  #    This example has been created using raylib 3.5 (www.raylib.com)
  #    raylib is licensed under an unmodified zlib/libpng license (View raylib.h for details)
  #
  #    Example contributed by Chris Camacho (@chriscamacho) and reviewed by Ramon Santamaria (@raysan5)
  #
  #    Copyright (c) 2020 Chris Camacho (@chriscamacho) and Ramon Santamaria (@raysan5)
  #    Converted in 2021 by greenfork
  #
  # ******************************************************************************************


  ##  Initialization
  ## --------------------------------------------------------------------------------------
  var screenWidth = 800
  var screenHeight = 450
  initWindow(screenWidth, screenHeight, "raylib [core] example - quat conversions")
  var camera = Camera3D()
  camera.position = (0.0, 10.0, 10.0)  # Camera position
  camera.target = (0.0, 0.0, 0.0)      # Camera looking at point
  camera.up = (0.0, 1.0, 0.0)          # Camera up vector (rotation towards target)
  camera.fovy = 45.0
  ##  Camera field-of-view Y
  camera.projection = Perspective
  ##  Camera mode type
  var mesh: Mesh = genMeshCylinder(0.2, 1.0, 32)
  var model: Model = loadModelFromMesh(mesh)
  ##  Some required variables
  var q1: Quaternion
  var
    m1: Matrix
    m2: Matrix
    m3: Matrix
    m4: Matrix
  var
    v1: Vector3
    v2: Vector3
  setTargetFPS(60)
  ##  Set our game to run at 60 frames-per-second
  ## --------------------------------------------------------------------------------------
  ##  Main game loop
  while not windowShouldClose(): ##  Detect window close button or ESC key
    ##  Update
    ## --------------------------------------------------------------------------------------
    if not isKeyDown(Space):
      v1.x += 0.01
      v1.y += 0.03
      v1.z += 0.05
    if v1.x > PI * 2:
      v1.x -= PI * 2
    if v1.y > PI * 2:
      v1.y -= PI * 2
    if v1.z > PI * 2:
      v1.z -= PI * 2
    q1 = fromEuler(v1.x, v1.y, v1.z)
    m1 = rotateZYX(v1)
    m2 = toMatrix(q1)
    q1 = fromMatrix(m1)
    m3 = toMatrix(q1)
    v2 = toEuler(q1)
    v2.x = degToRad v2.x
    v2.y = degToRad v2.y
    v2.z = degToRad v2.z
    m4 = rotateZYX(v2)
    ## --------------------------------------------------------------------------------------
    ##  Draw
    ## ----------------------------------------------------------------------------------
    beginDrawing:
      clearBackground(Raywhite)

      beginMode3D(camera):
        model.transform = m1
        drawModel(model, (-1.0, 0.0, 0.0), 1.0, Red)
        model.transform = m2
        drawModel(model, (1.0, 0.0, 0.0), 1.0, Red)
        model.transform = m3
        drawModel(model, (0.0, 0.0, 0.0), 1.0, Red)
        model.transform = m4
        drawModel(model, (0.0, 0.0, -1.0), 1.0, Red)
        drawGrid(10, 1.0)

      if v2.x < 0:
        v2.x += PI * 2
      if v2.y < 0:
        v2.y += PI * 2
      if v2.z < 0:
        v2.z += PI * 2
      var
        cx: Color = Black
        cy: Color =  Black
        cz: Color =   Black
      if v1.x == v2.x:
        cx = Green
      if v1.y == v2.y:
        cy = Green
      if v1.z == v2.z:
        cz = Green
      drawText(textFormat("%2.3f", v1.x), 20, 20, 20, cx)
      drawText(textFormat("%2.3f", v1.y), 20, 40, 20, cy)
      drawText(textFormat("%2.3f", v1.z), 20, 60, 20, cz)
      drawText(textFormat("%2.3f", v2.x), 200, 20, 20, cx)
      drawText(textFormat("%2.3f", v2.y), 200, 40, 20, cy)
      drawText(textFormat("%2.3f", v2.z), 200, 60, 20, cz)
  ## ----------------------------------------------------------------------------------
  ##  De-Initialization
  ## --------------------------------------------------------------------------------------
  unloadModel(model)
  ##  Unload model data (mesh and materials)
  closeWindow()
  ##  Close window and OpenGL context
  ## --------------------------------------------------------------------------------------


block core_random_values:
  # ******************************************************************************************
  #
  #    raylib [core] example - Generate random values
  #
  #    This example has been created using raylib 1.1 (www.raylib.com)
  #    raylib is licensed under an unmodified zlib/libpng license (View raylib.h for details)
  #
  #    Copyright (c) 2014 Ramon Santamaria (@raysan5)
  #    Converted in 2021 by greenfork
  #
  # ******************************************************************************************


  ##  Initialization
  ## --------------------------------------------------------------------------------------
  var screenWidth: int32 = 800
  var screenHeight: int32 = 450
  initWindow(screenWidth, screenHeight,
             "raylib [core] example - generate random values")
  var framesCounter: int32 = 0 ##  Variable used to count frames
  var randValue: int32 = getRandomValue(-8, 5) ##  Get a random integer number between -8 and 5 (both included)
  setTargetFPS(60) ##  Set our game to run at 60 frames-per-second
  ## --------------------------------------------------------------------------------------
  ##  Main game loop
  while not windowShouldClose(): ##  Detect window close button or ESC key
    ##  Update
    ## ----------------------------------------------------------------------------------
    inc(framesCounter)
    ##  Every two seconds (120 frames) a new random value is generated
    if ((framesCounter div 120) mod 2) == 1:
      randValue = getRandomValue(-8, 5)
      framesCounter = 0
    beginDrawing()
    clearBackground(Raywhite)
    drawText("Every 2 seconds a new random value is generated:", 130, 100, 20,
             Maroon)
    drawText(textFormat("%i", randValue), 360, 180, 80, Lightgray)
    endDrawing()
  ## ----------------------------------------------------------------------------------
  ##  De-Initialization
  ## --------------------------------------------------------------------------------------
  closeWindow()
  ##  Close window and OpenGL context
  ## --------------------------------------------------------------------------------------


block core_scissor_test:
  # ******************************************************************************************
  #
  #    raylib [core] example - Scissor test
  #
  #    This example has been created using raylib 2.5 (www.raylib.com)
  #    raylib is licensed under an unmodified zlib/libpng license (View raylib.h for details)
  #
  #    Example contributed by Chris Dill (@MysteriousSpace) and reviewed by Ramon Santamaria (@raysan5)
  #
  #    Copyright (c) 2019 Chris Dill (@MysteriousSpace)
  #    Converted in 2021 by greenfork
  #
  # ******************************************************************************************


  ##  Initialization
  ## --------------------------------------------------------------------------------------
  var screenWidth = 800
  var screenHeight = 450
  initWindow(screenWidth, screenHeight, "raylib [core] example - scissor test")
  var scissorArea: Rectangle = (0.0, 0.0, 300.0, 300.0)
  var scissorMode: bool = true
  setTargetFPS(60)
  ##  Set our game to run at 60 frames-per-second
  ## --------------------------------------------------------------------------------------
  ##  Main game loop
  while not windowShouldClose(): ##  Detect window close button or ESC key
    ##  Update
    ## ----------------------------------------------------------------------------------
    if isKeyPressed(S):
      scissorMode = not scissorMode
    scissorArea.x = getMouseX().float - scissorArea.width / 2
    scissorArea.y = getMouseY().float - scissorArea.height / 2
    ## ----------------------------------------------------------------------------------
    ##  Draw
    ## ----------------------------------------------------------------------------------
    beginDrawing()
    clearBackground(Raywhite)
    if scissorMode:
      beginScissorMode(scissorArea.x.cint, scissorArea.y.cint, scissorArea.width.cint,
                       scissorArea.height.cint)
    drawRectangle(0, 0, getScreenWidth(), getScreenHeight(), Red)
    drawText("Move the mouse around to reveal this text!", 190, 200, 20, Lightgray)
    if scissorMode:
      endScissorMode()
    drawRectangleLinesEx(scissorArea, 1, Black)
    drawText("Press S to toggle scissor test", 10, 10, 20, Black)
    endDrawing()
  ## ----------------------------------------------------------------------------------
  ##  De-Initialization
  ## --------------------------------------------------------------------------------------
  closeWindow()
  ##  Close window and OpenGL context
  ## --------------------------------------------------------------------------------------


block core_vr_simulator:
  # ******************************************************************************************
  #
  #    raylib [core] example - VR Simulator (Oculus Rift CV1 parameters)
  #
  #    This example has been created using raylib 1.7 (www.raylib.com)
  #    raylib is licensed under an unmodified zlib/libpng license (View raylib.h for details)
  #
  #    Copyright (c) 2017 Ramon Santamaria (@raysan5)
  #    Converted in 2021 by greenfork
  #
  # ******************************************************************************************


  # Change GLSL this version to see different effects!
  const
    GLSL_VERSION = 330
    # GLSL_VERSION* = 100

  ##  Initialization
  ## --------------------------------------------------------------------------------------
  var screenWidth = 800
  var screenHeight = 450
  initWindow(screenWidth, screenHeight, "raylib [core] example - vr simulator")
  ##  Init VR simulator (Oculus Rift CV1 parameters)
  var device = VrDeviceInfo()

  ##  VR device parameters (head-mounted-device)
  ##  Oculus Rift CV1 parameters for simulator
  device.hResolution = 2160            ## horizontal resolution in pixels
  device.vResolution = 1200            ## vertical resolution in pixels
  device.hScreenSize = 0.133793        ## horizontal size in meters
  device.vScreenSize = 0.0669          ## vertical size in meters
  device.vScreenCenter = 0.04678       ## screen center in meters
  device.eyeToScreenDistance = 0.041   ## distance between eye and display in meters
  device.lensSeparationDistance = 0.07 ## lens separation distance in meters
  device.interpupillaryDistance = 0.07 ## IPD (distance between pupils) in meters

  ## NOTE: CV1 uses a Fresnel-hybrid-asymmetric lenses with specific distortion compute shaders.
  ## Following parameters are an approximation to distortion stereo rendering
  device.lensDistortionValues[0] = 1.0  ## lens distortion constant parameter 0
  device.lensDistortionValues[1] = 0.22 ## lens distortion constant parameter 1
  device.lensDistortionValues[2] = 0.24 ## lens distortion constant parameter 2
  device.lensDistortionValues[3] = 0.0  ## lens distortion constant parameter 3
  device.chromaAbCorrection[0] = 0.996  ## chromatic aberration correction parameter 0
  device.chromaAbCorrection[1] = -0.004 ## chromatic aberration correction parameter 1
  device.chromaAbCorrection[2] = 1.014  ## chromatic aberration correction parameter 2
  device.chromaAbCorrection[3] = 0.0    ## chromatic aberration correction parameter 3

  ## Load VR stereo config for VR device parameteres (Oculus Rift CV1 parameters)
  var config = loadVrStereoConfig(device)

  ##  Distortion shader (uses device lens distortion and chroma)
  var distortion: Shader = loadShader("", textFormat("resources/distortion%i.fs", GlslVersion))

  ## Update distortion shader with lens and distortion-scale parameters
  setShaderValue(distortion, getShaderLocation(distortion, "leftLensCenter"),
                 cast[pointer](config.leftLensCenter.addr), ShaderUniformDataType.Vec2)
  setShaderValue(distortion, getShaderLocation(distortion, "rightLensCenter"),
                 cast[pointer](config.rightLensCenter.addr), ShaderUniformDataType.Vec2)
  setShaderValue(distortion, getShaderLocation(distortion, "leftScreenCenter"),
                 cast[pointer](config.leftScreenCenter.addr), ShaderUniformDataType.Vec2)
  setShaderValue(distortion, getShaderLocation(distortion, "rightScreenCenter"),
                 cast[pointer](config.rightScreenCenter.addr), ShaderUniformDataType.Vec2)

  setShaderValue(distortion, getShaderLocation(distortion, "scale"),
                 cast[pointer](config.scale.addr), ShaderUniformDataType.Vec2)
  setShaderValue(distortion, getShaderLocation(distortion, "scaleIn"),
                 cast[pointer](config.scaleIn.addr), ShaderUniformDataType.Vec2)
  setShaderValue(distortion, getShaderLocation(distortion, "deviceWarpParam"),
                 cast[pointer](device.lensDistortionValues.addr), ShaderUniformDataType.Vec4)
  setShaderValue(distortion, getShaderLocation(distortion, "chromaAbParam"),
                 cast[pointer](device.chromaAbCorrection.addr), ShaderUniformDataType.Vec4)

  var target = loadRenderTexture(getScreenWidth(), getScreenHeight())

  ##  Define the camera to look into our 3d world
  var camera = Camera()
  camera.position = (5.0, 2.0, 5.0)    # Camera position
  camera.target = (0.0, 2.0, 0.0)      # Camera looking at point
  camera.up = (0.0, 1.0, 0.0)          # Camera up vector
  camera.fovy = 60.0
  ##  Camera field-of-view Y
  camera.projection = Perspective
  ##  Camera type
  var cubePosition: Vector3 = (0.0, 0.0, 0.0)
  setCameraMode(camera, FirstPerson)
  ##  Set first person camera mode
  setTargetFPS(90)
  ##  Set our game to run at 90 frames-per-second
  ## --------------------------------------------------------------------------------------
  ##  Main game loop
  while not windowShouldClose(): ##  Detect window close button or ESC key
    ##  Update
    ## ----------------------------------------------------------------------------------
    updateCamera(addr(camera))
    ##  Update camera (simulator mode)
    beginDrawing:
      clearBackground(Raywhite)
      beginTextureMode(target):
        clearBackground(Raywhite)
        beginVrStereoMode(config):
          beginMode3D(camera):
            drawCube(cubePosition, 2.0, 2.0, 2.0, Red)
            drawCubeWires(cubePosition, 2.0, 2.0, 2.0, Maroon)
            drawGrid(40, 1.0)
      beginShaderMode(distortion):
        drawTextureRec(
          target.texture,
          Rectangle(width: target.texture.width.cfloat, height: -target.texture.height.cfloat),
          Vector2(),
          White
        )
      drawFPS(10, 10)

  ## ----------------------------------------------------------------------------------
  ##  De-Initialization
  ## --------------------------------------------------------------------------------------
  unloadVrStereoConfig(config)
  unloadRenderTexture(target)
  unloadShader(distortion)
  ##  Unload distortion shader
  ##  Close VR simulator
  closeWindow()
  ##  Close window and OpenGL context
  ## --------------------------------------------------------------------------------------


block core_window_flags:
  # ******************************************************************************************
  #
  #    raylib [core] example - window flags
  #
  #    This example has been created using raylib 3.5 (www.raylib.com)
  #    raylib is licensed under an unmodified zlib/libpng license (View raylib.h for details)
  #
  #    Copyright (c) 2020 Ramon Santamaria (@raysan5)
  #    Converted in 2021 by greenfork
  #
  # ******************************************************************************************


  ##  Initialization
  ## ---------------------------------------------------------
  var screenWidth = 800
  var screenHeight = 450
  ##  Possible window flags
  ##
  ##     FLAG_VSYNC_HINT
  ##     FLAG_FULLSCREEN_MODE    -> not working properly -> wrong scaling!
  ##     FLAG_WINDOW_RESIZABLE
  ##     FLAG_WINDOW_UNDECORATED
  ##     FLAG_WINDOW_TRANSPARENT
  ##     FLAG_WINDOW_HIDDEN
  ##     FLAG_WINDOW_MINIMIZED   -> Not supported on window creation
  ##     FLAG_WINDOW_MAXIMIZED   -> Not supported on window creation
  ##     FLAG_WINDOW_UNFOCUSED
  ##     FLAG_WINDOW_TOPMOST
  ##     FLAG_WINDOW_HIGHDPI     -> errors after minimize-resize, fb size is recalculated
  ##     FLAG_WINDOW_ALWAYS_RUN
  ##     FLAG_MSAA_4X_HINT
  ##
  ##  Set configuration flags for window creation
  setConfigFlags(VsyncHint or Msaa4xHint or WindowHighdpi)
  initWindow(screenWidth, screenHeight, "raylib [core] example - window flags")
  var ballPosition: Vector2 = (getScreenWidth().float / 2.0, getScreenHeight().float / 2.0)
  var ballSpeed: Vector2 = (5.0, 4.0)
  var ballRadius = 20
  var framesCounter = 0
  setTargetFPS(60)
  ## ----------------------------------------------------------
  ##  Main game loop
  while not windowShouldClose(): ##  Detect window close button or ESC key
    ##  Update
    ## -----------------------------------------------------
    if isKeyPressed(F):
      toggleFullscreen()
    if isKeyPressed(R):
      if isWindowState(Window_Resizable):
        clearWindowState(Window_Resizable)
      else:
        setWindowState(Window_Resizable)
    if isKeyPressed(D):
      if isWindowState(Window_Undecorated):
        clearWindowState(Window_Undecorated)
      else:
        setWindowState(Window_Undecorated)
    if isKeyPressed(H):
      if not isWindowState(Window_Hidden):
        setWindowState(Window_Hidden)
      framesCounter = 0
    if isWindowState(Window_Hidden):
      inc(framesCounter)
      if framesCounter >= 240:
        clearWindowState(Window_Hidden)
    if isKeyPressed(N):
      if not isWindowState(Window_Minimized):
        minimizeWindow()
      framesCounter = 0
    if isWindowState(Window_Minimized):
      inc(framesCounter)
      if framesCounter >= 240:
        restoreWindow()
    if isKeyPressed(M):
      ##  NOTE: Requires FLAG_WINDOW_RESIZABLE enabled!
      if isWindowState(Window_Maximized):
        restoreWindow()
      else:
        maximizeWindow()
    if isKeyPressed(U):
      if isWindowState(Window_Unfocused):
        clearWindowState(Window_Unfocused)
      else:
        setWindowState(Window_Unfocused)
    if isKeyPressed(T):
      if isWindowState(Window_Topmost):
        clearWindowState(Window_Topmost)
      else:
        setWindowState(Window_Topmost)
    if isKeyPressed(A):
      if isWindowState(Window_Always_Run):
        clearWindowState(Window_Always_Run)
      else:
        setWindowState(Window_Always_Run)
    if isKeyPressed(V):
      if isWindowState(Vsync_Hint):
        clearWindowState(Vsync_Hint)
      else:
        setWindowState(Vsync_Hint)
    ballPosition.x += ballSpeed.x
    ballPosition.y += ballSpeed.y
    if (ballPosition.x >= (getScreenWidth() - ballRadius)) or
        (ballPosition.x <= ballRadius):
      ballSpeed.x = ballSpeed.x * -1.0
    if (ballPosition.y >= (getScreenHeight() - ballRadius)) or
        (ballPosition.y <= ballRadius):
      ballSpeed.y = ballSpeed.y * -1.0
    beginDrawing()
    if isWindowState(Window_Transparent):
      clearBackground(Blank)
    else:
      clearBackground(Raywhite)
    drawCircleV(ballPosition, ballRadius.float, Maroon)
    drawRectangleLinesEx((0.0, 0.0, getScreenWidth().float, getScreenHeight().float), 4, Raywhite)
    drawCircleV(getMousePosition(), 10, Darkblue)
    drawFPS(10, 10)
    drawText(textFormat("Screen Size: [%i, %i]", getScreenWidth(),
                        getScreenHeight()), 10, 40, 10, Green)
    ##  Draw window state info
    drawText("Following flags can be set after window creation:", 10, 60, 10, Gray)
    if isWindowState(Fullscreen_Mode):
      drawText("[F] FLAG_FULLSCREEN_MODE: on", 10, 80, 10, Lime)
    else:
      drawText("[F] FLAG_FULLSCREEN_MODE: off", 10, 80, 10, Maroon)
    if isWindowState(Window_Resizable):
      drawText("[R] FLAG_WINDOW_RESIZABLE: on", 10, 100, 10, Lime)
    else:
      drawText("[R] FLAG_WINDOW_RESIZABLE: off", 10, 100, 10, Maroon)
    if isWindowState(Window_Undecorated):
      drawText("[D] FLAG_WINDOW_UNDECORATED: on", 10, 120, 10, Lime)
    else:
      drawText("[D] FLAG_WINDOW_UNDECORATED: off", 10, 120, 10, Maroon)
    if isWindowState(Window_Hidden):
      drawText("[H] FLAG_WINDOW_HIDDEN: on", 10, 140, 10, Lime)
    else:
      drawText("[H] FLAG_WINDOW_HIDDEN: off", 10, 140, 10, Maroon)
    if isWindowState(Window_Minimized):
      drawText("[N] FLAG_WINDOW_MINIMIZED: on", 10, 160, 10, Lime)
    else:
      drawText("[N] FLAG_WINDOW_MINIMIZED: off", 10, 160, 10, Maroon)
    if isWindowState(Window_Maximized):
      drawText("[M] FLAG_WINDOW_MAXIMIZED: on", 10, 180, 10, Lime)
    else:
      drawText("[M] FLAG_WINDOW_MAXIMIZED: off", 10, 180, 10, Maroon)
    if isWindowState(Window_Unfocused):
      drawText("[G] FLAG_WINDOW_UNFOCUSED: on", 10, 200, 10, Lime)
    else:
      drawText("[U] FLAG_WINDOW_UNFOCUSED: off", 10, 200, 10, Maroon)
    if isWindowState(Window_Topmost):
      drawText("[T] FLAG_WINDOW_TOPMOST: on", 10, 220, 10, Lime)
    else:
      drawText("[T] FLAG_WINDOW_TOPMOST: off", 10, 220, 10, Maroon)
    if isWindowState(Window_Always_Run):
      drawText("[A] FLAG_WINDOW_ALWAYS_RUN: on", 10, 240, 10, Lime)
    else:
      drawText("[A] FLAG_WINDOW_ALWAYS_RUN: off", 10, 240, 10, Maroon)
    if isWindowState(Vsync_Hint):
      drawText("[V] FLAG_VSYNC_HINT: on", 10, 260, 10, Lime)
    else:
      drawText("[V] FLAG_VSYNC_HINT: off", 10, 260, 10, Maroon)
    drawText("Following flags can only be set before window creation:", 10, 300,
             10, Gray)
    if isWindowState(Window_Highdpi):
      drawText("FLAG_WINDOW_HIGHDPI: on", 10, 320, 10, Lime)
    else:
      drawText("FLAG_WINDOW_HIGHDPI: off", 10, 320, 10, Maroon)
    if isWindowState(Window_Transparent):
      drawText("FLAG_WINDOW_TRANSPARENT: on", 10, 340, 10, Lime)
    else:
      drawText("FLAG_WINDOW_TRANSPARENT: off", 10, 340, 10, Maroon)
    if isWindowState(Msaa_4x_Hint):
      drawText("FLAG_MSAA_4X_HINT: on", 10, 360, 10, Lime)
    else:
      drawText("FLAG_MSAA_4X_HINT: off", 10, 360, 10, Maroon)
    endDrawing()
  ## -----------------------------------------------------
  ##  De-Initialization
  ## ---------------------------------------------------------
  closeWindow()
  ##  Close window and OpenGL context
  ## ----------------------------------------------------------


block core_window_letterbox:
  # ******************************************************************************************
  #
  #    raylib [core] example - window scale letterbox (and virtual mouse)
  #
  #    This example has been created using raylib 2.5 (www.raylib.com)
  #    raylib is licensed under an unmodified zlib/libpng license (View raylib.h for details)
  #
  #    Example contributed by Anata (@anatagawa) and reviewed by Ramon Santamaria (@raysan5)
  #
  #    Copyright (c) 2019 Anata (@anatagawa) and Ramon Santamaria (@raysan5)
  #    Converted in 2021 by greenfork
  #
  # ******************************************************************************************


  ##  Clamp Vector2 value with min and max and return a new vector2
  ##  NOTE: Required for virtual mouse, to clamp inside virtual game size
  proc clampValue(value: Vector2, minV: Vector2, maxV: Vector2): Vector2 =
    result = value
    result.x = if (result.x > maxV.x): maxV.x else: result.x
    result.x = if (result.x < minV.x): minV.x else: result.x
    result.y = if (result.y > maxV.y): maxV.y else: result.y
    result.y = if (result.y < minV.y): minV.y else: result.y

  var windowWidth = 800
  var windowHeight = 450
  ##  Enable config flags for resizable window and vertical synchro
  setConfigFlags(Window_Resizable or Vsync_Hint)
  initWindow(windowWidth, windowHeight,
             "raylib [core] example - window scale letterbox")
  setWindowMinSize(320, 240)
  var gameScreenWidth = 640
  var gameScreenHeight = 480
  ##  Render texture initialization, used to hold the rendering result so we can easily resize it
  var target: RenderTexture2D = loadRenderTexture(gameScreenWidth, gameScreenHeight)
  setTextureFilter(target.texture, Bilinear)
  ##  Texture scale filter to use
  var colors: array[10, Color]
  for color in colors.mitems:
    color = Color(r: getRandomValue(100, 250).uint8, g: getRandomValue(50, 150).uint8,
                  b: getRandomValue(10, 100).uint8, a: 255'u8)
  setTargetFPS(60)
  ##  Set our game to run at 60 frames-per-second
  ## --------------------------------------------------------------------------------------
  ##  Main game loop
  while not windowShouldClose(): ##  Detect window close button or ESC key
    ##  Update
    ## ----------------------------------------------------------------------------------
    ##  Compute required framebuffer scaling
    var scale: float = min((float)(getScreenWidth() / gameScreenWidth),
                             (float)(getScreenHeight() / gameScreenHeight))
    if isKeyPressed(Space):
      ##  Recalculate random colors for the bars
      for color in colors.mitems:
        color = Color(r: getRandomValue(100, 250).uint8, g: getRandomValue(50, 150).uint8,
                      b: getRandomValue(10, 100).uint8, a: 255'u8)
    var mouse: Vector2 = getMousePosition()
    var virtualMouse: Vector2
    virtualMouse.x = (mouse.x - (getScreenWidth() - (gameScreenWidth * scale)) * 0.5) / scale
    virtualMouse.y = (mouse.y - (getScreenHeight() - (gameScreenHeight * scale)) * 0.5) / scale
    virtualMouse = clampValue(virtualMouse, (0.0, 0.0), (gameScreenWidth.float, gameScreenHeight.float))
    ##  Apply the same transformation as the virtual mouse to the real mouse (i.e. to work with raygui)
    # setMouseOffset(
    #   -((getScreenWidth() - (gameScreenWidth * scale)) * 0.5).cint,
    #   -((getScreenHeight() - (gameScreenHeight * scale)) * 0.5).cint
    # )
    # setMouseScale(1.0/scale, 1.0/scale)

    ## ----------------------------------------------------------------------------------
    ##  Draw
    ##
    ## ----------------------------------------------------------------------------------
    beginDrawing()
    clearBackground(Black)
    ##  Draw everything in the render texture, note this will not be rendered on screen, yet
    beginTextureMode(target)
    clearBackground(Raywhite)
    ##  Clear render texture background color
    var i = 0
    while i < 10:
      drawRectangle(0, (gameScreenHeight div 10) * i, gameScreenWidth,
                    gameScreenHeight div 10, colors[i])
      inc(i)
    drawText("If executed inside a window,\nyou can resize the window,\nand see the screen scaling!",
             10, 25, 20, White)
    drawText(textFormat("Default Mouse: [%i , %i]", mouse.x.int, mouse.y.int),
      350, 25, 20, Green)
    drawText(textFormat("Virtual Mouse: [%i , %i]", virtualMouse.x.int, virtualMouse.y.int),
      350, 55, 20, Yellow)
    endTextureMode()
    ## Draw RenderTexture2D to window, properly scaled
    drawTexturePro(
      target.texture,
      (0.0, 0.0, target.texture.width.float, -target.texture.height.float),
      ((getScreenWidth() - (gameScreenWidth*scale))*0.5,
       (getScreenHeight() - (gameScreenHeight*scale))*0.5,
       (gameScreenWidth*scale),
       (gameScreenHeight*scale)
      ),
      (0.0, 0.0),
      0.0,
      White
    )
    endDrawing()
  ## --------------------------------------------------------------------------------------
  ##  De-Initialization
  ## --------------------------------------------------------------------------------------
  unloadRenderTexture(target)
  ##  Unload render texture
  closeWindow()
  ##  Close window and OpenGL context
  ## --------------------------------------------------------------------------------------


block core_world_screen:
  # ******************************************************************************************
  #
  #    raylib [core] example - World to screen
  #
  #    This example has been created using raylib 1.3 (www.raylib.com)
  #    raylib is licensed under an unmodified zlib/libpng license (View raylib.h for details)
  #
  #    Copyright (c) 2015 Ramon Santamaria (@raysan5)
  #    Converted in 2021 by greenfork
  #
  # ******************************************************************************************


  ##  Initialization
  ## --------------------------------------------------------------------------------------
  var screenWidth = 800
  var screenHeight = 450
  initWindow(screenWidth, screenHeight, "raylib [core] example - 3d camera free")
  ##  Define the camera to look into our 3d world
  var camera = Camera()
  camera.position = (10.0, 10.0, 10.0)
  camera.target = (0.0, 0.0, 0.0)
  camera.up = (0.0, 1.0, 0.0).Vector3
  camera.fovy = 45.0
  camera.projection = Perspective
  var cubePosition: Vector3 = (0.0, 0.0, 0.0)
  var cubeScreenPosition: Vector2 = (0.0, 0.0)
  setCameraMode(camera, Free)
  ##  Set a free camera mode
  setTargetFPS(60)
  ##  Set our game to run at 60 frames-per-second
  ## --------------------------------------------------------------------------------------
  ##  Main game loop
  while not windowShouldClose(): ##  Detect window close button or ESC key
    ##  Update
    ## ----------------------------------------------------------------------------------
    updateCamera(addr(camera))
    ## Update camera
    ## Calculate cube screen space position (with a little offset to be in top)
    cubeScreenPosition = getWorldToScreen((cubePosition.x.float, cubePosition.y + 2.5, cubePosition.z.float), camera)
    ## ----------------------------------------------------------------------------------
    ##  Draw
    ## ----------------------------------------------------------------------------------
    beginDrawing()
    clearBackground(Raywhite)
    beginMode3D(camera)
    drawCube(cubePosition, 2.0, 2.0, 2.0, Red)
    drawCubeWires(cubePosition, 2.0, 2.0, 2.0, Maroon)
    drawGrid(10, 1.0)
    endMode3D()
    drawText(
      "Enemy: 100 / 100",
      (cubeScreenPosition.x.int32 - measureText("Enemy: 100/100", 20) div 2),
      cubeScreenPosition.y.int32,
      20,
      Black
    )
    drawText(
      "Text is always on top of the cube",
      ((screenWidth - measureText("Text is always on top of the cube", 20)) / 2).int32,
      25,
      20,
      Gray
    )
    endDrawing()
  ## ----------------------------------------------------------------------------------
  ##  De-Initialization
  ## --------------------------------------------------------------------------------------
  closeWindow()
  ##  Close window and OpenGL context
  ## --------------------------------------------------------------------------------------


block models_first_person_maze:
  #[*******************************************************************************************
  *
  *   raylib [models] example - first person maze
  *
  *   This example has been created using raylib 2.5 (www.raylib.com)
  *   raylib is licensed under an unmodified zlib/libpng license (View raylib.h for details)
  *
  *   Copyright (c) 2019 Ramon Santamaria (@raysan5)
  *   Adapted to Nim by jseb (2021)
  *
  ********************************************************************************************]#


  proc main() =
    const
      screenWidth = 1024
      screenHeight = 768

    initWindow(screenWidth, screenHeight, "raylib [models] example - first person maze")

    var camera = Camera3D(
      position: (0.2, 0.4, 0.2), target: (0.0, 0.0, 0.0), up: (0.0, 1.0, 0.0),
          fovy: 45.0, projection: Perspective
    )
    camera.setCameraMode(FIRST_PERSON)

    let imMap: Image = loadImage("resources/cubicmap.png") # load cubicmap image (RAM)
    let cubicMapTexture: Texture2D = loadTextureFromImage(
        imMap) # convert image to texture (VRAM)
    let mesh = genMeshCubicmap(imMap, (x: 1.0, y: 1.0, z: 1.0))
    var model = loadModelFromMesh(mesh)

    # NOTE: By default each cube is mapped to one part of texture atlas
    let mapTexture = loadTexture("resources/cubicmap_atlas.png")
    model.materials[0].maps[int(Albedo)].texture = mapTexture

    # Get map image data to be used for collision detection
    let mapPixels = cast[ptr UncheckedArray[Color]](loadImageColors(imMap))
    unloadImage(imMap) # no need to keep imMap in RAM, once loaded

    var modelPosition = Vector3(x: -16.0, y: 0.0, z: -8.0)


    setTargetFPS(60)

    while not windowShouldClose(): # detect window close button or ESC key
      var oldCamPos = camera.position
      camera.addr.updateCamera()

      # Check player collision (we simplify to 2D collision detection)
      let playerPos: Vector2 = Vector2(x: camera.position.x, y: camera.position.z)
      let playerRadius: cfloat = 0.1 # Collision radius (player is modelled as a cilinder for collision)

      var playerCellX = (playerPos.x - modelPosition.x + 0.5f).int
      var playerCellY = (playerPos.y - modelPosition.z + 0.5f).int

      # out of limits check
      if playerCellX < 0: playerCellX = 0
      elif playerCellX >= cubicMapTexture.width: playerCellX = cubicMapTexture.width - 1
      if playerCellY < 0: playerCellY = 0
      elif playerCellY >= cubicMapTexture.height: playerCellY = cubicMapTexture.height - 1
      # Check map collisions using image data and player position
      # TODO: Improvement: Just check player surrounding cells for collision
      for y in 0..<cubicMapTexture.height:
        for x in 0..<cubicMapTexture.width:
          var collisionRect = Rectangle(x: modelPosition.x - 0.5 + x.float,
              y: modelPosition.z - 0.5 + y.float, width: 1.0, height: 1.0)
          # collision: white pixel, red channel
          if mapPixels[y*cubicMapTexture.width + x].r == 255 and
              checkCollisionCircleRec(playerPos, playerRadius, collisionRect):
            camera.position = oldCamPos

      beginDrawing:
        clearBackground(Gray)
        camera.beginMode3D:
          drawModel(model, modelPosition, 1.0f, WHITE) # draw maze map
        drawTextureEx(cubicMapTexture, (x: getScreenWidth().float -
            cubicMapTexture.width.float*4.0 - 20.0, y: 20.0), 0.0, 4.0, White)
        drawRectangleLines(getScreenWidth() - cubicMapTexture.width*4 - 20, 20,
            cubicMapTexture.width*4, cubicMapTexture.height*4, Green)
        # Draw player position radar
        drawRectangle(getScreenWidth() - cubicMapTexture.width*4 - 20 +
            playerCellX*4, 20 + playerCellY*4, 4, 4, Yellow)
        drawFPS(10, 10)

    unloadImageColors(mapPixels[0].addr) # Unload color array
    unloadTexture(cubicMapTexture) # Unload cubicmap texture
    unloadTexture(mapTexture) # Unload map texture
    unloadModel(model) # Unload map model

    closeWindow() # Close window and OpenGL context

  main()


block models_geometric_shapes:
  #*******************************************************************************************
  #
  #   raylib [models] example - Draw some basic geometric shapes (cube, sphere, cylinder...)
  #
  #   This example has been created using raylib 1.0 (www.raylib.com)
  #   raylib is licensed under an unmodified zlib/libpng license (View raylib.h for details)
  #
  #   Copyright (c) 2014 Ramon Santamaria (@raysan5)
  #   /Converted in 2*20 by Guevara-chan.
  #
  #*******************************************************************************************



  #  Initialization
  # --------------------------------------------------------------------------------------
  const screenWidth = 800
  const screenHeight = 450

  initWindow screenWidth, screenHeight, "raylib [models] example - geometric shapes"

  #  Define the camera to look into our 3d world
  var camera = Camera()
  camera.position = (x: 0.0, y: 10.0, z: 10.0)
  camera.target   = (x: 0.0, y: 0.0, z: 0.0)
  camera.up       = (x: 0.0, y: 1.0, z: 0.0)
  camera.fovy     = 45.0
  camera.projection   = PERSPECTIVE

  60.setTargetFPS                #  Set our game to run at 60 frames-per-second
  # --------------------------------------------------------------------------------------

  #  Main game loop
  while not windowShouldClose(): #  Detect window close button or ESC key
      #  Update
      # ----------------------------------------------------------------------------------
      #  TODO: Update your variables here
      # ----------------------------------------------------------------------------------

      #  Draw
      # ----------------------------------------------------------------------------------
      beginDrawing()

      clearBackground RAYWHITE

      beginMode3D camera

      drawCube (x: -4.0, y: 0.0, z: 2.0), 2.0, 5.0, 2.0, RED
      drawCubeWires (x: -4.0, y: 0.0, z: 2.0), 2.0, 5.0, 2.0, GOLD
      drawCubeWires (x: -4.0, y: 0.0, z: -2.0), 3.0, 6.0, 2.0, MAROON

      drawSphere (x: -1.0, y: 0.0, z: -2.0), 1.0, GREEN
      drawSphereWires (x: 1.0, y: 0.0, z: 2.0), 2.0, 16, 16, LIME

      drawCylinder (x: 4.0, y: 0.0, z: -2.0), 1.0, 2.0, 3.0, 4, SKYBLUE
      drawCylinderWires (x: 4.0, y: 0.0, z: -2.0), 1.0, 2.0, 3.0, 4, DARKBLUE
      drawCylinderWires (x: 4.5, y: -1.0, z: 2.0), 1.0, 1.0, 2.0, 6, BROWN

      drawCylinder (x: 1.0, y: 0.0, z: -4.0), 0.0, 1.5, 3.0, 8, GOLD
      drawCylinderWires (x: 1.0, y: 0.0, z: -4.0), 0.0, 1.5, 3.0, 8, PINK

      drawGrid 10, 1.0         #  Draw a grid

      endMode3D()

      drawFPS 10, 10

      endDrawing()
      # ----------------------------------------------------------------------------------

  #  De-Initialization
  # --------------------------------------------------------------------------------------
  closeWindow()        #  Close window and OpenGL context
  # --------------------------------------------------------------------------------------


block models_loading:

  # Window, Title, FPS Setup
  const screenWidth = 800
  const screenHeight = 450
  initWindow screenWidth, screenHeight, "Loading A 3D Model"
  setTargetFPS(60)

  # Camera Setup
  var camera = Camera(
    position: (x: 50.0, y: 50.0, z: 50.0),
    target: (x: 0.0, y: 10.0, z: 0.0),
    up: (x: 0.0, y: 1.0, z: 0.0),
    fovy: 45
    )
  camera.projection = Perspective
  camera.setCameraMode Free

  # Model Setup
  var model = loadModel("resources/castle.obj") # load model
  var texture: Texture2D = loadTexture("resources/castle_diffuse.png") # load model texture
  model.materials[0].maps[MaterialMapIndex.Albedo.int].texture = texture # set map diffuse texture
    # NOTES ON ABOVE:
    # original C code: model.materials[0].maps[MATERIAL_MAP_DIFFUSE].texture = texture
    # MATERIAL_MAP_DIFFUSE is now ALBEDO (Raylib)
  var position: Vector3 = (0.0, 0.0, 0.0) # set model position
  var bounds: BoundingBox = meshBoundingBox(model.meshes[0]) # set model bounds
    # NOTE: bounds are calculated from the original size of the model,
    # if model is scaled on drawing, bounds must be also scaled

  var selected = false # selected object flag

  # Main Loop
  while not windowShouldClose():

    # Update Camera
    camera.addr.updateCamera()

    # Load new models/textures on drag&drop
    if isFileDropped():
      var count: cint = 0
      var droppedFiles = getDroppedFiles(count.addr)

      if count == 1: # only support one file dropped
        # Model file formats supported
        if isFileExtension(fileName=droppedFiles[0], ext=".obj") or
          isFileExtension(fileName=droppedFiles[0], ext=".gltf") or
          isFileExtension(fileName=droppedFiles[0], ext=".iqm"):
            unloadModel(model) # unload previous model
            model = loadModel(droppedFiles[0]) # load new model
            model.materials[0].maps[MaterialMapIndex.Albedo.int].texture = texture # Set current map diffuse texture
            bounds = meshBoundingBox(model.meshes[0]) # set new model bounds
            # TODO: Move camera position from target enough distance to visualize model properly
        elif isFileExtension(droppedFiles[0],".png"): # Texture fil formats supported
          # unload current model texture and load new one
          unloadTexture(texture)
          texture = loadTexture(droppedFiles[0])
          model.materials[0].maps[MaterialMapIndex.Albedo.int].texture = texture

      clearDroppedFiles() # Clear internal buffers

    # Select model on mouse click
    if isMouseButtonPressed(LeftButton):
      # Check collision between ray and box
      if checkCollisionRayBox(getMouseRay(getMousePosition(),camera), bounds):
        selected = true
      else:
        selected = false

    # Draw
    beginDrawing()
    clearBackground(Raywhite)
    beginMode3D(camera):
      drawModel(model, position, 1.0, White) # Draw 3d model with texture
      drawGrid(20,10.0) # Draw grid
      if selected: drawBoundingBox(bounds, Green) # Draw selection box
    endMode3D()
    drawText("Drag & drop model to load mesh/texture.", 10, getScreenHeight() - 20, 10, Darkgray)
    if selected:
      drawText("MODEL SELECTED", getScreenWidth() - 110, 10, 10, Green)
    drawText("Castle 3D Model", screenWidth - 200, screenHeight - 20, 10, Gray)
    drawFPS(10, 10)
    endDrawing()

  # De-Initialization
  unloadTexture(texture) # unload model texture
  unloadModel(model) # unload model
  closeWindow() # Close window and OpenGL context


block models_mesh_generation:
  #[*******************************************************************************************
  *
  *   raylib example - procedural mesh generation
  *
  *   This example has been created using raylib 1.8 (www.raylib.com)
  *   raylib is licensed under an unmodified zlib/libpng license (View raylib.h for details)
  *
  *   Copyright (c) 2017 Ramon Santamaria (Ray San)
  *   Adapted for Nim by jseb
  *
  ********************************************************************************************]#


  proc allocateMeshData(mesh: var Mesh, triangleCount: int) =
    mesh.vertexCount = triangleCount * 3
    mesh.triangleCount = triangleCount

    mesh.vertices = cast[ptr UncheckedArray[cfloat]](memAlloc(mesh.vertexCount * 3 * sizeof(cfloat)))
    mesh.texcoords = cast[ptr UncheckedArray[cfloat]](memAlloc(mesh.vertexCount * 2 * sizeof(cfloat)))
    mesh.normals = cast[ptr UncheckedArray[cfloat]](memAlloc(mesh.vertexCount * 3 * sizeof(cfloat)))

  proc makeMesh(): Mesh =
    allocateMeshData(result, 1)

    for idx, val in [0.cfloat,0,0, 1,0,2, 2,0,0]:
      result.vertices[idx] = val
    for idx, val in [0.cfloat,1,0, 0,1,0, 0,1,0]:
      result.normals[idx] = val
    for idx, val in [0.cfloat,0, 0.5,1, 1,0]:
      result.texcoords[idx] = val

    uploadMesh(result.addr, false)

  proc main() =
    # Initialization
    #--------------------------------------------------------------------------------------
    const
      screenWidth = 800
      screenHeight = 450

    initWindow(screenWidth, screenHeight, "raylib [models] example - mesh generation")

    let meshes = [
      genMeshPlane(2,2,5,5),
      genMeshCube(2.0f, 1.0f, 2.0f),
      genMeshSphere(2, 32, 32),
      genMeshHemiSphere(2, 16, 16),
      genMeshCylinder(1, 2, 16),
      genMeshTorus(0.25f, 4.0f, 16, 32),
      genMeshKnot(1.0f, 2.0f, 16, 128),
      genMeshPoly(5, 2.0f),
      makeMesh()
    ]

    # We generate a checked image for texturing
    var checked: Image = genImageChecked(2, 2, 1, 1, Red, Green)
    var texture: Texture2D = loadTextureFromImage(checked)
    unloadImage(checked)

    # Set checked texture as default diffuse component for all models material
    var models: seq[Model]
    for mesh in meshes:
      var m = loadModelFromMesh(mesh)
      m.materials[0].maps[MaterialMapIndex.Albedo.int].texture = texture # MATERIAL_MAP_DIFFUSE is now ALBEDO
      models.add(m)

    # Define the camera to look into our 3d world
    var camera = Camera3D(
      position: (5.0, 5.0, 5.0),
      target: (0.0, 0.0, 0.0),
      up: (0.0, 1.0, 0.0),
      fovy: 45.0,
      projection: Perspective
    )

    var position = Vector3(x: 0.0, y: 0.0, z: 0.0)
    var currentModel = 0

    camera.setCameraMode(Orbital)

    setTargetFPS(60)
    #--------------------------------------------------------------------------------------

    # Main game loop
    while not windowShouldClose():  # Detect window close button or ESC key

      # Update
      #----------------------------------------------------------------------------------
      updateCamera(camera.addr)  # Update internal camera and our camera
      if isMouseButtonPressed(LEFT_BUTTON) or isKeyPressed(RIGHT):
        currentModel = (currentModel + 1) mod models.len  # Cycle between the textures
      if isKeyPressed(LEFT):
        currentModel = currentModel - 1
        if currentModel < 0: currentModel = models.len - 1
      #--------------------------------------------------------------------------------------

      # Draw
      #----------------------------------------------------------------------------------
      beginDrawing:
        clearBackground(White)
        camera.beginMode3D:
          drawModel(models[currentModel], position, 1.0, White)
          drawGrid(10, 1.0)

        drawRectangle(30, 400, 310, 30, fade(SkyBlue, 0.5f))
        drawRectangleLines(30, 400, 310, 30, fade(DarkBlue, 0.5f))
        drawText("MOUSE LEFT BUTTON to CYCLE PROCEDURAL MODELS", 40, 410, 10, Blue)

        let listModels = [("PLANE",680), ("CUBE",680), ("SPHERE",680), ("HEMISPHERE",640), ("CYLINDER",680),
                            ("TORUS",680), ("KNOT",680), ("POLY",680), ("Parametric(custom)",580)]
        drawText(listModels[currentModel][0], listModels[currentModel][1], 10, 20, DarkBlue)
      #--------------------------------------------------------------------------------------

    # De-Initialization
    #--------------------------------------------------------------------------------------
    unloadTexture(texture)

    # Unload models data (GPU VRAM)
    for m in models: unloadModel(m)

    closeWindow()  # Close window and OpenGL context
    #--------------------------------------------------------------------------------------

  main()


block models_rlgl_solar_system:
  #******************************************************************************************
  #
  #   raylib [models] example - gl module usage with push/pop matrix transformations
  #
  #   This example uses [gl] module funtionality (pseudo-OpenGL 1.1 style coding)
  #
  #   This example has been created using raylib 2.5 (www.raylib.com)
  #   raylib is licensed under an unmodified zlib/libpng license (View raylib.h for details)
  #
  #   Copyright (c) 2018 Ramon Santamaria (@raysan5)
  #   /Converted in 2*20 by Guevara-chan.
  #   Adapted in 2021 by greenfork
  #
  #*******************************************************************************************


  # ------------------------------------------------------------------------------------
  #  Module Functions Declaration
  # ------------------------------------------------------------------------------------
  proc drawSphereBasic(color: Color) #  Draw sphere without any matrix transformation

  # ------------------------------------------------------------------------------------
  #  Program main entry point
  # ------------------------------------------------------------------------------------

  #  Initialization
  # --------------------------------------------------------------------------------------
  const
    screenWidth      = 800
    screenHeight     = 450

    sunRadius        = 4.0
    earthRadius      = 0.6
    earthOrbitRadius = 8.0
    moonRadius       = 0.16
    moonOrbitRadius  = 1.5

  initWindow screenWidth, screenHeight, "raylib [models] example - gl module usage with push/pop matrix transformations"

  #  Define the camera to look into our 3d world
  var camera      = Camera()
  camera.position = (x: 16.0, y: 16.0, z: 16.0)
  camera.target   = (x: 0.0, y: 0.0, z: 0.0)
  camera.up       = (x: 0.0, y: 1.0, z: 0.0)
  camera.fovy     = 45.0
  camera.projection    = Perspective

  camera.setCameraMode Free

  var
    rotationSpeed = 0.2          #  General system rotation speed

    earthRotation      = 0.0     #  Rotation of earth around itself (days) in degrees
    earthOrbitRotation = 0.0     #  Rotation of earth around the Sun (years) in degrees
    moonRotation       = 0.0     #  Rotation of moon around itself
    moonOrbitRotation  = 0.0     #  Rotation of moon around earth in degrees

  60.setTargetFPS                   #  Set our game to run at 60 frames-per-second
  # --------------------------------------------------------------------------------------

  #  Main game loop
  while not windowShouldClose():    #  Detect window close button or ESC key
    #  Update
    # ----------------------------------------------------------------------------------
    camera.addr.updateCamera

    earthRotation += (5.0*rotationSpeed)
    earthOrbitRotation += (365/360.0*(5.0*rotationSpeed)*rotationSpeed)
    moonRotation += (2.0*rotationSpeed)
    moonOrbitRotation += (8.0*rotationSpeed)
    # ----------------------------------------------------------------------------------

    #  Draw
    # ----------------------------------------------------------------------------------
    beginDrawing:

      clearBackground Raywhite

      beginMode3D(camera):

        rl.pushMatrix()
        rl.scalef sunRadius, sunRadius, sunRadius           #  Scale Sun
        Gold.drawSphereBasic                                #  Draw the Sun
        rl.popMatrix()

        rl.pushMatrix()
        rl.rotatef earthOrbitRotation, 0.0, 1.0, 0.0        #  Rotation for Earth orbit around Sun
        rl.translatef earthOrbitRadius, 0.0, 0.0            #  Translation for Earth orbit
        rl.rotatef -earthOrbitRotation, 0.0, 1.0, 0.0       #  Rotation for Earth orbit around Sun inverted

        rl.pushMatrix()
        rl.rotatef earthRotation, 0.25, 1.0, 0.0            #  Rotation for Earth itself
        rl.scalef earthRadius, earthRadius, earthRadius     #  Scale Earth
        Blue.drawSphereBasic                                #  Draw the Earth
        rl.popMatrix()

        rl.rotatef moonOrbitRotation, 0.0, 1.0, 0.0         #  Rotation for Moon orbit around Earth
        rl.translatef moonOrbitRadius, 0.0, 0.0             #  Translation for Moon orbit
        rl.rotatef -moonOrbitRotation, 0.0, 1.0, 0.0        #  Rotation for Moon orbit around Earth inverted
        rl.rotatef moonRotation, 0.0, 1.0, 0.0              #  Rotation for Moon itself
        rl.scalef moonRadius, moonRadius, moonRadius        #  Scale Moon

        Lightgray.drawSphereBasic                           #  Draw the Moon
        rl.popMatrix()

        #  Some reference elements (not affected by previous matrix transformations)
        drawCircle3D (x: 0.0, y: 0.0, z: 0.0), earthOrbitRadius, (x: 1.0, y: 0.0, z: 0.0), 90.0, fade(RED, 0.5)
        drawGrid 20, 1.0

      drawText "EARTH ORBITING AROUND THE SUN!", 400, 10, 20, MAROON
      drawFPS 10, 10
  # ----------------------------------------------------------------------------------

  #  De-Initialization
  # --------------------------------------------------------------------------------------
  closeWindow()        #  Close window and OpenGL context
  # --------------------------------------------------------------------------------------

  # --------------------------------------------------------------------------------------------
  #  Module Functions Definitions (local)
  # --------------------------------------------------------------------------------------------

  #  Draw sphere without any matrix transformation
  #  NOTE: Sphere is drawn in world position ( 0, 0, 0 ) with radius 1.0
  proc drawSphereBasic(color: Color) =
      const
          rings = 16
          slices = 16

      rl.begin(rl.Triangles):
        rl.color4ub color.r, color.g, color.b, color.a

        for i in 0..<rings+2:
          for j in 0..<slices:
            rl.vertex3f(cos(degToRad(270+(180/(rings + 1))*i))*sin(degToRad(j*360/slices)),
                       sin(degToRad(270+(180/(rings + 1))*i)),
                       cos(degToRad(270+(180/(rings + 1))*i))*cos(degToRad(j*360/slices)))
            rl.vertex3f(cos(degToRad(270+(180/(rings + 1))*(i+1)))*sin(degToRad((j+1)*360/slices)),
                       sin(degToRad(270+(180/(rings + 1))*(i+1))),
                       cos(degToRad(270+(180/(rings + 1))*(i+1)))*cos(degToRad((j+1)*360/slices)))
            rl.vertex3f(cos(degToRad(270+(180/(rings + 1))*(i+1)))*sin(degToRad(j*360/slices)),
                       sin(degToRad(270+(180/(rings + 1))*(i+1))),
                       cos(degToRad(270+(180/(rings + 1))*(i+1)))*cos(degToRad(j*360/slices)))

            rl.vertex3f(cos(degToRad(270+(180/(rings + 1))*i))*sin(degToRad(j*360/slices)),
                       sin(degToRad(270+(180/(rings + 1))*i)),
                       cos(degToRad(270+(180/(rings + 1))*i))*cos(degToRad(j*360/slices)))
            rl.vertex3f(cos(degToRad(270+(180/(rings + 1))*(i)))*sin(degToRad((j+1)*360/slices)),
                       sin(degToRad(270+(180/(rings + 1))*(i))),
                       cos(degToRad(270+(180/(rings + 1))*(i)))*cos(degToRad((j+1)*360/slices)))
            rl.vertex3f(cos(degToRad(270+(180/(rings + 1))*(i+1)))*sin(degToRad((j+1)*360/slices)),
                       sin(degToRad(270+(180/(rings + 1))*(i+1))),
                       cos(degToRad(270+(180/(rings + 1))*(i+1)))*cos(degToRad((j+1)*360/slices)))


block models_waving_cubes:
  #*******************************************************************************************
  #
  #   raylib [models] example - Waving cubes
  #
  #   This example has been created using raylib 2.5 (www.raylib.com)
  #   raylib is licensed under an unmodified zlib/libpng license (View raylib.h for details)
  #
  #   Example contributed by Codecat (@codecat) and reviewed by Ramon Santamaria (@raysan5)
  #
  #   Copyright (c) 2019 Codecat (@codecat) and Ramon Santamaria (@raysan5)
  #   /Converted in 2*20 by Guevara-chan.
  #   Adapted in 2021 by greenfork
  #
  #*******************************************************************************************


  #  Initialization
  # --------------------------------------------------------------------------------------
  const screenWidth = 800
  const screenHeight = 450

  initWindow screenWidth, screenHeight, "raylib [models] example - waving cubes"

  #  Initialize the camera
  var camera      = Camera3D()
  camera.position = (x: 30.0, y: 20.0, z: 30.0)
  camera.target   = (x: 0.0, y: 0.0, z: 0.0)
  camera.up       = (x: 0.0, y: 1.0, z: 0.0)
  camera.fovy     = 70.0
  camera.projection   = PERSPECTIVE

  #  Specify the amount of blocks in each direction
  const numBlocks = 15

  60.setTargetFPS
  # --------------------------------------------------------------------------------------

  #  Main game loop
  while not windowShouldClose():    #  Detect window close button or ESC key

      #  Update
      # ----------------------------------------------------------------------------------
      let
          time = nimraylib_now.getTime()

          #  Calculate time scale for cube position and size
          scale = (2.0 + sin(time))*0.7

          #  Move camera around the scene
          cameraTime = time*0.3
      camera.position.x = cos(cameraTime)*40.0
      camera.position.z = sin(cameraTime)*40.0
      # ----------------------------------------------------------------------------------

      #  Draw
      # ----------------------------------------------------------------------------------
      beginDrawing:

        clearBackground(Raywhite)

        beginMode3D(camera):

          drawGrid 10, 5.0

          for x in 0..<numBlocks:
            for y in 0..<numBlocks:
              for z in 0..<numBlocks:
                  #  Scale of the blocks depends on x/y/z positions
                  let
                    blockScale = (x + y + z)/30.0

                    #  Scatter makes the waving effect by adding blockScale over time
                    scatter = sin(blockScale*20.0 + (time*4.0))

                    #  Calculate the cube position
                    cubePos = (
                        x: (x - numBlocks/2)*(scale*3.0) + scatter,
                        y: (y - numBlocks/2)*(scale*2.0) + scatter,
                        z: (z - numBlocks/2)*(scale*3.0) + scatter)

                    #  Pick a color with a hue depending on cube position for the rainbow color effect
                    cubeColor = colorFromHSV((((x + y + z)*18)%%360)/1.0, 0.75f, 0.9)

                    #  Calculate cube size
                    cubeSize = (2.4 - scale)*blockScale

                  #  And finally, draw the cube!
                  drawCube cubePos, cubeSize, cubeSize, cubeSize, cubeColor

        drawFPS 10, 10
  # ----------------------------------------------------------------------------------

  #  De-Initialization
  # --------------------------------------------------------------------------------------
  closeWindow()        #  Close window and OpenGL context
  # --------------------------------------------------------------------------------------


block basic:
  # -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- #
  # Raylib Forever basic usage sample
  # Developed in 2*20 by Guevara-chan
  # Adapted in 2021 by greenfork
  # -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- #


  initWindow 800, 600, "[nim]RaylibNow!"
  60.setTargetFPS

  # Camera setup.
  var camera = Camera(
    position: (x: 0.0, y: 10.0, z: -15.0),
    up: (x: 0.0, y: 0.5, z: 0.0),
    fovy: 45
  )
  camera.setCameraMode Orbital

  # ==Main code==
  while not windowShouldClose():
    camera.addr.updateCamera
    beginDrawing()
    label (x: 10.0, y: 0.0, width: 100.0, height: 25.0), "by V.A. Guevara"
    clearBackground(Black)
    beginMode3D(camera)
    drawGrid 10, 1.0
    drawSphere (0.0, 0.0, 0.0), 0.5, Red
    endMode3D()
    let
      slogan = "/Hello from Nim/"
      size = 20
      width = measureText(slogan, size)
    slogan.drawText(
      (getScreenWidth() - width) div 2,
      getScreenHeight() div 2 - 100,
      size,
      LightGray
    )
    drawRectangleV(
      (x: 10.0, y: 10.0),
      (x: (getScreenWidth() - 20).float, y: (getScreenHeight() - 20).float),
      (r: 255, g: 0, b: 0, a: 20)
    )
    endDrawing()


block crown:
  # Developed in 2021 by greenfork


  const
    nimFg: Color = (0xff, 0xc2, 0x00)          # Use this shortcut with alpha = 255!
    nimBg: Color = (0x17, 0x18, 0x1f)

  # Let's draw a Nim crown!
  const
    crownSides = 8                             # Low-polygon version
    centerAngle = 2.0 * PI / crownSides.float  # Angle from the center of a circle
    lowerRadius = 2.0                          # Lower crown circle
    upperRadius = lowerRadius * 1.4            # Upper crown circle
    mainHeight = lowerRadius * 0.8             # Height without teeth
    toothHeight = mainHeight * 1.3             # Height with teeth
    toothSkew = 1.2                            # Little angle for teeth

  var
    lowerPoints, upperPoints: array[crownSides, tuple[x, y: float]]

  # Get evenly spaced points on the lower and upper circles,
  # use Nim's math module for that
  for i in 0..<crownSides:
    let multiplier = i.float
    # Formulas are for 2D space, good enough for 3D since height is always same
    lowerPoints[i] = (
      x: lowerRadius * cos(centerAngle * multiplier),
      y: lowerRadius * sin(centerAngle * multiplier),
    )
    upperPoints[i] = (
      x: upperRadius * cos(centerAngle * multiplier),
      y: upperRadius * sin(centerAngle * multiplier),
    )

  initWindow(800, 600, "[nim]RaylibNow!")  # Open window

  var camera = Camera(
    position: (5.0, 8.0, 10.0),  # Camera position
    target: (0.0, 0.0, 0.0),     # Camera target it looks-at
    up: (0.0, 1.0, 0.0),         # Camera up vector (rotation over its axis)
    fovy: 45.0,                  # Camera field-of-view apperture in Y (degrees)
    projection: Perspective      # Defines projection type, see CameraProjection
  )
  camera.setCameraMode(Orbital)  # Several modes available, see CameraMode

  var pause = false              # Pausing the game will stop animation

  setTargetFPS(60)               # Set the game to run at 60 frames per second

  # Wait for Esc key press or when the window is closed
  while not windowShouldClose():
    if not pause:
      camera.addr.updateCamera   # Rotate camera

    if isKeyPressed(Space):      # Pressing Space will stop/resume animation
      pause = not pause

    beginDrawing:                # Use drawing functions inside this block
      clearBackground(RayWhite)  # Set background color

      beginMode3D(camera):       # Use 3D drawing functions inside this block
        drawGrid(10, 1.0)

        for i in 0..<crownSides:
          # Define 5 points:
          # - Current lower circle point
          # - Current upper circle point
          # - Next lower circle point
          # - Next upper circle point
          # - Point for peak of crown tooth
          let
            nexti = if i == crownSides - 1: 0 else: i + 1
            lowerCur: Vector3 = (lowerPoints[i].x, 0.0, lowerPoints[i].y)
            upperCur: Vector3 = (upperPoints[i].x, mainHeight, upperPoints[i].y)
            lowerNext: Vector3 = (lowerPoints[nexti].x, 0.0, lowerPoints[nexti].y)
            upperNext: Vector3 = (upperPoints[nexti].x, mainHeight, upperPoints[nexti].y)
            tooth: Vector3 = (
              (upperCur.x + upperNext.x) / 2.0 * toothSkew,
              toothHeight,
              (upperCur.z + upperNext.z) / 2.0 * toothSkew
            )

          # Front polygon (clockwise order)
          drawTriangle3D(lowerCur, upperCur, upperNext, nimFg)
          drawTriangle3D(lowerCur, upperNext, lowerNext, nimFg)

          # Back polygon (counter-clockwise order)
          drawTriangle3D(lowerCur, upperNext, upperCur, nimBg)
          drawTriangle3D(lowerCur, lowerNext, upperNext, nimBg)

          # Wire line for polygons
          drawLine3D(lowerCur, upperCur, Gray)

          # Crown tooth front triangle (clockwise order)
          drawTriangle3D(upperCur, tooth, upperNext, nimFg)

          # Crown tooth back triangle (counter-clockwise order)
          drawTriangle3D(upperNext, tooth, upperCur, nimBg)

      block text:
        block:
          let
            text = "I AM NIM"
            fontSize = 60
            textWidth = measureText(text, fontSize)
            verticalPos = (getScreenHeight().float * 0.4).int
          drawText(
            text,
            (getScreenWidth() - textWidth) div 2,  # center
            (getScreenHeight() + verticalPos) div 2,
            fontSize,
            Black
          )
        block:
          let text =
            if pause: "Press Space to continue"
            else: "Press Space to pause"
          drawText(text, 10, 10, 20, Black)

  closeWindow()


block physics_demo:
  ## ******************************************************************************************
  ##
  ##    Physac - Physics demo
  ##
  ##    Copyright (c) 2016-2018 Victor Fisac
  ##
  ## ******************************************************************************************


  ##  Initialization
  ## --------------------------------------------------------------------------------------
  var screenWidth = 800
  var screenHeight = 450
  setConfigFlags(Msaa4xHint)
  initWindow(screenWidth, screenHeight, "Physac [raylib] - Physics demo")
  ##  Physac logo drawing position
  var logoX = screenWidth - measureText("Physac", 30) - 10
  var logoY = 15
  var needsReset: bool = false
  ##  Initialize physics and default physics bodies
  initPhysics()
  ##  Create floor rectangle physics body
  var floor = createPhysicsBodyRectangle((screenWidth.float/2.0, screenHeight.float), 500.0, 100.0, 10.0)
  floor.enabled = false
  ##  Disable body state to convert it to static (no dynamics, but collisions)
  ##  Create obstacle circle physics body
  var circle = createPhysicsBodyCircle((screenWidth.float/2.0, screenHeight.float/2.0), 45.0, 10.0)
  circle.enabled = false
  ##  Disable body state to convert it to static (no dynamics, but collisions)
  setTargetFPS(60)
  ##  Set our game to run at 60 frames-per-second
  ## --------------------------------------------------------------------------------------
  ##  Main game loop
  while not windowShouldClose(): ##  Detect window close button or ESC key
    ##  Update
    ## ----------------------------------------------------------------------------------
    ##  Delay initialization of variables due to physics reset async
    updatePhysics()
    if needsReset:
      floor = createPhysicsBodyRectangle((screenWidth.float/2.0, screenHeight.float), 500.0, 100.0, 10.0)
      floor.enabled = false
      circle = createPhysicsBodyCircle((screenWidth.float/2.0, screenHeight.float/2.0), 45.0, 10.0)
      circle.enabled = false
      needsReset = false
    if isKeyPressed(R):
      resetPhysics()
      needsReset = true
    if isMouseButtonPressed(LeftButton):
      discard createPhysicsBodyPolygon(getMousePosition(), getRandomValue(20, 80).float,
                                       getRandomValue(3, 8), 10.0)
    elif isMouseButtonPressed(RightButton): ##  Destroy falling physics bodies
      discard createPhysicsBodyCircle(getMousePosition(), getRandomValue(10, 45).float, 10.0)
    var bodiesCount = getPhysicsBodiesCount()
    for i in countdown(bodiesCount, 0):
      var body: PhysicsBody = getPhysicsBody(i)
      if body != nil and (body.position.y.int > screenHeight * 2):
        destroyPhysicsBody(body)
    ## ----------------------------------------------------------------------------------
    ##  Draw
    ## ----------------------------------------------------------------------------------
    beginDrawing()
    clearBackground(Black)
    drawFPS(screenWidth - 90, screenHeight - 30)
    ##  Draw created physics bodies
    bodiesCount = getPhysicsBodiesCount()
    for i in 0..<bodiesCount:
      var body: PhysicsBody = getPhysicsBody(i)
      if body != nil:
        var vertexCount = getPhysicsShapeVerticesCount(i)
        for j in 0..<vertexCount:
          ##  Get physics bodies shape vertices to draw lines
          ##  Note: GetPhysicsShapeVertex() already calculates rotation transformations
          var vertexA: Vector2 = getPhysicsShapeVertex(body, j)
          var jj = (if ((j + 1) < vertexCount): (j + 1) else: 0)
          ##  Get next vertex or first to close the shape
          var vertexB: Vector2 = getPhysicsShapeVertex(body, jj)
          drawLineV(vertexA, vertexB, Green)
          ##  Draw a line between two vertex positions
    drawText("Left mouse button to create a polygon", 10, 10, 10, White)
    drawText("Right mouse button to create a circle", 10, 25, 10, White)
    drawText("Press \'R\' to reset example", 10, 40, 10, White)
    drawText("Physac", logoX, logoY, 30, White)
    drawText("Powered by", logoX + 50, logoY - 7, 10, White)
    endDrawing()
  ## ----------------------------------------------------------------------------------
  ##  De-Initialization
  ## --------------------------------------------------------------------------------------
  closePhysics()
  ##  Unitialize physics
  closeWindow()
  ##  Close window and OpenGL context
  ## --------------------------------------------------------------------------------------


block physics_friction:
  ## ******************************************************************************************
  ##
  ##    Physac - Physics friction
  ##
  ##    Copyright (c) 2016-2018 Victor Fisac
  ##
  ## ******************************************************************************************


  ##  Initialization
  ## --------------------------------------------------------------------------------------
  var screenWidth = 800
  var screenHeight = 450
  setConfigFlags(Msaa4xHint)
  initWindow(screenWidth, screenHeight, "Physac [raylib] - Physics friction")

  ##  Physac logo drawing position
  var logoX = screenWidth - measureText("Physac", 30) - 10
  var logoY = 15
  ##  Initialize physics and default physics bodies
  initPhysics()
  ##  Create floor rectangle physics body
  var floor = createPhysicsBodyRectangle(
    Vector2(x: (float) screenWidth div 2, y: screenHeight.float),
    screenWidth.float, 100, 10)
  floor.enabled = false
  ##  Disable body state to convert it to static (no dynamics, but collisions)
  var wall = createPhysicsBodyRectangle(Vector2(x: screenWidth.float/2.0, y: screenHeight.float*0.8), 10, 80, 10)
  wall.enabled = false
  ##  Disable body state to convert it to static (no dynamics, but collisions)
  ##  Create left ramp physics body
  var rectLeft = createPhysicsBodyRectangle(Vector2(x: 25, y: (float) screenHeight - 5), 250, 250, 10)
  rectLeft.enabled = false
  ##  Disable body state to convert it to static (no dynamics, but collisions)
  setPhysicsBodyRotation(rectLeft, degToRad(30.0))
  ##  Create right ramp  physics body
  var rectRight = createPhysicsBodyRectangle(
    Vector2(x: (float) screenWidth - 25, y: (float) screenHeight - 5), 250, 250, 10)
  rectRight.enabled = false
  ##  Disable body state to convert it to static (no dynamics, but collisions)
  setPhysicsBodyRotation(rectRight, degToRad(330.0))
  ##  Create dynamic physics bodies
  var bodyA = createPhysicsBodyRectangle(Vector2(x: 35, y: screenHeight.float * 0.6), 40, 40, 10)
  bodyA.staticFriction = 0.1
  bodyA.dynamicFriction = 0.1
  setPhysicsBodyRotation(bodyA, degToRad(30.0))
  var bodyB = createPhysicsBodyRectangle(Vector2(x: (float) screenWidth - 35, y: screenHeight.float * 0.6), 40, 40, 10)
  bodyB.staticFriction = 1.0
  bodyB.dynamicFriction = 1.0
  setPhysicsBodyRotation(bodyB, degToRad(330.0))
  setTargetFPS(60)
  ##  Set our game to run at 60 frames-per-second
  ## --------------------------------------------------------------------------------------
  ##  Main game loop
  while not windowShouldClose(): ##  Detect window close button or ESC key
    ##  Update
    ## ----------------------------------------------------------------------------------
    updatePhysics()
    if isKeyPressed(R):
      ##  Reset dynamic physics bodies position, velocity and rotation
      bodyA.position = Vector2(x: 35, y: screenHeight.float * 0.6)
      bodyA.velocity = Vector2(x: 0, y: 0)
      bodyA.angularVelocity = 0
      setPhysicsBodyRotation(bodyA, degToRad(30.0))
      bodyB.position = Vector2(x: (float) screenWidth - 35, y: screenHeight.float * 0.6)
      bodyB.velocity = Vector2(x: 0, y: 0)
      bodyB.angularVelocity = 0
      setPhysicsBodyRotation(bodyB, degToRad(330.0))
    beginDrawing()
    clearBackground(Black)
    drawFPS(screenWidth - 90, screenHeight - 30)
    ##  Draw created physics bodies
    var bodiesCount: int32 = getPhysicsBodiesCount()
    var i: int32 = 0
    while i < bodiesCount:
      var body: PhysicsBody = getPhysicsBody(i)
      if body != nil:
        var vertexCount: int32 = getPhysicsShapeVerticesCount(i)
        var j: int32 = 0
        while j < vertexCount:
          ##  Get physics bodies shape vertices to draw lines
          ##  Note: GetPhysicsShapeVertex() already calculates rotation transformations
          var vertexA: Vector2 = getPhysicsShapeVertex(body, j)
          var jj: int32 = (if ((j + 1) < vertexCount): (j + 1) else: 0)
          ##  Get next vertex or first to close the shape
          var vertexB: Vector2 = getPhysicsShapeVertex(body, jj)
          drawLineV(vertexA, vertexB, Green)
          ##  Draw a line between two vertex positions
          inc(j)
      inc(i)
    drawRectangle(0, screenHeight - 49, screenWidth, 49, Black)
    drawText("Friction amount",
             (screenWidth - measureText("Friction amount", 30)) div 2, 75, 30, White)
    drawText("0.1", bodyA.position.x.int - measureText("0.1", 20) div 2,
             bodyA.position.y.int - 7, 20, White)
    drawText("1", bodyB.position.x.int - measureText("1", 20) div 2, bodyB.position.y.int - 7, 20,
             White)
    drawText("Press \'R\' to reset example", 10, 10, 10, White)
    drawText("Physac", logoX, logoY, 30, White)
    drawText("Powered by", logoX + 50, logoY - 7, 10, White)
    endDrawing()
  ## ----------------------------------------------------------------------------------
  ##  De-Initialization
  ## --------------------------------------------------------------------------------------
  closePhysics()
  ##  Unitialize physics
  closeWindow()
  ##  Close window and OpenGL context
  ## --------------------------------------------------------------------------------------


block physics_movement:
  ## ******************************************************************************************
  ##
  ##    Physac - Physics movement
  ##
  ##    Copyright (c) 2016-2018 Victor Fisac
  ##
  ## ******************************************************************************************


  const
    Velocity = 0.5

  ##  Initialization
  ## --------------------------------------------------------------------------------------
  var screenWidth = 800
  var screenHeight = 450
  setConfigFlags(Msaa4xHint)
  initWindow(screenWidth, screenHeight, "Physac [raylib] - Physics movement")
  ##  Physac logo drawing position
  var logoX = screenWidth - measureText("Physac", 30) - 10
  var logoY = 15
  ##  Initialize physics and default physics bodies
  initPhysics()
  ##  Create floor and walls rectangle physics body
  var
    floor = createPhysicsBodyRectangle(
      Vector2(x: (float) screenWidth div 2, y: screenHeight.float),
      screenWidth.float, 100, 10
    )
    platformLeft = createPhysicsBodyRectangle(
      Vector2(x: screenWidth.float * 0.25, y: screenHeight.float * 0.6),
      screenWidth.float * 0.25, 10, 10
    )
    platformRight = createPhysicsBodyRectangle(
      Vector2(x: screenWidth.float * 0.75, y: screenHeight.float * 0.6),
      screenWidth.float * 0.25, 10, 10
    )
    wallLeft = createPhysicsBodyRectangle(
      Vector2(x: -5, y: screenHeight.float * 0.5),
      10.0, screenHeight.float, 10.0
    )
    wallRight = createPhysicsBodyRectangle(
      Vector2(x: (float) screenWidth + 5, y: screenHeight.float * 0.5),
      10.0, screenHeight.float, 10.0
    )
  ##  Disable dynamics to floor and walls physics bodies
  floor.enabled = false
  platformLeft.enabled = false
  platformRight.enabled = false
  wallLeft.enabled = false
  wallRight.enabled = false
  ##  Create movement physics body
  var
    body = createPhysicsBodyRectangle(
      Vector2(x: (float) screenWidth div 2, y: (float) screenHeight div 2),
      50, 50, 1
    )
  body.freezeOrient = true ##  Constrain body rotation to avoid little collision torque amounts
  setTargetFPS(60)
  ##  Set our game to run at 60 frames-per-second
  ## --------------------------------------------------------------------------------------
  ##  Main game loop
  while not windowShouldClose(): ##  Detect window close button or ESC key
    ##  Update
    ## ----------------------------------------------------------------------------------
    updatePhysics()
    if isKeyPressed(R):
      ##  Reset movement physics body position, velocity and rotation
      body.position = (screenWidth.float / 2.0, screenHeight.float / 2.0)
      body.velocity = (0.0, 0.0)
      setPhysicsBodyRotation(body, 0)
    if isKeyDown(Right):
      body.velocity.x = Velocity
    elif isKeyDown(Left):  ##  Vertical movement input checking if player physics body is grounded
      body.velocity.x = -Velocity
    if isKeyDown(Up) and body.isGrounded:
      body.velocity.y = -(Velocity * 4.0)
    beginDrawing:
      clearBackground(Black)
      drawFPS(screenWidth - 90, screenHeight - 30)
      ##  Draw created physics bodies
      var bodiesCount = getPhysicsBodiesCount()
      var i = 0
      while i < bodiesCount:
        var body: PhysicsBody = getPhysicsBody(i)
        var vertexCount = getPhysicsShapeVerticesCount(i)
        var j = 0
        while j < vertexCount:
          ##  Get physics bodies shape vertices to draw lines
          ##  Note: GetPhysicsShapeVertex() already calculates rotation transformations
          var vertexA: Vector2 = getPhysicsShapeVertex(body, j)
          var jj = (if ((j + 1) < vertexCount): (j + 1) else: 0)
          ##  Get next vertex or first to close the shape
          var vertexB: Vector2 = getPhysicsShapeVertex(body, jj)
          drawLineV(vertexA, vertexB, Green)
          ##  Draw a line between two vertex positions
          inc(j)
        inc(i)
      drawText("Use \'ARROWS\' to move player", 10, 10, 10, White)
      drawText("Press \'R\' to reset example", 10, 30, 10, White)
      drawText("Physac", logoX, logoY, 30, White)
      drawText("Powered by", logoX + 50, logoY - 7, 10, White)
  ## ----------------------------------------------------------------------------------
  ##  De-Initialization
  ## --------------------------------------------------------------------------------------
  closePhysics()
  ##  Unitialize physics
  closeWindow()
  ##  Close window and OpenGL context
  ## --------------------------------------------------------------------------------------


block physics_restitution:
  ## ******************************************************************************************
  ##
  ##    Physac - Physics restitution
  ##
  ##    Copyright (c) 2016-2018 Victor Fisac
  ##
  ## ******************************************************************************************


  ##  Initialization
  ## --------------------------------------------------------------------------------------
  var screenWidth = 800
  var screenHeight = 450
  setConfigFlags(Msaa_4x_Hint)
  initWindow(screenWidth, screenHeight, "Physac [raylib] - Physics restitution")
  ##  Physac logo drawing position
  var logoX = screenWidth - measureText("Physac", 30) - 10
  var logoY = 15
  ##  Initialize physics and default physics bodies
  initPhysics()
  ##  Create floor rectangle physics body
  var
    floor = createPhysicsBodyRectangle(
      Vector2(x: (float) screenWidth div 2, y: screenHeight.float),
      screenWidth.float, 100, 10
    )
  floor.enabled = false
  ##  Disable body state to convert it to static (no dynamics, but collisions)
  floor.restitution = 1
  ##  Create circles physics body
  var
    circleA = createPhysicsBodyCircle(
      Vector2(x: screenWidth.float * 0.25, y: screenHeight.float / 2.0),
      30, 10
    )
    circleB = createPhysicsBodyCircle(
      Vector2(x: screenWidth.float * 0.5, y: screenHeight.float / 2.0),
      30, 10
    )
    circleC = createPhysicsBodyCircle(
      Vector2(x: screenWidth.float * 0.75, y: screenHeight.float / 2.0),
      30, 10
    )
  circleA.restitution = 0
  circleB.restitution = 0.5
  circleC.restitution = 1
  ##  Restitution demo needs a very tiny physics time step for a proper simulation
  setPhysicsTimeStep(1.0 / 60.0 / 100 * 1000)
  setTargetFPS(60)
  ##  Set our game to run at 60 frames-per-second
  ## --------------------------------------------------------------------------------------
  ##  Main game loop
  while not windowShouldClose(): ##  Detect window close button or ESC key
    ##  Update
    ## ----------------------------------------------------------------------------------
    updatePhysics()
    if isKeyPressed(R):
      ##  Reset circles physics bodies position and velocity
      circleA.position = Vector2(x: screenWidth.float * 0.25, y: screenHeight.float / 2.0)
      circleB.position = Vector2(x: screenWidth.float * 0.5, y: screenHeight.float / 2.0)
      circleC.position = Vector2(x: screenWidth.float * 0.75, y: screenHeight.float / 2.0)
      circleA.velocity = (0.0, 0.0)
      circleB.velocity = (0.0, 0.0)
      circleC.velocity = (0.0, 0.0)
    beginDrawing:
      clearBackground(Black)
      drawFPS(screenWidth - 90, screenHeight - 30)
      ##  Draw created physics bodies
      var bodiesCount = getPhysicsBodiesCount()
      var i = 0
      while i < bodiesCount:
        var body: PhysicsBody = getPhysicsBody(i)
        var vertexCount = getPhysicsShapeVerticesCount(i)
        var j = 0
        while j < vertexCount:
          ##  Get physics bodies shape vertices to draw lines
          ##  Note: GetPhysicsShapeVertex() already calculates rotation transformations
          var vertexA: Vector2 = getPhysicsShapeVertex(body, j)
          var jj = (if ((j + 1) < vertexCount): (j + 1) else: 0)
          ##  Get next vertex or first to close the shape
          var vertexB: Vector2 = getPhysicsShapeVertex(body, jj)
          drawLineV(vertexA, vertexB, Green)
          ##  Draw a line between two vertex positions
          inc(j)
        inc(i)
      drawText("Restitution amount",
               (screenWidth - measureText("Restitution amount", 30)) div 2, 75, 30, White)
      drawText("0", circleA.position.x.int - measureText("0", 20) div 2,
               circleA.position.y.int - 7, 20, White)
      drawText("0.5", circleB.position.x.int - measureText("0.5", 20) div 2,
               circleB.position.y.int - 7, 20, White)
      drawText("1", circleC.position.x.int - measureText("1", 20) div 2,
               circleC.position.y.int - 7, 20, White)
      drawText("Press \'R\' to reset example", 10, 10, 10, White)
      drawText("Physac", logoX, logoY, 30, White)
      drawText("Powered by", logoX + 50, logoY - 7, 10, White)
  ## ----------------------------------------------------------------------------------
  ##  De-Initialization
  ## --------------------------------------------------------------------------------------
  destroyPhysicsBody(circleA)
  destroyPhysicsBody(circleB)
  destroyPhysicsBody(circleC)
  destroyPhysicsBody(floor)
  closePhysics()
  ##  Unitialize physics
  closeWindow()
  ##  Close window and OpenGL context
  ## --------------------------------------------------------------------------------------


block physics_shatter:
  ## ******************************************************************************************
  ##
  ##    Physac - Body shatter
  ##
  ##    Copyright (c) 2016-2018 Victor Fisac
  ##
  ## ******************************************************************************************


  ##  Initialization
  ## --------------------------------------------------------------------------------------
  var screenWidth = 800
  var screenHeight = 450
  setConfigFlags(Msaa_4x_Hint)
  initWindow(screenWidth, screenHeight, "Physac [raylib] - Body shatter")
  ##  Physac logo drawing position
  var logoX = screenWidth - measureText("Physac", 30) - 10
  var logoY = 15
  var needsReset: bool = false
  ##  Initialize physics and default physics bodies
  initPhysics()
  setPhysicsGravity(0, 0)
  ##  Create random polygon physics body to shatter
  discard createPhysicsBodyPolygon(
    Vector2(x: (float) screenWidth div 2, y: (float) screenHeight div 2),
    getRandomValue(80, 200).float, getRandomValue(3, 8), 10.0
  )
  setTargetFPS(60)
  ##  Set our game to run at 60 frames-per-second
  ## --------------------------------------------------------------------------------------
  ##  Main game loop
  while not windowShouldClose(): ##  Detect window close button or ESC key
    ##  Update
    updatePhysics()
    ## ----------------------------------------------------------------------------------
    ##  Delay initialization of variables due to physics reset asynchronous
    if needsReset:
      ##  Create random polygon physics body to shatter
      discard createPhysicsBodyPolygon(
        Vector2(x: (float) screenWidth div 2, y: (float) screenHeight div 2),
        getRandomValue(80, 200).float, getRandomValue(3, 8), 10.0
      )
      needsReset = false
    if isKeyPressed(R):
      resetPhysics()
      needsReset = true
    if isMouseButtonPressed(LeftButton):
      ##  Note: some values need to be stored in variables due to asynchronous changes during main thread
      var count = getPhysicsBodiesCount()
      var i = count - 1
      while i >= 0:
        var currentBody: PhysicsBody = getPhysicsBody(i)
        if currentBody != nil:
          physicsShatter(currentBody, getMousePosition(), 10.0 / currentBody.inverseMass)
        dec(i)
    beginDrawing:
      clearBackground(Black)
      ##  Draw created physics bodies
      var bodiesCount = getPhysicsBodiesCount()
      var i = 0
      while i < bodiesCount:
        var currentBody: PhysicsBody = getPhysicsBody(i)
        var vertexCount = getPhysicsShapeVerticesCount(i)
        var j = 0
        while j < vertexCount:
          ##  Get physics bodies shape vertices to draw lines
          ##  Note: GetPhysicsShapeVertex() already calculates rotation transformations
          var vertexA: Vector2 = getPhysicsShapeVertex(currentBody, j)
          var jj = (if ((j + 1) < vertexCount): (j + 1) else: 0)
          ##  Get next vertex or first to close the shape
          var vertexB: Vector2 = getPhysicsShapeVertex(currentBody, jj)
          drawLineV(vertexA, vertexB, Green)
          ##  Draw a line between two vertex positions
          inc(j)
        inc(i)
      drawText("Left mouse button in polygon area to shatter body\nPress \'R\' to reset example",
               10, 10, 10, White)
      drawText("Physac", logoX, logoY, 30, White)
      drawText("Powered by", logoX + 50, logoY - 7, 10, White)
  ## ----------------------------------------------------------------------------------
  ##  De-Initialization
  ## --------------------------------------------------------------------------------------
  closePhysics()
  ##  Unitialize physics
  closeWindow()
  ##  Close window and OpenGL context
  ## --------------------------------------------------------------------------------------


block shaders_basic_lighting:
  # ******************************************************************************************
  #
  #    raylib [shaders] example - basic lighting
  #
  #    NOTE: This example requires raylib OpenGL 3.3 or ES2 versions for shaders support,
  #          OpenGL 1.1 does not support shaders, recompile raylib to OpenGL 3.3 version.
  #
  #    NOTE: Shaders used in this example are #version 330 (OpenGL 3.3).
  #
  #    This example has been created using raylib 2.5 (www.raylib.com)
  #    raylib is licensed under an unmodified zlib/libpng license (View raylib.h for details)
  #
  #    Example contributed by Chris Camacho (@codifies) and reviewed by Ramon Santamaria (@raysan5)
  #
  #    Chris Camacho (@codifies -  http://bedroomcoders.co.uk/) notes:
  #
  #    This is based on the PBR lighting example, but greatly simplified to aid learning...
  #    actually there is very little of the PBR example left!
  #    When I first looked at the bewildering complexity of the PBR example I feaRed
  #    I would never understand how I could do simple lighting with raylib however its
  #    a testement to the authors of raylib (including rlights.h) that the example
  #    came together fairly quickly.
  #
  #    Copyright (c) 2019 Chris Camacho (@codifies) and Ramon Santamaria (@raysan5)
  #    Converted in 2021 by greenfork
  #
  # ******************************************************************************************


  const GLSL_VERSION = 330

  ##  Initialization
  ## --------------------------------------------------------------------------------------
  var screenWidth = 800
  var screenHeight = 450
  setConfigFlags(Msaa_4x_Hint) ##  Enable Multi Sampling Anti Aliasing 4x (if available)
  initWindow(screenWidth, screenHeight, "raylib [shaders] example - basic lighting")
  ##  Define the camera to look into our 3d world
  var camera = Camera()
  camera.position = (2.0, 2.0, 6.0) ##  Camera position
  camera.target = (0.0, 0.5, 0.0) ##  Camera looking at point
  camera.up = (0.0, 1.0, 0.0) ##  Camera up vector (rotation towards target)
  camera.fovy = 45.0 ##  Camera field-of-view Y
  camera.projection = Perspective
  ##  Camera mode type
  ##  Load models
  var modelA: Model = loadModelFromMesh(genMeshTorus(0.4, 1.0, 16, 32))
  var modelB: Model = loadModelFromMesh(genMeshCube(1.0, 1.0, 1.0))
  var modelC: Model = loadModelFromMesh(genMeshSphere(0.5, 32, 32))

  ##  Load models texture
  var texture: Texture = loadTexture("resources/texel_checker.png")
  ##  Assign texture to default model material
  modelA.materials[0].maps[int(Albedo)].texture = texture
  modelB.materials[0].maps[int(Albedo)].texture = texture
  modelC.materials[0].maps[int(Albedo)].texture = texture
  var shader: Shader = loadShader(
    textFormat("resources/shaders/glsl%i/base_lighting.vs", GLSL_VERSION),
    textFormat("resources/shaders/glsl%i/lighting.fs", GLSL_VERSION)
  )
  ##  Get some shader locations
  shader.locs[int(Matrix_Model)] = getShaderLocation(shader, "matModel")
  shader.locs[int(Vector_View)] = getShaderLocation(shader, "viewPos")
  ##  ambient light level
  var ambientLoc = getShaderLocation(shader, "ambient")
  var uniformLocations = [0.2.cfloat, 0.2, 0.2, 1.0]
  setShaderValue(shader, ambientLoc, uniformLocations.addr, VEC4)
  var angle = 6.282
  ##  All models use the same shader
  modelA.materials[0].shader = shader
  modelB.materials[0].shader = shader
  modelC.materials[0].shader = shader
  ##  Using 4 point lights, White, Red, Green and Blue
  var lights: array[MAX_LIGHTS, Light]
  lights[0] = createLight(LightType.Point, (4.0, 2.0, 4.0), vector3Zero(), White, shader)
  lights[1] = createLight(LightType.Point, (4.0, 2.0, 4.0), vector3Zero(), Red, shader)
  lights[2] = createLight(LightType.Point, (0.0, 4.0, 2.0), vector3Zero(), Green, shader)
  lights[3] = createLight(LightType.Point, (0.0, 4.0, 2.0), vector3Zero(), Blue, shader)
  setCameraMode(camera, Orbital)
  ##  Set an orbital camera mode
  setTargetFPS(60) ##  Set our game to run at 60 frames-per-second

  ## --------------------------------------------------------------------------------------
  ##  Main game loop

  while not windowShouldClose(): ##  Detect window close button or ESC key
    ##  Update
    ## ----------------------------------------------------------------------------------
    if isKeyPressed(W):
      lights[0].enabled = not lights[0].enabled
    if isKeyPressed(R):
      lights[1].enabled = not lights[1].enabled
    if isKeyPressed(G):
      lights[2].enabled = not lights[2].enabled
    if isKeyPressed(B):
      lights[3].enabled = not lights[3].enabled
    updateCamera(addr(camera))
    ##  Update camera
    ##  Make the lights do differing orbits
    angle -= 0.02
    lights[0].position.x = cos(angle) * 4.0
    lights[0].position.z = sin(angle) * 4.0
    lights[1].position.x = cos(-(angle * 0.6)) * 4.0
    lights[1].position.z = sin(-(angle * 0.6)) * 4.0
    lights[2].position.y = cos(angle * 0.2) * 4.0
    lights[2].position.z = sin(angle * 0.2) * 4.0
    lights[3].position.y = cos(-(angle * 0.35)) * 4.0
    lights[3].position.z = sin(-(angle * 0.35)) * 4.0
    updateLightValues(shader, lights[0])
    updateLightValues(shader, lights[1])
    updateLightValues(shader, lights[2])
    updateLightValues(shader, lights[3])
    ##  Rotate the torus
    modelA.transform = modelA.transform * rotateX(-0.025)
    modelA.transform = modelA.transform * rotateZ(0.012)
    ##  Update the light shader with the camera view position
    var cameraPos: array[3, cfloat] = [camera.position.x, camera.position.y,
                                  camera.position.z]
    setShaderValue(shader, shader.locs[int(Vector_View)], cameraPos.addr, VEC3)
    ## ----------------------------------------------------------------------------------
    ##  Draw
    ## ----------------------------------------------------------------------------------
    beginDrawing:
      clearBackground(Raywhite)
      beginMode3D(camera):
        ##  Draw the three models
        drawModel(modelA, vector3Zero(), 1.0, White)
        drawModel(modelB, (-1.6, 0.0, 0.0), 1.0, White)
        drawModel(modelC, (1.6, 0.0, 0.0), 1.0, White)
        ##  Draw markers to show where the lights are
        if lights[0].enabled:
          drawSphereEx(lights[0].position, 0.2, 8, 8, White)
        if lights[1].enabled:
          drawSphereEx(lights[1].position, 0.2, 8, 8, Red)
        if lights[2].enabled:
          drawSphereEx(lights[2].position, 0.2, 8, 8, Green)
        if lights[3].enabled:
          drawSphereEx(lights[3].position, 0.2, 8, 8, Blue)
        drawGrid(10, 1.0)
      drawFPS(10, 10)
      drawText("Use keys RGBW to toggle lights", 10, 30, 20, Darkgray)

  ## ----------------------------------------------------------------------------------
  ##  De-Initialization
  ## --------------------------------------------------------------------------------------
  unloadModel(modelA)
  ##  Unload the modelA
  unloadModel(modelB)
  ##  Unload the modelB
  unloadModel(modelC)
  ##  Unload the modelC
  unloadTexture(texture)
  ##  Unload the texture
  unloadShader(shader)
  ##  Unload shader
  closeWindow()
  ##  Close window and OpenGL context
  ## --------------------------------------------------------------------------------------


block shaders_custom_uniform:
  # ******************************************************************************************
  #
  #    raylib [shaders] example - Apply a postprocessing shader and connect a custom uniform variable
  #
  #    NOTE: This example requires raylib OpenGL 3.3 or ES2 versions for shaders support,
  #          OpenGL 1.1 does not support shaders, recompile raylib to OpenGL 3.3 version.
  #
  #    NOTE: Shaders used in this example are #version 330 (OpenGL 3.3), to test this example
  #          on OpenGL ES 2.0 platforms (Android, Raspberry Pi, HTML5), use #version 100 shaders
  #          raylib comes with shaders ready for both versions, check raylib/shaders install folder
  #
  #    This example has been created using raylib 1.3 (www.raylib.com)
  #    raylib is licensed under an unmodified zlib/libpng license (View raylib.h for details)
  #
  #    Copyright (c) 2015 Ramon Santamaria (@raysan5)
  #    Converted in 2021 by greenfork
  #
  # ******************************************************************************************


  const GLSL_VERSION = 330

  ##  Initialization
  ## --------------------------------------------------------------------------------------
  var screenWidth = 800
  var screenHeight = 450
  setConfigFlags(Msaa_4x_Hint)
  ##  Enable Multi Sampling Anti Aliasing 4x (if available)
  initWindow(screenWidth, screenHeight,
             "raylib [shaders] example - custom uniform variable")
  ##  Define the camera to look into our 3d world
  var camera = Camera()
  camera.position = (8.0, 8.0, 8.0)
  camera.target = (0.0, 1.5, 0.0)
  camera.up = (0.0, 1.0, 0.0)
  camera.fovy = 45.0
  camera.projection = Perspective
  var model: Model = loadModel("resources/models/barracks.obj")
  ##  Load OBJ model
  var texture: Texture2D = loadTexture("resources/models/barracks_diffuse.png")
  ##  Load model texture (diffuse map)
  model.materials[0].maps[int(Albedo)].texture = texture
  ##  Set model diffuse texture
  var position = Vector3()
  ##  Set model position
  ##  Load postprocessing shader
  ##  NOTE: Defining 0 (NULL) for vertex shader forces usage of internal default vertex shader
  var shader: Shader = loadShader(nil, textFormat("resources/shaders/glsl%i/swirl.fs",
      GLSL_VERSION))
  ##  Get variable (uniform) location on the shader to connect with the program
  ##  NOTE: If uniform variable could not be found in the shader, function returns -1
  var swirlCenterLoc = getShaderLocation(shader, "center")
  var swirlCenter: array[2, cfloat] = [(screenWidth div 2).cfloat, (screenHeight div 2).cfloat]
  ##  Create a RenderTexture2D to be used for render to texture
  var target: RenderTexture2D = loadRenderTexture(screenWidth, screenHeight)
  ##  Setup orbital camera
  setCameraMode(camera, Orbital)
  ##  Set an orbital camera mode
  setTargetFPS(60)
  ##  Set our game to run at 60 frames-per-second
  ## --------------------------------------------------------------------------------------
  ##  Main game loop
  while not windowShouldClose(): ##  Detect window close button or ESC key
    ##  Update
    ## ----------------------------------------------------------------------------------
    var mousePosition: Vector2 = getMousePosition()
    swirlCenter[0] = mousePosition.x
    swirlCenter[1] = screenHeight.float - mousePosition.y
    ##  Send new value to the shader to be used on drawing
    setShaderValue(shader, swirlCenterLoc, swirlCenter.addr, Vec2)
    updateCamera(addr(camera))
    ##  Update camera
    ## ----------------------------------------------------------------------------------
    ##  Draw
    ## ----------------------------------------------------------------------------------
    beginDrawing:
      clearBackground(Raywhite)
      beginTextureMode(target): ##  Enable drawing to texture
        clearBackground(Raywhite) ##  Clear texture background
        beginMode3D(camera): ##  Begin 3d mode drawing
          drawModel(model, position, 0.5, White) ##  Draw 3d model with texture
          drawGrid(10, 1.0) ##  Draw a grid
        ##  End 3d mode drawing, returns to orthographic 2d mode
        drawText("TEXT DRAWN IN RENDER TEXTURE", 200, 10, 30, Red)
      ##  End drawing to texture (now we have a texture available for next passes)
      beginShaderMode(shader):
        # NOTE: Render texture must be y-flipped due to default OpenGL coordinates (left-bottom)
        drawTextureRec(
          target.texture,
          Rectangle(x: 0, y: 0, width: target.texture.width.float, height: -target.texture.height.float),
          Vector2(x: 0, y: 0),
          White
        )
      ##  Draw some 2d text over drawn texture
      drawText("(c) Barracks 3D model by Alberto Cano", screenWidth - 220,
               screenHeight - 20, 10, Gray)
      drawFPS(10, 10)
  ## ----------------------------------------------------------------------------------
  ##  De-Initialization
  ## --------------------------------------------------------------------------------------
  unloadShader(shader)
  ##  Unload shader
  unloadTexture(texture)
  ##  Unload texture
  unloadModel(model)
  ##  Unload model
  unloadRenderTexture(target)
  ##  Unload render texture
  closeWindow()
  ##  Close window and OpenGL context
  ## --------------------------------------------------------------------------------------


block shaders_eratosthenes:
  # ******************************************************************************************
  #
  #    raylib [shaders] example - Sieve of Eratosthenes
  #
  #    Sieve of Eratosthenes, the earliest known (ancient Greek) prime number sieve.
  #
  #    "Sift the twos and sift the threes,
  #     The Sieve of Eratosthenes.
  #     When the multiples subLime,
  #     the numbers that are left are prime."
  #
  #    NOTE: This example requires raylib OpenGL 3.3 or ES2 versions for shaders support,
  #          OpenGL 1.1 does not support shaders, recompile raylib to OpenGL 3.3 version.
  #
  #    NOTE: Shaders used in this example are #version 330 (OpenGL 3.3).
  #
  #    This example has been created using raylib 2.5 (www.raylib.com)
  #    raylib is licensed under an unmodified zlib/libpng license (View raylib.h for details)
  #
  #    Example contributed by ProfJski and reviewed by Ramon Santamaria (@raysan5)
  #
  #    Copyright (c) 2019 ProfJski and Ramon Santamaria (@raysan5)
  #    Converted in 2021 by greenfork
  #
  # ******************************************************************************************


  const GLSL_VERSION = 330

  ##  Initialization
  ## --------------------------------------------------------------------------------------
  var screenWidth = 800
  var screenHeight = 450
  initWindow(screenWidth, screenHeight,
             "raylib [shaders] example - Sieve of Eratosthenes")
  var target: RenderTexture2D = loadRenderTexture(screenWidth, screenHeight)
  ##  Load Eratosthenes shader
  ##  NOTE: Defining 0 (NULL) for vertex shader forces usage of internal default vertex shader
  var shader: Shader = loadShader(nil, textFormat(
      "resources/shaders/glsl%i/eratosthenes.fs", GLSL_VERSION))
  setTargetFPS(60)
  ##  Set our game to run at 60 frames-per-second
  ## --------------------------------------------------------------------------------------
  ##  Main game loop
  while not windowShouldClose(): ##  Detect window close button or ESC key
    ##  Update
    ## ----------------------------------------------------------------------------------
    ##  Nothing to do here, everything is happening in the shader
    ## ----------------------------------------------------------------------------------
    ##  Draw
    ## ----------------------------------------------------------------------------------
    beginDrawing:
      clearBackground(Raywhite)
      beginTextureMode(target):
        ##  Enable drawing to texture
        clearBackground(Black)
        ##  Clear the render texture
        ##  Draw a rectangle in shader mode to be used as shader canvas
        ##  NOTE: Rectangle uses font White character texture coordinates,
        ##  so shader can not be applied here directly because input vertexTexCoord
        ##  do not represent full screen coordinates (space where want to apply shader)
        drawRectangle(0, 0, getScreenWidth(), getScreenHeight(), Black)
      ##  End drawing to texture (now we have a Blank texture available for the shader)
      beginShaderMode(shader):
        ##  NOTE: Render texture must be y-flipped due to default OpenGL coordinates (left-bottom)
        drawTextureRec(
          target.texture,
          Rectangle(x: 0, y: 0, width: target.texture.width.float, height: -target.texture.height.float),
          Vector2(x: 0.0, y: 0.0),
          White
        )
  ## ----------------------------------------------------------------------------------
  ##  De-Initialization
  ## --------------------------------------------------------------------------------------
  unloadShader(shader)
  ##  Unload shader
  unloadRenderTexture(target)
  ##  Unload texture
  closeWindow()
  ##  Close window and OpenGL context
  ## --------------------------------------------------------------------------------------


block shaders_fog:
  # ******************************************************************************************
  #
  #    raylib [shaders] example - fog
  #
  #    NOTE: This example requires raylib OpenGL 3.3 or ES2 versions for shaders support,
  #          OpenGL 1.1 does not support shaders, recompile raylib to OpenGL 3.3 version.
  #
  #    NOTE: Shaders used in this example are #version 330 (OpenGL 3.3).
  #
  #    This example has been created using raylib 2.5 (www.raylib.com)
  #    raylib is licensed under an unmodified zlib/libpng license (View raylib.h for details)
  #
  #    Example contributed by Chris Camacho (@chriscamacho) and reviewed by Ramon Santamaria (@raysan5)
  #
  #    Chris Camacho (@chriscamacho -  http://bedroomcoders.co.uk/) notes:
  #
  #    This is based on the PBR lighting example, but greatly simplified to aid learning...
  #    actually there is very little of the PBR example left!
  #    When I first looked at the bewildering complexity of the PBR example I feaRed
  #    I would never understand how I could do simple lighting with raylib however its
  #    a testement to the authors of raylib (including rlights.h) that the example
  #    came together fairly quickly.
  #
  #    Copyright (c) 2019 Chris Camacho (@chriscamacho) and Ramon Santamaria (@raysan5)
  #    Converted in 2021 by greenfork
  #
  # ******************************************************************************************


  const GLSL_VERSION = 330

  ##  Initialization
  ## --------------------------------------------------------------------------------------
  var screenWidth = 800
  var screenHeight = 450
  setConfigFlags(Msaa_4x_Hint)
  ##  Enable Multi Sampling Anti Aliasing 4x (if available)
  initWindow(screenWidth, screenHeight, "raylib [shaders] example - fog")
  ##  Define the camera to look into our 3d world
  var camera = Camera(
    position: (2.0, 2.0, 6.0),
    target: (0.0, 0.5, 0.0),
    up: (0.0, 1.0, 0.0),
    fovy: 45.0,
    projection: Perspective
  )
  ##  Load models and texture
  var modelA: Model = loadModelFromMesh(genMeshTorus(0.4, 1.0, 16, 32))
  var modelB: Model = loadModelFromMesh(genMeshCube(1.0, 1.0, 1.0))
  var modelC: Model = loadModelFromMesh(genMeshSphere(0.5, 32, 32))
  var texture: Texture = loadTexture("resources/texel_checker.png")
  ##  Assign texture to default model material
  modelA.materials[0].maps[int(Albedo)].texture = texture
  modelB.materials[0].maps[int(Albedo)].texture = texture
  modelC.materials[0].maps[int(Albedo)].texture = texture
  ##  Load shader and set up some uniforms
  var shader: Shader = loadShader(textFormat(
      "resources/shaders/glsl%i/base_lighting.vs", GLSL_VERSION), textFormat(
      "resources/shaders/glsl%i/fog.fs", GLSL_VERSION))
  shader.locs[int(Matrix_Model)] = getShaderLocation(shader, "matModel")
  shader.locs[int(Vector_View)] = getShaderLocation(shader, "viewPos")
  ##  Ambient light level
  var ambientLoc = getShaderLocation(shader, "ambient")
  var shaderPosition = [0.2.cfloat, 0.2, 0.2, 1.0]
  setShaderValue(shader, ambientLoc, shaderPosition.addr, VEC4)
  var fogDensity: cfloat = 0.15
  var fogDensityLoc = getShaderLocation(shader, "fogDensity")
  setShaderValue(shader, fogDensityLoc, addr(fogDensity), Float)
  ##  NOTE: All models share the same shader
  modelA.materials[0].shader = shader
  modelB.materials[0].shader = shader
  modelC.materials[0].shader = shader
  ##  Using just 1 point lights
  discard createLight(LightType.Point, (0.0, 2.0, 6.0), vector3Zero(), White, shader)
  setCameraMode(camera, Orbital)
  ##  Set an orbital camera mode
  setTargetFPS(60)
  ##  Set our game to run at 60 frames-per-second
  ## --------------------------------------------------------------------------------------
  ##  Main game loop
  while not windowShouldClose(): ##  Detect window close button or ESC key
    ##  Update
    ## ----------------------------------------------------------------------------------
    updateCamera(addr(camera))
    ##  Update camera
    if isKeyDown(Up):
      fogDensity += 0.001
      if fogDensity > 1.0:
        fogDensity = 1.0
    if isKeyDown(Down):
      fogDensity -= 0.001
      if fogDensity < 0.0:
        fogDensity = 0.0
    setShaderValue(shader, fogDensityLoc, addr(fogDensity), Float)
    ##  Rotate the torus
    modelA.transform = modelA.transform * rotateX(-0.025)
    modelA.transform = modelA.transform * rotateZ(0.012)
    ##  Update the light shader with the camera view position
    setShaderValue(shader, shader.locs[int(Vector_View)], addr(camera.position.x), Vec3)
    ## ----------------------------------------------------------------------------------
    ##  Draw
    ## ----------------------------------------------------------------------------------
    beginDrawing:
      clearBackground(Gray)
      beginMode3D(camera):
        ##  Draw the three models
        drawModel(modelA, vector3Zero(), 1.0, White)
        drawModel(modelB, (-2.6, 0.0, 0.0), 1.0, White)
        drawModel(modelC, (2.6, 0.0, 0.0), 1.0, White)
        var i = -20
        while i < 20:
          drawModel(modelA, (i.float, 0.0, 2.0), 1.0, White)
          inc(i, 2)
      drawText(textFormat("Use KEY_UP/KEY_DOWN to change fog density [%.2f]",
                          fogDensity), 10, 10, 20, Raywhite)
  ## ----------------------------------------------------------------------------------
  ##  De-Initialization
  ## --------------------------------------------------------------------------------------
  unloadModel(modelA)
  ##  Unload the model A
  unloadModel(modelB)
  ##  Unload the model B
  unloadModel(modelC)
  ##  Unload the model C
  unloadTexture(texture)
  ##  Unload the texture
  unloadShader(shader)
  ##  Unload shader
  closeWindow()
  ##  Close window and OpenGL context
  ## --------------------------------------------------------------------------------------


block shaders_hot_reloading:
  # ******************************************************************************************
  #
  #    raylib [shaders] example - Hot reloading
  #
  #    NOTE: This example requires raylib OpenGL 3.3 for shaders support and only #version 330
  #          is currently supported. OpenGL ES 2.0 platforms are not supported at the moment.
  #
  #    This example has been created using raylib 3.0 (www.raylib.com)
  #    raylib is licensed under an unmodified zlib/libpng license (View raylib.h for details)
  #
  #    Copyright (c) 2020 Ramon Santamaria (@raysan5)
  #    Converted in 2021 by greenfork
  #
  # ******************************************************************************************


  const GLSL_VERSION = 330

  ##  Initialization
  ## --------------------------------------------------------------------------------------
  var screenWidth = 800
  var screenHeight = 450
  initWindow(screenWidth, screenHeight, "raylib [shaders] example - hot reloading")
  var fragShaderFileName: cstring = "resources/shaders/glsl%i/reload.fs"
  var fragShaderFileModTime: clong = getFileModTime(
      textFormat(fragShaderFileName, GLSL_VERSION))
  ##  Load raymarching shader
  ##  NOTE: Defining 0 (NULL) for vertex shader forces usage of internal default vertex shader
  var shader: Shader = loadShader(nil, textFormat(fragShaderFileName, GLSL_VERSION))
  ##  Get shader locations for requiRed uniforms
  var resolutionLoc = getShaderLocation(shader, "resolution")
  var mouseLoc = getShaderLocation(shader, "mouse")
  var timeLoc = getShaderLocation(shader, "time")
  var resolution: array[2, cfloat] = [screenWidth.cfloat, screenHeight.cfloat]
  setShaderValue(shader, resolutionLoc, resolution.addr, Vec2)
  var totalTime: cfloat = 0.0
  var shaderAutoReloading: bool = false
  setTargetFPS(60)
  ##  Set our game to run at 60 frames-per-second
  ## --------------------------------------------------------------------------------------
  ##  Main game loop
  while not windowShouldClose(): ##  Detect window close button or ESC key
    ##  Update
    ## ----------------------------------------------------------------------------------
    totalTime += getFrameTime()
    var mouse: Vector2 = getMousePosition()
    var mousePos: array[2, cfloat] = [mouse.x, mouse.y]
    ##  Set shader requiRed uniform values
    setShaderValue(shader, timeLoc, addr(totalTime), Float)
    setShaderValue(shader, mouseLoc, mousePos.addr, Vec2)
    ##  Hot shader reloading
    if shaderAutoReloading or (isMouseButtonPressed(Left_Button)):
      var currentFragShaderModTime: clong = getFileModTime(textFormat(fragShaderFileName, GLSL_VERSION))
      ##  Check if shader file has been modified
      if currentFragShaderModTime != fragShaderFileModTime:
        ##  Try reloading updated shader
        var updatedShader: Shader = loadShader(nil, textFormat(fragShaderFileName, GLSL_VERSION))
        if updatedShader.id != rl.getShaderDefault().id:
          unloadShader(shader)
          shader = updatedShader
          ##  Get shader locations for requiRed uniforms
          resolutionLoc = getShaderLocation(shader, "resolution")
          mouseLoc = getShaderLocation(shader, "mouse")
          timeLoc = getShaderLocation(shader, "time")
          ##  Reset requiRed uniforms
          setShaderValue(shader, resolutionLoc, resolution.addr, Vec2)
        fragShaderFileModTime = currentFragShaderModTime
    if isKeyPressed(A):
      shaderAutoReloading = not shaderAutoReloading
    beginDrawing:
      clearBackground(Raywhite)
      ##  We only draw a White full-screen rectangle, frame is generated in shader
      beginShaderMode(shader):
        drawRectangle(0, 0, screenWidth, screenHeight, White)
      drawText(textFormat("PRESS [A] to TOGGLE SHADER AUTOLOADING: %s",
                          if shaderAutoReloading: "AUTO" else: "MANUAL"), 10, 10, 10,
               if shaderAutoReloading: Red else: Black)
      if not shaderAutoReloading:
        drawText("MOUSE CLICK to SHADER RE-LOADING", 10, 30, 10, Black)
      drawText(textFormat("Shader last modification: %s", $fromUnix(fragShaderFileModTime)), 10, 430,
               10, Black)
  ## ----------------------------------------------------------------------------------
  ##  De-Initialization
  ## --------------------------------------------------------------------------------------
  unloadShader(shader)
  ##  Unload shader
  closeWindow()
  ##  Close window and OpenGL context
  ## --------------------------------------------------------------------------------------


block shaders_julia_set:
  # ******************************************************************************************
  #
  #    raylib [shaders] example - julia sets
  #
  #    NOTE: This example requires raylib OpenGL 3.3 or ES2 versions for shaders support,
  #          OpenGL 1.1 does not support shaders, recompile raylib to OpenGL 3.3 version.
  #
  #    NOTE: Shaders used in this example are #version 330 (OpenGL 3.3).
  #
  #    This example has been created using raylib 2.5 (www.raylib.com)
  #    raylib is licensed under an unmodified zlib/libpng license (View raylib.h for details)
  #
  #    Example contributed by eggmund (@eggmund) and reviewed by Ramon Santamaria (@raysan5)
  #
  #    Copyright (c) 2019 eggmund (@eggmund) and Ramon Santamaria (@raysan5)
  #    Converted in 2021 by greenfork
  #
  # ******************************************************************************************


  const GLSL_VERSION = 330

  ##  A few good julia sets
  var POINTS_OF_INTEREST: array[6, array[2, cfloat]] = [
    [-0.348827.cfloat, 0.607167],
    [-0.786268.cfloat, 0.169728],
    [-0.8.cfloat, 0.156],
    [0.285.cfloat, 0.0],
    [-0.835.cfloat, -0.2321],
    [-0.7017600000000001.cfloat, -0.3842]
  ]


  ##  Initialization
  ## --------------------------------------------------------------------------------------
  var screenWidth = 800
  var screenHeight = 450
  initWindow(screenWidth, screenHeight, "raylib [shaders] example - julia sets")
  ##  Load julia set shader
  ##  NOTE: Defining 0 (NULL) for vertex shader forces usage of internal default vertex shader
  var shader: Shader = loadShader(nil, textFormat(
      "resources/shaders/glsl%i/julia_set.fs", GLSL_VERSION))
  ##  c constant to use in z^2 + c
  var c: array[2, cfloat] = [POINTS_OF_INTEREST[0][0], POINTS_OF_INTEREST[0][1]]
  ##  Offset and zoom to draw the julia set at. (centeRed on screen and default size)
  var offset: array[2, cfloat] = [-(screenWidth div 2).cfloat, -(screenHeight div 2).cfloat]
  var zoom: cfloat = 1.0
  var offsetSpeed = Vector2()
  ##  Get variable (uniform) locations on the shader to connect with the program
  ##  NOTE: If uniform variable could not be found in the shader, function returns -1
  var cLoc = getShaderLocation(shader, "c")
  var zoomLoc = getShaderLocation(shader, "zoom")
  var offsetLoc = getShaderLocation(shader, "offset")
  ##  Tell the shader what the screen dimensions, zoom, offset and c are
  var screenDims: array[2, cfloat] = [screenWidth.cfloat, screenHeight.cfloat]
  setShaderValue(shader, getShaderLocation(shader, "screenDims"), screenDims.addr, Vec2)
  setShaderValue(shader, cLoc, c.addr, Vec2)
  setShaderValue(shader, zoomLoc, addr(zoom), Float)
  setShaderValue(shader, offsetLoc, offset.addr, Vec2)
  ##  Create a RenderTexture2D to be used for render to texture
  var target: RenderTexture2D = loadRenderTexture(screenWidth, screenHeight)
  var incrementSpeed = 0
  ##  Multiplier of speed to change c value
  var showControls: bool = true
  ##  Show controls
  var pause: bool = false
  ##  Pause animation
  setTargetFPS(60)
  ##  Set our game to run at 60 frames-per-second
  ## --------------------------------------------------------------------------------------
  ##  Main game loop
  while not windowShouldClose(): ##  Detect window close button or ESC key
    ##  Update
    ## ----------------------------------------------------------------------------------
    ##  Press [1 - 6] to reset c to a point of interest
    if isKeyPressed(One) or isKeyPressed(Two) or isKeyPressed(Three) or
        isKeyPressed(Four) or isKeyPressed(Five) or isKeyPressed(Six):
      if isKeyPressed(One):
        c[0] = POINTS_OF_INTEREST[0][0]
        c[1] = POINTS_OF_INTEREST[0][1]
      elif isKeyPressed(Two):
        c[0] = POINTS_OF_INTEREST[1][0]
        c[1] = POINTS_OF_INTEREST[1][1]
      elif isKeyPressed(Three):
        c[0] = POINTS_OF_INTEREST[2][0]
        c[1] = POINTS_OF_INTEREST[2][1]
      elif isKeyPressed(Four):
        c[0] = POINTS_OF_INTEREST[3][0]
        c[1] = POINTS_OF_INTEREST[3][1]
      elif isKeyPressed(Five):
        c[0] = POINTS_OF_INTEREST[4][0]
        c[1] = POINTS_OF_INTEREST[4][1]
      elif isKeyPressed(Six):
        c[0] = POINTS_OF_INTEREST[5][0]
        c[1] = POINTS_OF_INTEREST[5][1]
      setShaderValue(shader, cLoc, c.addr, Vec2)
    if isKeyPressed(Space):
      pause = not pause
    if isKeyPressed(F1):
      showControls = not showControls
    if not pause:
      if isKeyPressed(Right):
        inc(incrementSpeed)
      elif isKeyPressed(Left): ##  TODO: The idea is to zoom and move around with mouse
                                 ##  Probably offset movement should be proportional to zoom level
        dec(incrementSpeed)
      if isMouseButtonDown(Left_Button) or isMouseButtonDown(Right_Button):
        if isMouseButtonDown(Left_Button):
          zoom += zoom*0.003
        if isMouseButtonDown(Right_Button):
          zoom -= zoom*0.003
        var mousePos: Vector2 = getMousePosition()
        offsetSpeed.x = mousePos.x - (float)(screenWidth div 2)
        offsetSpeed.y = mousePos.y - (float)(screenHeight div 2)
        ##  Slowly move camera to targetOffset
        offset[0] += getFrameTime() * offsetSpeed.x * 0.8
        offset[1] += getFrameTime() * offsetSpeed.y * 0.8
      else:
        offsetSpeed = (0.0, 0.0)
      setShaderValue(shader, zoomLoc, addr(zoom), Float)
      setShaderValue(shader, offsetLoc, offset.addr, Vec2)
      ##  Increment c value with time
      var amount = getFrameTime() * incrementSpeed.float * 0.0005
      c[0] += amount
      c[1] += amount
      setShaderValue(shader, cLoc, c.addr, Vec2)
    beginDrawing:
      clearBackground(Black)
      ##  Clear the screen of the previous frame.
      ##  Using a render texture to draw Julia set
      beginTextureMode(target):
        ##  Enable drawing to texture
        clearBackground(Black)
        ##  Clear the render texture
        ##  Draw a rectangle in shader mode to be used as shader canvas
        ##  NOTE: Rectangle uses font White character texture coordinates,
        ##  so shader can not be applied here directly because input vertexTexCoord
        ##  do not represent full screen coordinates (space where want to apply shader)
        drawRectangle(0, 0, getScreenWidth(), getScreenHeight(), Black)
      ##  Draw the saved texture and rendeRed julia set with shader
      ##  NOTE: We do not invert texture on Y, already consideRed inside shader
      beginShaderMode(shader):
        drawTexture(target.texture, 0, 0, White)
      if showControls:
        drawText("Press Mouse buttons right/left to zoom in/out and move", 10, 15,
                 10, Raywhite)
        drawText("Press KEY_F1 to toggle these controls", 10, 30, 10, Raywhite)
        drawText("Press KEYS [1 - 6] to change point of interest", 10, 45, 10,
                 Raywhite)
        drawText("Press KEY_LEFT | KEY_RIGHT to change speed", 10, 60, 10, Raywhite)
        drawText("Press KEY_SPACE to pause movement animation", 10, 75, 10, Raywhite)
  ## ----------------------------------------------------------------------------------
  ##  De-Initialization
  ## --------------------------------------------------------------------------------------
  unloadShader(shader)
  ##  Unload shader
  unloadRenderTexture(target)
  ##  Unload render texture
  closeWindow()
  ##  Close window and OpenGL context
  ## --------------------------------------------------------------------------------------


block shaders_palette_switch:
  #*******************************************************************************************
  #
  #   raylib [shaders] example - Color palette switch
  #
  #   NOTE: This example requires raylib OpenGL 3.3 or ES2 versions for shaders support,
  #         OpenGL 1.1 does not support shaders, recompile raylib to OpenGL 3.3 version.
  #
  #   NOTE: Shaders used in this example are #version 330 (OpenGL 3.3), to test this example
  #         on OpenGL ES 2.0 platforms (Android, Raspberry Pi, HTML5), use #version 100 shaders
  #         raylib comes with shaders ready for both versions, check raylib/shaders install folder
  #
  #   This example has been created using raylib 2.3 (www.raylib.com)
  #   raylib is licensed under an unmodified zlib/libpng license (View raylib.h for details)
  #
  #   Example contributed by Marco Lizza (@MarcoLizza) and reviewed by Ramon Santamaria (@raysan5)
  #
  #   Copyright (c) 2019 Marco Lizza (@MarcoLizza) and Ramon Santamaria (@raysan5)
  #   /Converted in 2*20 by Guevara-chan.
  #   Adapted in 2021 by greenfork
  #
  #*******************************************************************************************


  const GLSL_VERSION = 330

  const MAX_PALETTES       = 3
  const COLORS_PER_PALETTE = 8

  var palettes = [
      [   #  3-BIT RGB
          0.int32, 0, 0,
          255, 0, 0,
          0, 255, 0,
          0, 0, 255,
          0, 255, 255,
          255, 0, 255,
          255, 255, 0,
          255, 255, 255,
      ],
      [   #  AMMO-8 (GameBoy-like)
          4.int32, 12, 6,
          17, 35, 24,
          30, 58, 41,
          48, 93, 66,
          77, 128, 97,
          137, 162, 87,
          190, 220, 127,
          238, 255, 204,
      ],
      [   #  RKBV (2-strip film)
          21.int32, 25, 26,
          138, 76, 88,
          217, 98, 117,
          230, 184, 193,
          69, 107, 115,
          75, 151, 166,
          165, 189, 194,
          255, 245, 247,
      ],
  ]
  echo palettes

  const paletteText = [
      "3-BIT RGB",
      "AMMO-8 (GameBoy-like)",
      "RKBV (2-strip film)"
  ]


  #  Initialization
  # --------------------------------------------------------------------------------------
  const screenWidth = 800
  const screenHeight = 450

  initWindow screenWidth, screenHeight, "raylib [shaders] example - color palette switch"

  let
    # Load shader to be used on some parts drawing
    # NOTE 1: Using GLSL 330 shader version, on OpenGL ES 2.0 use GLSL 100 shader version
    # NOTE 2: Defining 0 (NULL) for vertex shader forces usage of internal default vertex shader
    shader = loadShader(nil, textFormat("resources/shaders/glsl%i/palette_switch.fs", GLSL_VERSION))
    # Get variable (uniform) location on the shader to connect with the program
    # NOTE: If uniform variable could not be found in the shader, function returns -1
    paletteLoc = getShaderLocation(shader, "palette")

  var currentPalette = 0
  let lineHeight = screenHeight div COLORS_PER_PALETTE

  60.setTargetFPS                        #  Set our game to run at 60 frames-per-second
  # --------------------------------------------------------------------------------------

  #  Main game loop
  while not windowShouldClose():         #  Detect window close button or ESC key
      #  Update
      # ----------------------------------------------------------------------------------
      currentPalette += (if isKeyPressed(RIGHT): 1 elif isKeyPressed(LEFT): -1 else: 0)

      if currentPalette >= MAX_PALETTES: currentPalette = 0
      elif currentPalette < 0: currentPalette = MAX_PALETTES - 1

      #  Send new value to the shader to be used on drawing.
      #  NOTE: We are sending RGB triplets w/o the alpha channel
      setShaderValueV shader, paletteLoc, palettes[currentPalette].addr, IVec3, COLORS_PER_PALETTE
      # ----------------------------------------------------------------------------------

      #  Draw
      # ----------------------------------------------------------------------------------
      beginDrawing:
        clearBackground Raywhite
        beginShaderMode(shader):
          for i in 0..<COLORS_PER_PALETTE:
              #  Draw horizontal screen-wide rectangles with increasing "palette index"
              #  The used palette index is encoded in the RGB components of the pixel
              drawRectangle 0.int32, (int32)lineHeight*i, getScreenWidth(), lineHeight.int32, (r: i, g: i, b: i, a: 255)
        drawText "< >", 10, 10, 30, DARKBLUE
        drawText "CURRENT PALETTE:", 60, 15, 20, RAYWHITE
        drawText paletteText[currentPalette], 300, 15, 20, RED

        drawFPS 700, 15
      # ----------------------------------------------------------------------------------

  #  De-Initialization
  # --------------------------------------------------------------------------------------
  unloadShader shader        #  Unload shader

  closeWindow()              #  Close window and OpenGL context
  # --------------------------------------------------------------------------------------


block shaders_raymarching:
  #*******************************************************************************************
  #
  #   raylib [shaders] example - Raymarching shapes generation
  #
  #   NOTE: This example requires raylib OpenGL 3.3 or ES2 versions for shaders support,
  #         OpenGL 1.1 does not support shaders, recompile raylib to OpenGL 3.3 version.
  #
  #   NOTE: Shaders used in this example are #version 330 (OpenGL 3.3), to test this example
  #         on OpenGL ES 2.0 platforms (Android, Raspberry Pi, HTML5), use #version 100 shaders
  #         raylib comes with shaders ready for both versions, check raylib/shaders install folder
  #
  #   This example has been created using raylib 2.0 (www.raylib.com)
  #   raylib is licensed under an unmodified zlib/libpng license (View raylib.h for details)
  #
  #   Copyright (c) 2018 Ramon Santamaria (@raysan5)
  #   /Converted in 2*20 by Guevara-chan.
  #   Adapted in 2021 by greenfork
  #
  #*******************************************************************************************

  const GLSL_VERSION = 330

  #  Initialization
  # --------------------------------------------------------------------------------------
  var
    screenWidth = 800
    screenHeight = 450

  setConfigFlags WINDOW_RESIZABLE
  initWindow screenWidth, screenHeight, "raylib [shaders] example - raymarching shapes"

  var camera = Camera()
  camera.position = (x: 2.5, y: 2.5, z: 3.0)    #  Camera position
  camera.target = (x: 0.0, y: 0.0, z: 0.7)      #  Camera looking at point
  camera.up = (x: 0.0, y: 1.0, z: 0.0)          #  Camera up vector (rotation towards target)
  camera.fovy = 65.0                                     #  Camera field-of-view Y

  setCameraMode camera, Free                       #  Set camera mode

  #  Load raymarching shader
  #  NOTE: Defining 0 (NULL) for vertex shader forces usage of internal default vertex shader
  let
    shader = loadShader(nil, textFormat("resources/shaders/glsl%i/raymarching.fs", GLSL_VERSION))
    # Get shader locations for required uniforms
    viewEyeLoc      = getShaderLocation(shader, "viewEye")
    viewCenterLoc   = getShaderLocation(shader, "viewCenter")
    runTimeLoc      = getShaderLocation(shader, "runTime")
    resolutionLoc   = getShaderLocation(shader, "resolution")

  var resolution = [screenWidth.cfloat, screenHeight.cfloat]
  setShaderValue shader, resolutionLoc, resolution.addr, VEC2

  var runTime: cfloat = 0.0

  60.setTargetFPS                         #  Set our game to run at 60 frames-per-second
  # --------------------------------------------------------------------------------------

  #  Main game loop
  while not windowShouldClose():          #  Detect window close button or ESC key
      #  Check if screen is resized
      # ----------------------------------------------------------------------------------
      if isWindowResized():
          screenWidth  = getScreenWidth()
          screenHeight = getScreenHeight()
          resolution   = [screenWidth.cfloat, screenHeight.cfloat]
          setShaderValue shader, resolutionLoc, resolution.addr, VEC2

      #  Update
      # ----------------------------------------------------------------------------------
      camera.addr.updateCamera           #  Update camera

      var
        cameraPos = [camera.position.x, camera.position.y, camera.position.z]
        cameraTarget = [camera.target.x, camera.target.y, camera.target.z]

        deltaTime = getFrameTime()
      runTime += deltaTime

      #  Set shader required uniform values
      setShaderValue shader, viewEyeLoc, cameraPos.addr, VEC3
      setShaderValue shader, viewCenterLoc, cameraTarget.addr, VEC3
      setShaderValue shader, runTimeLoc, runTime.addr, FLOAT
      # ----------------------------------------------------------------------------------

      #  Draw
      # ----------------------------------------------------------------------------------
      beginDrawing:

        clearBackground RAYWHITE

        #  We only draw a white full-screen rectangle,
        #  frame is generated in shader using raymarching
        beginShaderMode(shader):
          drawRectangle 0, 0, screenWidth, screenHeight, WHITE

        drawText "(c) Raymarching shader by Iñigo Quilez. MIT License.", screenWidth - 280, screenHeight - 20, 10, BLACK
      # ----------------------------------------------------------------------------------

  #  De-Initialization
  # --------------------------------------------------------------------------------------
  unloadShader shader            #  Unload shader

  closeWindow()                  #  Close window and OpenGL context
  # --------------------------------------------------------------------------------------


block shapes_bouncing_ball:
  #*******************************************************************************************
  #
  #   raylib [shapes] example - bouncing ball
  #
  #   This example has been created using raylib 1.0 (www.raylib.com)
  #   raylib is licensed under an unmodified zlib/libpng license (View raylib.h for details)
  #
  #   Copyright (c) 2013 Ramon Santamaria (@raysan5)
  #   /Converted in 2*20 by Guevara-chan.
  #   Adapted in 2021 by greenfork
  #
  #*******************************************************************************************


  #  Initialization
  # ---------------------------------------------------------
  const screenWidth = 800
  const screenHeight = 450

  initWindow screenWidth, screenHeight, "raylib [shapes] example - bouncing ball"

  var
    ballPosition = (x: getScreenWidth()/2, y: getScreenHeight()/2)
    ballSpeed = (x: 5.0f, y: 4.0f)
    ballRadius = 20.0

    pause = false
    framesCounter = 0

  setTargetFPS(60)               #  Set our game to run at 60 frames-per-second
  # ----------------------------------------------------------

  #  Main game loop
  while not windowShouldClose():  #  Detect window close button or ESC key
      #  Update
      # -----------------------------------------------------
      if isKeyPressed(SPACE): pause = not pause

      if not pause:
        ballPosition.x += ballSpeed.x
        ballPosition.y += ballSpeed.y

        #  Check walls collision for bouncing
        if (ballPosition.x >= (getScreenWidth() - ballRadius)) or (ballPosition.x <= ballRadius):  ballSpeed.x *= -1.0f
        if (ballPosition.y >= (getScreenHeight() - ballRadius)) or (ballPosition.y <= ballRadius): ballSpeed.y *= -1.0f
      else: framesCounter.inc
      # -----------------------------------------------------

      #  Draw
      # -----------------------------------------------------
      beginDrawing()

      clearBackground RAYWHITE

      drawCircleV ballPosition, ballRadius, MAROON
      drawText "PRESS SPACE to PAUSE BALL MOVEMENT", 10, getScreenHeight() - 25, 20, LIGHTGRAY

      #  On pause, we draw a blinking message
      if pause and ((framesCounter div 30) %% 2).bool: drawText "PAUSED", 350, 200, 30, GRAY

      drawFPS 10, 10

      endDrawing()
      # -----------------------------------------------------

  #  De-Initialization
  # ---------------------------------------------------------
  closeWindow()         #  Close window and OpenGL context
  # ---------------------------------------------------------


block shapes_draw_ring:
  #*******************************************************************************************
  #
  #   raylib [shapes] example - draw ring (with gui options)
  #
  #   This example has been created using raylib 2.5 (www.raylib.com)
  #   raylib is licensed under an unmodified zlib/libpng license (View raylib.h for details)
  #
  #   Example contributed by Vlad Adrian (@demizdor) and reviewed by Ramon Santamaria (@raysan5)
  #
  #   Copyright (c) 2018 Vlad Adrian (@demizdor) and Ramon Santamaria (@raysan5)
  #   /Converted in 2*20 by Guevara-chan.
  #   Adapted in 2021 by greenfork
  #
  #*******************************************************************************************


  #  Initialization
  # --------------------------------------------------------------------------------------
  const screenWidth = 800
  const screenHeight = 450

  initWindow screenWidth, screenHeight, "raylib [shapes] example - draw ring"

  var
      center = (x: (getScreenWidth() - 300) / 2, y: getScreenHeight() / 2)

      innerRadius = 80.0
      outerRadius = 190.0

      startAngle = 0.0
      endAngle = 360.0
      segments = 0.int32

      doDrawRing = true
      doDrawRingLines = false
      doDrawCircleLines = false

  60.setTargetFPS                 #  Set our game to run at 60 frames-per-second
  # --------------------------------------------------------------------------------------

  #  Main game loop
  while not windowShouldClose():  #  Detect window close button or ESC key
      #  Update
      # ----------------------------------------------------------------------------------
      #  NOTE: All variables update happens inside GUI control functions
      # ----------------------------------------------------------------------------------

      #  Draw
      # ----------------------------------------------------------------------------------
      beginDrawing()

      clearBackground RAYWHITE

      drawLine 500, 0, 500, getScreenHeight(), fade(LIGHTGRAY, 0.6)
      drawRectangle 500, 0, getScreenWidth() - 500, getScreenHeight(), fade(LIGHTGRAY, 0.3)

      if doDrawRing:
        drawRing(center, innerRadius, outerRadius, startAngle.float32, endAngle.float32, segments, fade(MAROON, 0.3))
      if doDrawRingLines:
        drawRingLines(center, innerRadius, outerRadius, startAngle.float32, endAngle.float32, segments, fade(BLACK, 0.4))
      if doDrawCircleLines:
        drawCircleSectorLines(center, outerRadius, startAngle.float32, endAngle.float32, segments, fade(BLACK, 0.4))

      #  Draw GUI controls
      # ------------------------------------------------------------------------------
      startAngle = sliderBar((x: 600.0, y: 40.0, width: 120.0, height: 20.0), "StartAngle", "", startAngle, -450,450)
      endAngle = sliderBar((x: 600.0, y: 70.0, width: 120.0, height: 20.0), "EndAngle", "", endAngle, -450,450)

      innerRadius = sliderBar((x: 600.0, y: 140.0, width: 120.0, height: 20.0), "InnerRadius", "", innerRadius, 0,100)
      outerRadius = sliderBar((x: 600.0, y: 170.0, width: 120.0, height: 20.0), "OuterRadius", "", outerRadius, 0,200)

      segments = sliderBar((x: 600.0, y: 240.0, width: 120.0, height: 20.0), "Segments", "", segments.float, 0,100).int32

      doDrawRing = checkBox((x: 600.0, y: 320.0, width: 20.0, height: 20.0), "Draw Ring", doDrawRing)
      doDrawRingLines = checkBox((x: 600.0, y: 350.0, width: 20.0, height: 20.0), "Draw RingLines", doDrawRingLines)
      doDrawCircleLines = checkBox((x: 600.0, y: 380.0, width: 20.0, height: 20.0), "Draw CircleLines", doDrawCircleLines)
      # ------------------------------------------------------------------------------

      drawText textFormat("MODE: %s", (if segments >= 4: "MANUAL" else: "AUTO")), 600, 270, 10,
          (if segments >= 4: MAROON else: DARKGRAY)

      drawFPS 10, 10

      endDrawing()
      # ----------------------------------------------------------------------------------

  #  De-Initialization
  # --------------------------------------------------------------------------------------
  closeWindow()         #  Close window and OpenGL context
  # --------------------------------------------------------------------------------------


block shapes_following_eyes:
  #*******************************************************************************************
  #
  #   raylib [shapes] example - following eyes
  #
  #   This example has been created using raylib 2.5 (www.raylib.com)
  #   raylib is licensed under an unmodified zlib/libpng license (View raylib.h for details)
  #
  #   Copyright (c) 2013-2019 Ramon Santamaria (@raysan5)
  #   /Converted in 2*20 by Guevara-chan.
  #   Adapted in 2021 by greenfork
  #
  #*******************************************************************************************


  #  Initialization
  # --------------------------------------------------------------------------------------
  const screenWidth = 800
  const screenHeight = 450

  initWindow screenWidth, screenHeight, "raylib [shapes] example - following eyes"

  var
    scleraLeftPosition = (x: getScreenWidth()/2 - 100, y: getScreenHeight()/2).Vector2
    scleraRightPosition = (x: getScreenWidth()/2 + 100, y: getScreenHeight()/2).Vector2
    scleraRadius = 80.0

    irisLeftPosition = (x: getScreenWidth()/2 - 100, y: getScreenHeight()/2).Vector2
    irisRightPosition = (x: getScreenWidth()/2 + 100, y: getScreenHeight()/2).Vector2
    irisRadius = 24.0

    angle = 0.0f
    dx = 0.0f
    dy = 0.0f
    dxx = 0.0f
    dyy = 0.0f

  setTargetFPS 60                 #  Set our game to run at 60 frames-per-second
  # --------------------------------------------------------------------------------------

  #  Main game loop
  while not windowShouldClose():  #  Detect window close button or ESC key
      #  Update
      # ----------------------------------------------------------------------------------
      irisLeftPosition = getMousePosition()
      irisRightPosition = getMousePosition()

      #  Check not inside the left eye sclera
      if not checkCollisionPointCircle(irisLeftPosition, scleraLeftPosition, scleraRadius - 20):
          dx = irisLeftPosition.x - scleraLeftPosition.x
          dy = irisLeftPosition.y - scleraLeftPosition.y

          angle = arctan2(dy, dx)

          dxx = (scleraRadius - irisRadius)*angle.cos
          dyy = (scleraRadius - irisRadius)*angle.sin

          irisLeftPosition.x = scleraLeftPosition.x + dxx
          irisLeftPosition.y = scleraLeftPosition.y + dyy

      #  Check not inside the right eye sclera
      if not checkCollisionPointCircle(irisRightPosition, scleraRightPosition, scleraRadius - 20):
          dx = irisRightPosition.x - scleraRightPosition.x
          dy = irisRightPosition.y - scleraRightPosition.y

          angle = arctan2(dy, dx)

          dxx = (scleraRadius - irisRadius)*angle.cos
          dyy = (scleraRadius - irisRadius)*angle.sin

          irisRightPosition.x = scleraRightPosition.x + dxx
          irisRightPosition.y = scleraRightPosition.y + dyy
      # ----------------------------------------------------------------------------------

      #  Draw
      # ----------------------------------------------------------------------------------
      beginDrawing()

      clearBackground RAYWHITE

      drawCircleV scleraLeftPosition, scleraRadius, LIGHTGRAY
      drawCircleV irisLeftPosition, irisRadius, BROWN
      drawCircleV irisLeftPosition, 10, BLACK

      drawCircleV scleraRightPosition, scleraRadius, LIGHTGRAY
      drawCircleV irisRightPosition, irisRadius, DARKGREEN
      drawCircleV irisRightPosition, 10, BLACK

      drawFPS 10, 10

      endDrawing()
      # ----------------------------------------------------------------------------------

  #  De-Initialization
  # --------------------------------------------------------------------------------------
  closeWindow()         #  Close window and OpenGL context
  # --------------------------------------------------------------------------------------


block text_format_text:
  #*******************************************************************************************
  #
  #   raylib [text] example - Text formatting
  #
  #   This example has been created using raylib 1.1 (www.raylib.com)
  #   raylib is licensed under an unmodified zlib/libpng license (View raylib.h for details)
  #
  #   Copyright (c) 2014 Ramon Santamaria (@raysan5)
  #   /Converted in 2*20 by Guevara-chan.
  #   Adapted in 2021 by greenfork
  #
  #*******************************************************************************************


  #  Initialization
  # --------------------------------------------------------------------------------------
  const screenWidth = 800
  const screenHeight = 450

  initWindow screenWidth, screenHeight, "raylib [text] example - text formatting"

  let
      score   = 100020
      hiscore = 200450
      lives   = 5

  setTargetFPS(60)               #  Set our game to run at 60 frames-per-second
  # --------------------------------------------------------------------------------------

  #  Main game loop
  while not windowShouldClose(): #  Detect window close button or ESC key
      #  Update
      # ----------------------------------------------------------------------------------
      #  TODO: Update your variables here
      # ----------------------------------------------------------------------------------

      #  Draw
      # ----------------------------------------------------------------------------------
      beginDrawing()

      clearBackground RAYWHITE

      drawText textFormat("Score: %08i", score), 200, 80, 20, RED

      drawText textFormat("HiScore: %08i", hiscore), 200, 120, 20, GREEN

      drawText textFormat("Lives: %02i", lives), 200, 160, 40, BLUE

      drawText textFormat("Elapsed Time: %02.02f ms", getFrameTime()*1000), 200, 220, 20, BLACK

      endDrawing()
      # ----------------------------------------------------------------------------------

  #  De-Initialization
  # --------------------------------------------------------------------------------------
  closeWindow()        #  Close window and OpenGL context
  # --------------------------------------------------------------------------------------


block text_input_box:
  #******************************************************************************************
  #
  #   raylib [text] example - Input Box
  #
  #   This example has been created using raylib 1.7 (www.raylib.com)
  #   raylib is licensed under an unmodified zlib/libpng license (View raylib.h for details)
  #
  #   Copyright (c) 2017 Ramon Santamaria (@raysan5)
  #   /Converted in 2*20 by Guevara-chan.
  #   Adapted in 2021 by greenfork
  #
  #*******************************************************************************************


  const MAX_INPUT_CHARS = 9

  #  Initialization
  # --------------------------------------------------------------------------------------
  const screenWidth = 800
  const screenHeight = 450

  initWindow screenWidth, screenHeight, "raylib [text] example - input box"

  var
      name: array[MAX_INPUT_CHARS+1, char] #  NOTE: One extra space required for line ending char '\0'
      letterCount = 0

      textBox: Rectangle = (x: (float) screenWidth/2 - 100, y: 180.0, width: 225.0, height: 50.0)
      mouseOnText = false

      framesCounter = 0

  60.setTargetFPS               #  Set our game to run at 60 frames-per-second
  # --------------------------------------------------------------------------------------

  #  Main game loop
  while not windowShouldClose():#  Detect window close button or ESC key
      #  Update
      # ----------------------------------------------------------------------------------
      mouseOnText = checkCollisionPointRec(getMousePosition(), textBox)

      if mouseOnText:
          #  Get pressed key (character) on the queue
          var key = getKeyPressed()

          #  Check if more characters have been pressed on the same frame
          while key > 0:
              #  NOTE: Only allow keys in range [32..125]
              if key >= 32 and key <= 125 and letterCount < MAX_INPUT_CHARS:
                  name[letterCount] = key.char
                  letterCount.inc
              key = getKeyPressed()  #  Check next character in the queue

          if isKeyPressed(BACKSPACE):
              letterCount.dec
              if letterCount < 0: letterCount = 0
              name[letterCount] = '\0'

      if mouseOnText: framesCounter.inc else: framesCounter = 0
      # ----------------------------------------------------------------------------------
      #  Draw
      # ----------------------------------------------------------------------------------
      beginDrawing()

      clearBackground RAYWHITE

      drawText "PLACE MOUSE OVER INPUT BOX!", 240, 140, 20, GRAY

      drawRectangleRec textBox, LIGHTGRAY
      if mouseOnText: drawRectangleLines textBox.x.int, textBox.y.int, textBox.width.int, textBox.height.int, RED
      else: drawRectangleLines textBox.x.int, textBox.y.int, textBox.width.int, textBox.height.int, DARKGRAY

      let namestr = cast[cstring](addr name[0])
      drawText $namestr, textBox.x.int + 5, textBox.y.int + 8, 40, MAROON

      drawText textFormat("INPUT CHARS: %i/%i", letterCount, MAX_INPUT_CHARS), 315, 250, 20, DARKGRAY

      if mouseOnText:
          if letterCount < MAX_INPUT_CHARS:
              #  Draw blinking underscore char
              if (framesCounter div 20)%%2 == 0:
                  drawText "_", textBox.x.int + 8 + measureText(namestr, 40), textBox.y.int + 12, 40, MAROON
          else: drawText "Press BACKSPACE to delete chars...", 230, 300, 20, GRAY

      endDrawing()

  # ----------------------------------------------------------------------------------
  #  De-Initialization
  # --------------------------------------------------------------------------------------
  closeWindow()        #  Close window and OpenGL context
  # --------------------------------------------------------------------------------------


block text_rectangle_bound:
  #*******************************************************************************************
  #
  #   raylib [text] example - Draw text inside a rectangle
  #
  #   This example has been created using raylib 2.3 (www.raylib.com)
  #   raylib is licensed under an unmodified zlib/libpng license (View raylib.h for details)
  #
  #   Example contributed by Vlad Adrian (@demizdor) and reviewed by Ramon Santamaria (@raysan5)
  #
  #   Copyright (c) 2018 Vlad Adrian (@demizdor) and Ramon Santamaria (@raysan5)
  #   /Converted in 2*20 by Guevara-chan.
  #   Adapted in 2021 by greenfork
  #
  #*******************************************************************************************


  #  Initialization
  # --------------------------------------------------------------------------------------
  const screenWidth = 800
  const screenHeight = 450

  initWindow screenWidth, screenHeight, "raylib [text] example - draw text inside a rectangle"

  let text = "Text cannot escape\tthis container\t...word wrap also works when active so here's" &
      "a long text for testing.\n\nLorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod" &
      "tempor incididunt ut labore et dolore magna aliqua. Nec ullamcorper sit amet risus nullam eget felis eget."

  var
      resizing = false
      wordWrap = true

      container: Rectangle = (x: 25.0, y: 25.0, width: (float) screenWidth - 50, height: (float) screenHeight - 250)
      resizer: Rectangle   = (x: container.x+container.width-17.0, y: container.y+container.height-17.0, width: 14.0, height: 14.0)

  #  Minimum width and heigh for the container rectangle
  const minWidth  = 60
  const minHeight = 60
  const maxWidth  = screenWidth - 50
  const maxHeight = screenHeight - 160

  var
      lastMouse: Vector2 = (x: 0.0, y: 0.0) #  Stores last mouse coordinates
      borderColor = MAROON                 #  Container border color
      font = getFontDefault()              #  Get default system font

  60.setTargetFPS                       #  Set our game to run at 60 frames-per-second
  # --------------------------------------------------------------------------------------

  #  Main game loop
  while not windowShouldClose():        #  Detect window close button or ESC key
      #  Update
      # ----------------------------------------------------------------------------------
      if isKeyPressed(SPACE): wordWrap = not wordWrap

      let mouse = getMousePosition()

      #  Check if the mouse is inside the container and toggle border color
      if checkCollisionPointRec(mouse, container): borderColor = fade(MAROON, 0.4)
      elif not resizing: borderColor = MAROON

      #  Container resizing logic
      if resizing:
          if isMouseButtonReleased(LEFT_BUTTON): resizing = false

          let width = container.width + (mouse.x - lastMouse.x)
          container.width = if width > minWidth: (if width < maxWidth: width else: maxWidth) else: minWidth

          let height = container.height + (mouse.y - lastMouse.y)
          container.height = if height > minHeight: (if height < maxHeight: height else: maxHeight) else: minHeight
      else:
          #  Check if we're resizing
          if isMouseButtonDown(LEFT_BUTTON) and checkCollisionPointRec(mouse, resizer): resizing = true

      #  Move resizer rectangle properly
      resizer.x = container.x + container.width - 17
      resizer.y = container.y + container.height - 17

      lastMouse = mouse #  Update mouse
      # ----------------------------------------------------------------------------------

      #  Draw
      # ----------------------------------------------------------------------------------
      beginDrawing()

      clearBackground RAYWHITE

      drawRectangleLinesEx container, 3, borderColor  #  Draw container border

      #  Draw text in container (add some padding)
      drawTextRec font, text,
                 (x: container.x + 4.0, y: container.y + 4.0, width: container.width-4.0, height: container.height-4.0),
                 20.0, 2.0, wordWrap, GRAY

      drawRectangleRec resizer, borderColor          #  Draw the resize box

      #  Draw bottom info
      drawRectangle 0, screenHeight - 54, screenWidth, 54, GRAY
      drawRectangleRec (x: 382.0, y: screenHeight - 34.0, width: 12.0, height: 12.0), MAROON

      drawText "Word Wrap: ", 313, screenHeight-115, 20, BLACK
      if wordWrap: drawText "ON", 447, screenHeight - 115, 20, RED
      else: drawText "OFF", 447, screenHeight - 115, 20, BLACK

      drawText "Press [SPACE] to toggle word wrap", 218, screenHeight - 86, 20, GRAY

      drawText "Click hold & drag the    to resize the container", 155, screenHeight - 38, 20, RAYWHITE

      endDrawing()
      # ----------------------------------------------------------------------------------

  #  De-Initialization
  # --------------------------------------------------------------------------------------
  closeWindow()        #  Close window and OpenGL context
  # --------------------------------------------------------------------------------------


block textures_background_scrolling:
  # ******************************************************************************************
  #
  #    raylib [textures] example - Background scrolling
  #
  #    This example has been created using raylib 2.0 (www.raylib.com)
  #    raylib is licensed under an unmodified zlib/libpng license (View raylib.h for details)
  #
  #    Copyright (c) 2019 Ramon Santamaria (@raysan5)
  #    Converted in 2021 by greenfork
  #
  # ******************************************************************************************


  ##  Initialization
  ## --------------------------------------------------------------------------------------
  var screenWidth = 800
  var screenHeight = 450
  initWindow(screenWidth, screenHeight,
             "raylib [textures] example - background scrolling")
  ##  NOTE: Be careful, background width must be equal or bigger than screen width
  ##  if not, texture should be draw more than two times for scrolling effect
  var background: Texture2D = loadTexture("resources/cyberpunk_street_background.png")
  var midground: Texture2D = loadTexture("resources/cyberpunk_street_midground.png")
  var foreground: Texture2D = loadTexture("resources/cyberpunk_street_foreground.png")
  var scrollingBack = 0.0
  var scrollingMid = 0.0
  var scrollingFore = 0.0
  setTargetFPS(60)
  ##  Set our game to run at 60 frames-per-second
  ## --------------------------------------------------------------------------------------
  ##  Main game loop
  while not windowShouldClose(): ##  Detect window close button or ESC key
    ##  Update
    ## ----------------------------------------------------------------------------------
    scrollingBack -= 0.1
    scrollingMid -= 0.5
    scrollingFore -= 1.0
    ##  NOTE: Texture is scaled twice its size, so it sould be consideRed on scrolling
    if scrollingBack <= -(background.width * 2):
      scrollingBack = 0
    if scrollingMid <= -(midground.width * 2):
      scrollingMid = 0
    if scrollingFore <= -(foreground.width * 2):
      scrollingFore = 0
    beginDrawing:
      clearBackground(getColor(0x052C46FF))
      ##  Draw background image twice
      ##  NOTE: Texture is scaled twice its size
      drawTextureEx(background, (scrollingBack, 20.0), 0.0, 2.0, White)
      drawTextureEx(background, (background.width * 2 + scrollingBack, 20.0), 0.0,
                    2.0, White)
      ##  Draw midground image twice
      drawTextureEx(midground, (scrollingMid, 20.0), 0.0, 2.0, White)
      drawTextureEx(midground, (midground.width * 2 + scrollingMid, 20.0), 0.0, 2.0,
                    White)
      ##  Draw foreground image twice
      drawTextureEx(foreground, (scrollingFore, 70.0), 0.0, 2.0, White)
      drawTextureEx(foreground, (foreground.width * 2 + scrollingFore, 70.0), 0.0,
                    2.0, White)
      drawText("BACKGROUND SCROLLING & PARALLAX", 10, 10, 20, Red)
      drawText("(c) Cyberpunk Street Environment by Luis Zuno (@ansimuz)",
               screenWidth - 330, screenHeight - 20, 10, Raywhite)
  ## ----------------------------------------------------------------------------------
  ##  De-Initialization
  ## --------------------------------------------------------------------------------------
  unloadTexture(background)
  ##  Unload background texture
  unloadTexture(midground)
  ##  Unload midground texture
  unloadTexture(foreground)
  ##  Unload foreground texture
  closeWindow()
  ##  Close window and OpenGL context
  ## --------------------------------------------------------------------------------------


block textures_blend_modes:
  # ******************************************************************************************
  #
  #    raylib [textures] example - blend modes
  #
  #    NOTE: Images are loaded in CPU memory (RAM); textures are loaded in GPU memory (VRAM)
  #
  #    This example has been created using raylib 3.5 (www.raylib.com)
  #    raylib is licensed under an unmodified zlib/libpng license (View raylib.h for details)
  #
  #    Example contributed by Karlo Licudine (@accidentalrebel) and reviewed by Ramon Santamaria (@raysan5)
  #
  #    Copyright (c) 2020 Karlo Licudine (@accidentalrebel)
  #    Converted in 2021 by greenfork
  #
  # ******************************************************************************************



  ##  Initialization
  ## --------------------------------------------------------------------------------------
  var screenWidth = 800
  var screenHeight = 450
  initWindow(screenWidth, screenHeight, "raylib [textures] example - blend modes")
  ##  NOTE: Textures MUST be loaded after Window initialization (OpenGL context is requiRed)
  var bgImage: Image = loadImage("resources/cyberpunk_street_background.png")
  ##  Loaded in CPU memory (RAM)
  var bgTexture: Texture2D = loadTextureFromImage(bgImage)
  ##  Image converted to texture, GPU memory (VRAM)
  var fgImage: Image = loadImage("resources/cyberpunk_street_foreground.png")
  ##  Loaded in CPU memory (RAM)
  var fgTexture: Texture2D = loadTextureFromImage(fgImage)
  ##  Image converted to texture, GPU memory (VRAM)
  ##  Once image has been converted to texture and uploaded to VRAM, it can be unloaded from RAM
  unloadImage(bgImage)
  unloadImage(fgImage)
  var blendCountMax = 4
  var blendMode: BlendMode
  ##  Main game loop
  while not windowShouldClose(): ##  Detect window close button or ESC key
    ##  Update
    ## ----------------------------------------------------------------------------------
    if isKeyPressed(Space):
      if blendMode >= (blendCountMax - 1):
        blendMode = BlendMode(0.ord)
      else:
        blendMode = succ(blendMode)
    beginDrawing()
    clearBackground(Raywhite)
    drawTexture(bgTexture, screenWidth div 2 - bgTexture.width div 2,
                screenHeight div 2 - bgTexture.height div 2, White)
    ##  Apply the blend mode and then draw the foreground texture
    beginBlendMode(blendMode)
    drawTexture(fgTexture, screenWidth div 2 - fgTexture.width div 2,
                screenHeight div 2 - fgTexture.height div 2, White)
    endBlendMode()
    ##  Draw the texts
    drawText("Press SPACE to change blend modes.", 310, 350, 10, Gray)
    case blendMode
    of Alpha:
      drawText("Current: BLEND_ALPHA", (screenWidth div 2) - 60, 370, 10, Gray)
    of Additive:
      drawText("Current: BLEND_ADDITIVE", (screenWidth div 2) - 60, 370, 10, Gray)
    of Multiplied:
      drawText("Current: BLEND_MULTIPLIED", (screenWidth div 2) - 60, 370, 10, Gray)
    of Add_Colors:
      drawText("Current: BLEND_ADD_COLORS", (screenWidth div 2) - 60, 370, 10, Gray)
    else:
      discard
    drawText("(c) Cyberpunk Street Environment by Luis Zuno (@ansimuz)",
             screenWidth - 330, screenHeight - 20, 10, Gray)
    endDrawing()
    ## ----------------------------------------------------------------------------------
  ##  De-Initialization
  ## --------------------------------------------------------------------------------------
  unloadTexture(fgTexture)
  ##  Unload foreground texture
  unloadTexture(bgTexture)
  ##  Unload background texture
  closeWindow()
  ##  Close window and OpenGL context
  ## --------------------------------------------------------------------------------------


block textures_bunnymark:
  # ******************************************************************************************
  #
  #    raylib [textures] example - Bunnymark
  #
  #    This example has been created using raylib 1.6 (www.raylib.com)
  #    raylib is licensed under an unmodified zlib/libpng license (View raylib.h for details)
  #
  #    Copyright (c) 2014-2019 Ramon Santamaria (@raysan5)
  #    Converted in 2021 by greenfork
  #
  # ******************************************************************************************


  const
    MAX_BUNNIES = 50000

  ##  This is the maximum amount of elements (quads) per batch
  ##  NOTE: This value is defined in [rlgl] module and can be changed there

  const
    MAX_BATCH_ELEMENTS = 8192

  type
    BunnyObj {.bycopy.} = object
      position: Vector2
      speed: Vector2
      color: Color
    Bunny = ref BunnyObj

  ##  Initialization
  ## --------------------------------------------------------------------------------------
  var screenWidth = 800
  var screenHeight = 450
  initWindow(screenWidth, screenHeight, "raylib [textures] example - bunnymark")
  ##  Load bunny texture
  var texBunny: Texture2D = loadTexture("resources/wabbit_alpha.png")
  var bunnies: array[MAX_BUNNIES, Bunny] ##  Bunnies array
  for bunny in bunnies.mitems:
    bunny = new Bunny
  var bunniesCount = 0 ##  Bunnies counter
  setTargetFPS(60)
  ##  Set our game to run at 60 frames-per-second
  ## --------------------------------------------------------------------------------------
  ##  Main game loop
  while not windowShouldClose(): ##  Detect window close button or ESC key
    ##  Update
    ## ----------------------------------------------------------------------------------
    if isMouseButtonDown(Left_Button):
      ##  Create more bunnies
      for i in 0..<100:
        if bunniesCount < MAX_BUNNIES:
          bunnies[bunniesCount].position = getMousePosition()
          bunnies[bunniesCount].speed.x = (getRandomValue(-250, 250).float / 60.0)
          bunnies[bunniesCount].speed.y = (getRandomValue(-250, 250).float / 60.0)
          bunnies[bunniesCount].color = Color(
            r: getRandomValue(50, 240).uint8,
            g: getRandomValue(80, 240).uint8,
            b: getRandomValue(100, 240).uint8,
            a: 255
          )
          inc(bunniesCount)
    for i in 0..<bunniesCount:
      bunnies[i].position.x += bunnies[i].speed.x
      bunnies[i].position.y += bunnies[i].speed.y
      if ((bunnies[i].position.x + texBunny.width / 2.0) > getScreenWidth()) or
          ((bunnies[i].position.x + texBunny.width div 2) < 0):
        bunnies[i].speed.x = bunnies[i].speed.x * -1
      if ((bunnies[i].position.y + texBunny.height div 2) > getScreenHeight()) or
          ((bunnies[i].position.y + texBunny.height div 2 - 40) < 0):
        bunnies[i].speed.y = bunnies[i].speed.y * -1
    ## ----------------------------------------------------------------------------------
    ##  Draw
    ## ----------------------------------------------------------------------------------
    beginDrawing()
    clearBackground(Raywhite)
    for i in 0..<bunniesCount:
      ##  NOTE: When internal batch buffer limit is reached (MAX_BATCH_ELEMENTS),
      ##  a draw call is launched and buffer starts being filled again;
      ##  before issuing a draw call, updated vertex data from internal CPU buffer is send to GPU...
      ##  Process of sending data is costly and it could happen that GPU data has not been completely
      ##  processed for drawing while new data is tried to be sent (updating current in-use buffers)
      ##  it could generates a stall and consequently a frame drop, limiting the number of drawn bunnies
      drawTexture(texBunny, bunnies[i].position.x.cint, bunnies[i].position.y.cint,
                  bunnies[i].color)
    drawRectangle(0, 0, screenWidth, 40, Black)
    drawText(textFormat("bunnies: %i", bunniesCount), 120, 10, 20, Green)
    drawText(textFormat("batched draw calls: %i",
                        1 + bunniesCount div MAX_BATCH_ELEMENTS), 320, 10, 20, Maroon)
    drawFPS(10, 10)
    endDrawing()
  ## ----------------------------------------------------------------------------------
  ##  De-Initialization
  ## --------------------------------------------------------------------------------------
  unloadTexture(texBunny)
  ##  Unload bunny texture
  closeWindow()
  ##  Close window and OpenGL context
  ## --------------------------------------------------------------------------------------


block textures_draw_tiled:
  # ******************************************************************************************
  #
  #    raylib [textures] example - Draw part of the texture tiled
  #
  #    This example has been created using raylib 3.0 (www.raylib.com)
  #    raylib is licensed under an unmodified zlib/libpng license (View raylib.h for details)
  #
  #    Copyright (c) 2020 Vlad Adrian (@demizdor) and Ramon Santamaria (@raysan5)
  #    Converted in 2021 by greenfork
  #
  # ******************************************************************************************


  const
    OPT_WIDTH = 220
    MARGIN_SIZE = 8
    COLOR_SIZE = 16

  ##  Initialization
  ## --------------------------------------------------------------------------------------
  var screenWidth = 800
  var screenHeight = 450
  setConfigFlags(WindowResizable)
  ##  Make the window resizable
  initWindow(screenWidth, screenHeight,
             "raylib [textures] example - Draw part of a texture tiled")
  ##  NOTE: Textures MUST be loaded after Window initialization (OpenGL context is requiRed)
  var texPattern: Texture = loadTexture("resources/patterns.png")
  setTextureFilter(texPattern, Trilinear)
  ##  Makes the texture smoother when upscaled
  ##  Coordinates for all patterns inside the texture
  var recPattern = [
    Rectangle(x: 3, y: 3, width: 66, height: 66),
    Rectangle(x: 75, y: 3, width: 100, height: 100),
    Rectangle(x: 3, y: 75, width: 66, height: 66),
    Rectangle(x: 7, y: 156, width: 50, height: 50),
    Rectangle(x: 85, y: 106, width: 90, height: 45),
    Rectangle(x: 75, y: 154, width: 100, height: 60)
  ]
  ##  Setup colors
  var colors = [Black, Maroon, Orange, Blue, Purple, Beige, Lime, Red, Darkgray,
                      Skyblue]
  const
    MAX_COLORS = colors.len
  var colorRec: array[MAX_COLORS, Rectangle]
  ##  Calculate rectangle for each color
  var
    i = 0
    x = 0
    y = 0
  while i < MAX_COLORS:
    colorRec[i].x = (float) 2 + MARGIN_SIZE + x
    colorRec[i].y = (float) 22 + 256 + MARGIN_SIZE + y
    colorRec[i].width = COLOR_SIZE * 2
    colorRec[i].height = COLOR_SIZE
    if i == (MAX_COLORS div 2 - 1):
      x = 0
      inc(y, COLOR_SIZE + MARGIN_SIZE)
    else:
      inc(x, (COLOR_SIZE * 2 + MARGIN_SIZE))
    inc(i)
  var
    activePattern = 0
    activeCol = 0
  var
    scale = 1.0
    rotation = 0.0
  setTargetFPS(60)
  ## ---------------------------------------------------------------------------------------
  ##  Main game loop
  while not windowShouldClose(): ##  Detect window close button or ESC key
    ##  Update
    ## ----------------------------------------------------------------------------------
    screenWidth = getScreenWidth()
    screenHeight = getScreenHeight()
    ##  Handle mouse
    if isMouseButtonPressed(Left_Button):
      var mouse: Vector2 = getMousePosition()
      ##  Check which pattern was clicked and set it as the active pattern
      var i = 0
      while i < recPattern.len:
        if checkCollisionPointRec(mouse, Rectangle(x: 2 + MARGIN_SIZE + recPattern[i].x,
            y: 40 + MARGIN_SIZE + recPattern[i].y, width: recPattern[i].width,
            height: recPattern[i].height)):
          activePattern = i
          break
        inc(i)
      ##  Check to see which color was clicked and set it as the active color
      for i in 0..<MAX_COLORS:
        if checkCollisionPointRec(mouse, colorRec[i]):
          activeCol = i
          break
    if isKeyPressed(Up):
      scale += 0.25
    if isKeyPressed(Down):
      scale -= 0.25
    if scale > 10.0:
      scale = 10.0
    elif scale <= 0.0:           ##  Change rotation
      scale = 0.25
    if isKeyPressed(Left):
      rotation -= 25.0
    if isKeyPressed(Right):
      rotation += 25.0
    if isKeyPressed(Space):
      rotation = 0.0
      scale = 1.0
    beginDrawing()
    clearBackground(Raywhite)
    ##  Draw the tiled area
    drawTextureTiled(texPattern, recPattern[activePattern], Rectangle(
        x: OPT_WIDTH + MARGIN_SIZE, y: MARGIN_SIZE,
        width: (float) screenWidth - OPT_WIDTH - 2 * MARGIN_SIZE, height: (float) screenHeight - 2 * MARGIN_SIZE),
                     (0.0, 0.0), rotation, scale, colors[activeCol])
    ##  Draw options
    drawRectangle(MARGIN_SIZE, MARGIN_SIZE, OPT_WIDTH - MARGIN_SIZE,
                  screenHeight - 2 * MARGIN_SIZE, colorAlpha(Lightgray, 0.5))
    drawText("Select Pattern", 2 + MARGIN_SIZE, 30 + MARGIN_SIZE, 10, Black)
    drawTexture(texPattern, 2 + MARGIN_SIZE, 40 + MARGIN_SIZE, Black)
    drawRectangle((int)2 + MARGIN_SIZE + recPattern[activePattern].x,
                  (int)40 + MARGIN_SIZE + recPattern[activePattern].y,
                  (int)recPattern[activePattern].width,
                  (int)recPattern[activePattern].height, colorAlpha(Darkblue, 0.3))
    drawText("Select Color", 2 + MARGIN_SIZE, 10 + 256 + MARGIN_SIZE, 10, Black)
    for i in 0..<MAX_COLORS:
      drawRectangleRec(colorRec[i], colors[i])
      if activeCol == i:
        drawRectangleLinesEx(colorRec[i], 3, colorAlpha(White, 0.5))
    drawText("Scale (UP/DOWN to change)", 2 + MARGIN_SIZE, 80 + 256 + MARGIN_SIZE, 10,
             Black)
    drawText(textFormat("%.2fx", scale), 2 + MARGIN_SIZE, 92 + 256 + MARGIN_SIZE, 20, Black)
    drawText("Rotation (LEFT/RIGHT to change)", 2 + MARGIN_SIZE,
             122 + 256 + MARGIN_SIZE, 10, Black)
    drawText(textFormat("%.0f degrees", rotation), 2 + MARGIN_SIZE,
             134 + 256 + MARGIN_SIZE, 20, Black)
    drawText("Press [SPACE] to reset", 2 + MARGIN_SIZE, 164 + 256 + MARGIN_SIZE, 10,
             Darkblue)
    ##  Draw FPS
    drawText(textFormat("%i FPS", getFPS()), 2 + MARGIN_SIZE, 2 + MARGIN_SIZE, 20, Black)
    endDrawing()
    ## ----------------------------------------------------------------------------------
  ##  De-Initialization
  ## --------------------------------------------------------------------------------------
  unloadTexture(texPattern)
  ##  Unload texture
  closeWindow()
  ##  Close window and OpenGL context
  ## --------------------------------------------------------------------------------------


block textures_image_drawing:
  # ******************************************************************************************
  #
  #    raylib [textures] example - Image loading and drawing on it
  #
  #    NOTE: Images are loaded in CPU memory (RAM); textures are loaded in GPU memory (VRAM)
  #
  #    This example has been created using raylib 1.4 (www.raylib.com)
  #    raylib is licensed under an unmodified zlib/libpng license (View raylib.h for details)
  #
  #    Copyright (c) 2016 Ramon Santamaria (@raysan5)
  #    Converted in 2021 by greenfork
  #
  # ******************************************************************************************


  ##  Initialization
  ## --------------------------------------------------------------------------------------
  var screenWidth = 800
  var screenHeight = 450
  initWindow(screenWidth, screenHeight,
             "raylib [textures] example - image drawing")
  ##  NOTE: Textures MUST be loaded after Window initialization (OpenGL context is requiRed)
  var cat: Image = loadImage("resources/cat.png") ##  Load image in CPU memory (RAM)
  imageCrop(addr(cat), (100.0, 10.0, 280.0, 380.0)) ##  Crop an image piece
  imageFlipHorizontal(addr(cat)) ##  Flip cropped image horizontally
  imageResize(addr(cat), 150, 200) ##  Resize flipped-cropped image
  var parrots: Image = loadImage("resources/parrots.png") ##  Load image in CPU memory (RAM)
  ##  Draw one image over the other with a scaling of 1.5f
  imageDraw(
    addr(parrots),
    cat,
    Rectangle(x: 0.0, y: 0.0, width: cat.width.float, height: cat.height.float),
    Rectangle(x: 30.0, y: 40.0, width: cat.width.float*1.5, height: cat.height.float*1.5),
    White)
  imageCrop(addr(parrots), (0.0, 50.0, parrots.width.float, parrots.height.float - 100.0)) ##  Crop resulting image
  ##  Draw on the image with a few image draw methods
  imageDrawPixel(addr(parrots), 10, 10, Raywhite)
  imageDrawCircle(addr(parrots), 10, 10, 5, Raywhite)
  imageDrawRectangle(addr(parrots), 5, 20, 10, 10, Raywhite)
  unloadImage(cat)
  ##  Unload image from RAM
  ##  Load custom font for frawing on image
  var font: Font = loadFont("resources/custom_jupiter_crash.png")
  ##  Draw over image using custom font
  imageDrawTextEx(addr(parrots), font, "PARROTS & CAT", (300.0, 230.0),
                  font.baseSize.float, -2.0, White)
  unloadFont(font)
  ##  Unload custom spritefont (already drawn used on image)
  var texture: Texture2D = loadTextureFromImage(parrots)
  ##  Image converted to texture, uploaded to GPU memory (VRAM)
  unloadImage(parrots)
  ##  Once image has been converted to texture and uploaded to VRAM, it can be unloaded from RAM
  setTargetFPS(60)
  ## ---------------------------------------------------------------------------------------
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
    drawTexture(texture, screenWidth div 2 - texture.width div 2,
                screenHeight div 2 - texture.height div 2 - 40, White)
    drawRectangleLines(screenWidth div 2 - texture.width div 2,
                       screenHeight div 2 - texture.height div 2 - 40, texture.width,
                       texture.height, Darkgray)
    drawText("We are drawing only one texture from various images composed!",
             240, 350, 10, Darkgray)
    drawText("Source images have been cropped, scaled, flipped and copied one over the other.",
             190, 370, 10, Darkgray)
    endDrawing()
  ## ----------------------------------------------------------------------------------
  ##  De-Initialization
  ## --------------------------------------------------------------------------------------
  unloadTexture(texture)
  ##  Texture unloading
  closeWindow()
  ##  Close window and OpenGL context
  ## --------------------------------------------------------------------------------------


block textures_image_generation:
  # ******************************************************************************************
  #
  #    raylib [textures] example - Procedural images generation
  #
  #    This example has been created using raylib 1.8 (www.raylib.com)
  #    raylib is licensed under an unmodified zlib/libpng license (View raylib.h for details)
  #
  #    Copyright (c) 2O17 Wilhem Barbier (@nounoursheureux)
  #    Converted in 2021 by greenfork
  #
  # ******************************************************************************************


  const
    NUM_TEXTURES = 7


  ##  Initialization
  ## --------------------------------------------------------------------------------------
  var screenWidth = 800
  var screenHeight = 450
  initWindow(screenWidth, screenHeight,
             "raylib [textures] example - procedural images generation")
  var verticalGradient: Image = genImageGradientV(screenWidth, screenHeight, Red, Blue)
  var horizontalGradient: Image = genImageGradientH(screenWidth, screenHeight, Red,
      Blue)
  var radialGradient: Image = genImageGradientRadial(screenWidth, screenHeight, 0.0,
      White, Black)
  var checked: Image = genImageChecked(screenWidth, screenHeight, 32, 32, Red, Blue)
  var WhiteNoise: Image = genImageWhiteNoise(screenWidth, screenHeight, 0.5)
  var perlinNoise: Image = genImagePerlinNoise(screenWidth, screenHeight, 50, 50, 4.0)
  var cellular: Image = genImageCellular(screenWidth, screenHeight, 32)
  var textures: array[NUM_TEXTURES, Texture2D]
  textures[0] = loadTextureFromImage(verticalGradient)
  textures[1] = loadTextureFromImage(horizontalGradient)
  textures[2] = loadTextureFromImage(radialGradient)
  textures[3] = loadTextureFromImage(checked)
  textures[4] = loadTextureFromImage(WhiteNoise)
  textures[5] = loadTextureFromImage(perlinNoise)
  textures[6] = loadTextureFromImage(cellular)
  ##  Unload image data (CPU RAM)
  unloadImage(verticalGradient)
  unloadImage(horizontalGradient)
  unloadImage(radialGradient)
  unloadImage(checked)
  unloadImage(WhiteNoise)
  unloadImage(perlinNoise)
  unloadImage(cellular)
  var currentTexture = 0
  setTargetFPS(60)
  ## ---------------------------------------------------------------------------------------
  ##  Main game loop
  while not windowShouldClose():
    ##  Update
    ## ----------------------------------------------------------------------------------
    if isMouseButtonPressed(Left_Button) or isKeyPressed(Right):
      currentTexture = (currentTexture + 1) mod NUM_TEXTURES
      ##  Cycle between the textures
    beginDrawing()
    clearBackground(Raywhite)
    drawTexture(textures[currentTexture], 0, 0, White)
    drawRectangle(30, 400, 325, 30, fade(Skyblue, 0.5))
    drawRectangleLines(30, 400, 325, 30, fade(White, 0.5))
    drawText("MOUSE LEFT BUTTON to CYCLE PROCEDURAL TEXTURES", 40, 410, 10, White)
    case currentTexture
    of 0:
      drawText("VERTICAL GRADIENT", 560, 10, 20, Raywhite)
    of 1:
      drawText("HORIZONTAL GRADIENT", 540, 10, 20, Raywhite)
    of 2:
      drawText("RADIAL GRADIENT", 580, 10, 20, Lightgray)
    of 3:
      drawText("CHECKED", 680, 10, 20, Raywhite)
    of 4:
      drawText("WHITE NOISE", 640, 10, 20, Red)
    of 5:
      drawText("PERLIN NOISE", 630, 10, 20, Raywhite)
    of 6:
      drawText("CELLULAR", 670, 10, 20, Raywhite)
    else:
      discard
    endDrawing()
  ## ----------------------------------------------------------------------------------
  ##  De-Initialization
  ## --------------------------------------------------------------------------------------
  ##  Unload textures data (GPU VRAM)
  var i = 0
  while i < NUM_TEXTURES:
    unloadTexture(textures[i])
    inc(i)
  closeWindow()
  ##  Close window and OpenGL context
  ## --------------------------------------------------------------------------------------


block textures_image_loading:
  # ******************************************************************************************
  #
  #    raylib [textures] example - Image loading and texture creation
  #
  #    NOTE: Images are loaded in CPU memory (RAM); textures are loaded in GPU memory (VRAM)
  #
  #    This example has been created using raylib 1.3 (www.raylib.com)
  #    raylib is licensed under an unmodified zlib/libpng license (View raylib.h for details)
  #
  #    Copyright (c) 2015 Ramon Santamaria (@raysan5)
  #    Converted in 2021 by greenfork
  #
  # ******************************************************************************************



  ##  Initialization
  ## --------------------------------------------------------------------------------------
  var screenWidth = 800
  var screenHeight = 450
  initWindow(screenWidth, screenHeight,
             "raylib [textures] example - image loading")
  ##  NOTE: Textures MUST be loaded after Window initialization (OpenGL context is requiRed)
  var image: Image = loadImage("resources/raylib_logo.png")
  ##  Loaded in CPU memory (RAM)
  var texture: Texture2D = loadTextureFromImage(image)
  ##  Image converted to texture, GPU memory (VRAM)
  unloadImage(image)
  ##  Once image has been converted to texture and uploaded to VRAM, it can be unloaded from RAM
  ## ---------------------------------------------------------------------------------------
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
    drawTexture(texture, screenWidth div 2 - texture.width div 2,
                screenHeight div 2 - texture.height div 2, White)
    drawText("this IS a texture loaded from an image!", 300, 370, 10, Gray)
    endDrawing()
    ## ----------------------------------------------------------------------------------
  ##  De-Initialization
  ## --------------------------------------------------------------------------------------
  unloadTexture(texture)
  ##  Texture unloading
  closeWindow()
  ##  Close window and OpenGL context
  ## --------------------------------------------------------------------------------------


block textures_image_processing:
  #*******************************************************************************************
  #
  #   raylib [textures] example - Image processing
  #
  #   NOTE: Images are loaded in CPU memory (RAM) textures are loaded in GPU memory (VRAM)
  #
  #   This example has been created using raylib 1.4 (www.raylib.com)
  #   raylib is licensed under an unmodified zlib/libpng license (View raylib.h for details)
  #
  #   Copyright (c) 2016 Ramon Santamaria (@raysan5)
  #   /Converted in 2*20 by Guevara-chan.
  #   Adapted in 2021 by greenfork
  #
  #*******************************************************************************************


  const NUM_PROCESSES = 8

  type ImageProcess = enum
      NONE = 0
      COLOR_GRAYSCALE
      COLOR_TINT
      COLOR_INVERT
      COLOR_CONTRAST
      COLOR_BRIGHTNESS
      FLIP_VERTICAL
      FLIP_HORIZONTAL

  const processText = [
      "NO PROCESSING",
      "COLOR GRAYSCALE",
      "COLOR TINT",
      "COLOR INVERT",
      "COLOR CONTRAST",
      "COLOR BRIGHTNESS",
      "FLIP VERTICAL",
      "FLIP HORIZONTAL"
  ]

  #  Initialization
  # --------------------------------------------------------------------------------------
  const screenWidth = 800
  const screenHeight = 450

  initWindow screenWidth, screenHeight, "raylib [textures] example - image processing"

  #  NOTE: Textures MUST be loaded after Window initialization (OpenGL context is required)

  var image = loadImage("resources/parrots.png") #  Loaded in CPU memory (RAM)
  imageFormat image.addr, UNCOMPRESSED_R8G8B8A8  #  Format image to RGBA 32bit (required for texture update) <-- ISSUE
  let texture = loadTextureFromImage image       #  Image converted to texture, GPU memory (VRAM)

  var
      currentProcess = NONE
      textureReload = false
      selectRecs: array[NUM_PROCESSES, Rectangle]

  for i in 0..<NUM_PROCESSES:
      selectRecs[i] = (x: 40.0, y: (50 + 32*i).float, width: 150.0, height: 30.0)

  60.setTargetFPS
  # ---------------------------------------------------------------------------------------

  #  Main game loop
  while not windowShouldClose():    #  Detect window close button or ESC key
      #  Update
      # ----------------------------------------------------------------------------------
      if isKeyPressed(DOWN):
          currentProcess = (if currentProcess.int == 7: 0 else: currentProcess.int + 1).ImageProcess
          textureReload = true

      elif isKeyPressed(UP):
          currentProcess = (if currentProcess.int == 0: 7 else: currentProcess.int - 1).ImageProcess
          textureReload = true

      if textureReload:
          unloadImage image                          #  Unload current image data
          image = loadImage("resources/parrots.png") #  Re-load image data

          #  NOTE: Image processing is a costly CPU process to be done every frame,
          #  If image processing is required in a frame-basis, it should be done
          #  with a texture and by shaders
          case currentProcess:
              of COLOR_GRAYSCALE: imageColorGrayscale image.addr
              of COLOR_TINT:      imageColorTint image.addr, GREEN
              of COLOR_INVERT:    imageColorInvert image.addr
              of COLOR_CONTRAST:  imageColorContrast image.addr, -40
              of COLOR_BRIGHTNESS:imageColorBrightness image.addr, -80
              of FLIP_VERTICAL:   imageFlipVertical image.addr
              of FLIP_HORIZONTAL: imageFlipHorizontal image.addr
              else: discard

          let pixels = loadImageColors(image) #  Get pixel data from image (RGBA 32bit)
          updateTexture texture, pixels    #  Update texture with new image data
          pixels.c_free                    #  Unload pixels data from RAM

          textureReload = false
      # ----------------------------------------------------------------------------------

      #  Draw
      # ----------------------------------------------------------------------------------
      beginDrawing()

      clearBackground RAYWHITE

      drawText "IMAGE PROCESSING:", 40, 30, 10, DARKGRAY

      #  Draw rectangles
      for i in 0..<NUM_PROCESSES:
          drawRectangleRec selectRecs[i], (if i == currentProcess.int: SKYBLUE else: LIGHTGRAY)
          drawRectangleLines selectRecs[i].x.int, selectRecs[i].y.int, selectRecs[i].width.int,
              selectRecs[i].height.int, (if i == currentProcess.int: BLUE else: GRAY)
          drawText processText[i], (selectRecs[i].x + selectRecs[i].width/2 - measureText(processText[i], 10)/2).int,
              selectRecs[i].y.int + 11, 10, (if i == currentProcess.int: DARKBLUE else: DARKGRAY)

      drawTexture texture, screenWidth - texture.width - 60, screenHeight div 2 - texture.height div 2, WHITE
      drawRectangleLines screenWidth - texture.width - 60, screenHeight div 2 - texture.height div 2, texture.width, texture.height, BLACK

      endDrawing()
      # ----------------------------------------------------------------------------------

  #  De-Initialization
  # --------------------------------------------------------------------------------------
  unloadTexture texture        #  Unload texture from VRAM
  unloadImage image            #  Unload image from RAM

  closeWindow()                #  Close window and OpenGL context
  # --------------------------------------------------------------------------------------


block textures_image_text:
  # ******************************************************************************************
  #
  #    raylib [texture] example - Image text drawing using TTF generated spritefont
  #
  #    This example has been created using raylib 1.8 (www.raylib.com)
  #    raylib is licensed under an unmodified zlib/libpng license (View raylib.h for details)
  #
  #    Copyright (c) 2017 Ramon Santamaria (@raysan5)
  #    Converted in 2021 by greenfork
  #
  # ******************************************************************************************


  ##  Initialization
  ## --------------------------------------------------------------------------------------
  var screenWidth = 800
  var screenHeight = 450
  initWindow(screenWidth, screenHeight,
             "raylib [texture] example - image text drawing")
  var parrots: Image = loadImage("resources/parrots.png")
  ##  Load image in CPU memory (RAM)
  ##  TTF Font loading with custom generation parameters
  var font: Font = loadFontEx("resources/KAISG.ttf", 64, nil, 0)
  ##  Draw over image using custom font
  imageDrawTextEx(addr(parrots), font, "[Parrots font drawing]",
                  (20.0, 20.0), cast[cfloat](font.baseSize), 0.0, Red)
  var texture: Texture2D = loadTextureFromImage(parrots)
  ##  Image converted to texture, uploaded to GPU memory (VRAM)
  unloadImage(parrots)
  ##  Once image has been converted to texture and uploaded to VRAM, it can be unloaded from RAM
  var position: Vector2 = ((float)(screenWidth div 2 - texture.width div 2),
                       (float)(screenHeight div 2 - texture.height div 2 - 20))
  var showFont: bool = false
  setTargetFPS(60)
  ## --------------------------------------------------------------------------------------
  ##  Main game loop
  while not windowShouldClose(): ##  Detect window close button or ESC key
    ##  Update
    ## ----------------------------------------------------------------------------------
    if isKeyDown(Space):
      showFont = true
    else:
      showFont = false
    ## ----------------------------------------------------------------------------------
    ##  Draw
    ## ----------------------------------------------------------------------------------
    beginDrawing()
    clearBackground(Raywhite)
    if not showFont:
      ##  Draw texture with text already drawn inside
      drawTextureV(texture, position, White)
      ##  Draw text directly using sprite font
      drawTextEx(font, "[Parrots font drawing]", Vector2(x: position.x + 20,
                 y: position.y + 20 + 280), (float)font.baseSize, 0.0, White)
    else:
      drawTexture(font.texture, screenWidth div 2 - font.texture.width div 2, 50, Black)
    drawText("PRESS SPACE to SEE USED SPRITEFONT ", 290, 420, 10, Darkgray)
    endDrawing()
  ## ----------------------------------------------------------------------------------
  ##  De-Initialization
  ## --------------------------------------------------------------------------------------
  unloadTexture(texture)
  ##  Texture unloading
  unloadFont(font)
  ##  Unload custom spritefont
  closeWindow()
  ##  Close window and OpenGL context
  ## --------------------------------------------------------------------------------------


block textures_logo_raylib:
  # ******************************************************************************************
  #
  #    raylib [textures] example - Texture loading and drawing
  #
  #    This example has been created using raylib 1.0 (www.raylib.com)
  #    raylib is licensed under an unmodified zlib/libpng license (View raylib.h for details)
  #
  #    Copyright (c) 2014 Ramon Santamaria (@raysan5)
  #    Converted in 2021 by greenfork
  #
  # ******************************************************************************************



  ##  Initialization
  ## --------------------------------------------------------------------------------------
  var screenWidth = 800
  var screenHeight = 450
  initWindow(screenWidth, screenHeight,
             "raylib [textures] example - texture loading and drawing")
  ##  NOTE: Textures MUST be loaded after Window initialization (OpenGL context is requiRed)
  var texture: Texture2D = loadTexture("resources/raylib_logo.png")
  ##  Texture loading
  ## ---------------------------------------------------------------------------------------
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
    drawTexture(texture, screenWidth div 2 - texture.width div 2,
                screenHeight div 2 - texture.height div 2, White)
    drawText("this IS a texture!", 360, 370, 10, Gray)
    endDrawing()
    ## ----------------------------------------------------------------------------------
  ##  De-Initialization
  ## --------------------------------------------------------------------------------------
  unloadTexture(texture)
  ##  Texture unloading
  closeWindow()
  ##  Close window and OpenGL context
  ## --------------------------------------------------------------------------------------


block textures_mouse_painting:
  # ******************************************************************************************
  #
  #    raylib [textures] example - Mouse painting
  #
  #    This example has been created using raylib 2.5 (www.raylib.com)
  #    raylib is licensed under an unmodified zlib/libpng license (View raylib.h for details)
  #
  #    Example contributed by Chris Dill (@MysteriousSpace) and reviewed by Ramon Santamaria (@raysan5)
  #
  #    Copyright (c) 2019 Chris Dill (@MysteriousSpace) and Ramon Santamaria (@raysan5)
  #    Converted in 2021 by greenfork
  #
  # ******************************************************************************************


  const
    MAX_COLORS_COUNT = 23

  ##  Initialization
  ## --------------------------------------------------------------------------------------
  var screenWidth = 800
  var screenHeight = 450
  initWindow(screenWidth, screenHeight,
             "raylib [textures] example - mouse painting")
  ##  Colours to choose from
  var colors: array[MAX_COLORS_COUNT, Color] = [Raywhite, Yellow, Gold, Orange, Pink, Red,
      Maroon, Green, Lime, Darkgreen, Skyblue, Blue, Darkblue, Purple, Violet,
      Darkpurple, Beige, Brown, Darkbrown, Lightgray, Gray, Darkgray, Black]
  ##  Define colorsRecs data (for every rectangle)
  var colorsRecs: array[MAX_COLORS_COUNT, Rectangle]
  for i in 0..<MAX_COLORS_COUNT:
    colorsRecs[i].x = (float) 10 + 30 * i + 2 * i
    colorsRecs[i].y = 10.0
    colorsRecs[i].width = 30
    colorsRecs[i].height = 30
  var colorSelected = 0
  var colorSelectedPrev = colorSelected
  var colorMouseHover = 0
  var brushSize = 20
  var btnSaveRec: Rectangle = (750.0, 10.0, 40.0, 30.0)
  var btnSaveMouseHover: bool = false
  var showSaveMessage: bool = false
  var saveMessageCounter = 0
  ##  Create a RenderTexture2D to use as a canvas
  var target: RenderTexture2D = loadRenderTexture(screenWidth, screenHeight)
  ##  Clear render texture before entering the game loop
  beginTextureMode(target)
  clearBackground(colors[0])
  endTextureMode()
  setTargetFPS(120)
  ##  Set our game to run at 120 frames-per-second
  ## --------------------------------------------------------------------------------------
  ##  Main game loop
  while not windowShouldClose(): ##  Detect window close button or ESC key
    ##  Update
    ## ----------------------------------------------------------------------------------
    var mousePos: Vector2 = getMousePosition()
    ##  Move between colors with keys
    if isKeyPressed(Right):
      inc(colorSelected)
    elif isKeyPressed(Left):
      dec(colorSelected)
    if colorSelected >= MAX_COLORS_COUNT:
      colorSelected = MAX_COLORS_COUNT - 1
    elif colorSelected < 0:      ##  Choose color with mouse
      colorSelected = 0
    var i = 0
    while i < MAX_COLORS_COUNT:
      if checkCollisionPointRec(mousePos, colorsRecs[i]):
        colorMouseHover = i
        break
      else:
        colorMouseHover = -1
      inc(i)
    if (colorMouseHover >= 0) and isMouseButtonPressed(Left_Button):
      colorSelected = colorMouseHover
      colorSelectedPrev = colorSelected
    brushSize += getMouseWheelMove().int * 5
    if brushSize < 2:
      brushSize = 2
    if brushSize > 50:
      brushSize = 50
    if isKeyPressed(C):
      ##  Clear render texture to clear color
      beginTextureMode(target)
      clearBackground(colors[0])
      endTextureMode()
    if isMouseButtonDown(Left_Button) or
        (getGestureDetected() == Drag):
      ##  Paint circle into render texture
      ##  NOTE: To avoid discontinuous circles, we could store
      ##  previous-next mouse points and just draw a line using brush size
      beginTextureMode(target)
      if mousePos.y > 50:
        drawCircle(mousePos.x.int, mousePos.y.int, brushSize.float, colors[colorSelected])
      endTextureMode()
    if isMouseButtonDown(Right_Button):
      colorSelected = 0
      ##  Erase circle from render texture
      beginTextureMode(target)
      if mousePos.y > 50:
        drawCircle(mousePos.x.int, mousePos.y.int, brushSize.float, colors[0])
      endTextureMode()
    else:
      colorSelected = colorSelectedPrev
    ##  Check mouse hover save button
    if checkCollisionPointRec(mousePos, btnSaveRec):
      btnSaveMouseHover = true
    else:
      btnSaveMouseHover = false
    ##  Image saving logic
    ##  NOTE: Saving painted texture to a default named image
    if (btnSaveMouseHover and isMouseButtonReleased(Left_Button)) or
        isKeyPressed(S):
      var image: Image = getTextureData(target.texture)
      imageFlipVertical(addr(image))
      discard exportImage(image, "my_amazing_texture_painting.png")
      unloadImage(image)
      showSaveMessage = true
    if showSaveMessage:
      ##  On saving, show a full screen message for 2 seconds
      inc(saveMessageCounter)
      if saveMessageCounter > 240:
        showSaveMessage = false
        saveMessageCounter = 0
    beginDrawing()
    clearBackground(Raywhite)
    ##  NOTE: Render texture must be y-flipped due to default OpenGL coordinates (left-bottom)
    drawTextureRec(
      target.texture,
      Rectangle(x: 0.0, y: 0.0, width: target.texture.width.float, height: -target.texture.height.float),
      Vector2(x: 0, y: 0),
      White
    )
    ##  Draw drawing circle for reference
    if mousePos.y > 50:
      if isMouseButtonDown(Right_Button):
        drawCircleLines(mousePos.x.int, mousePos.y.int, brushSize.float, Gray)
      else:
        drawCircle(getMouseX().int, getMouseY().int, brushSize.float, colors[colorSelected])
    drawRectangle(0, 0, getScreenWidth(), 50, Raywhite)
    drawLine(0, 50, getScreenWidth(), 50, Lightgray)
    ##  Draw color selection rectangles
    for i in 0..<MAX_COLORS_COUNT:
      drawRectangleRec(colorsRecs[i], colors[i])
    drawRectangleLines(10, 10, 30, 30, Lightgray)
    if colorMouseHover >= 0:
      drawRectangleRec(colorsRecs[colorMouseHover], fade(White, 0.6))
    drawRectangleLinesEx(
      Rectangle(
        x: colorsRecs[colorSelected].x - 2,
        y: colorsRecs[colorSelected].y - 2,
        width: colorsRecs[colorSelected].width + 4,
        height: colorsRecs[colorSelected].height + 4
      ),
      2,
      Black
    )

    drawRectangleLinesEx(btnSaveRec, 2, if btnSaveMouseHover: Red else: Black)
    drawText("SAVE!", 755, 20, 10, if btnSaveMouseHover: Red else: Black)
    ##  Draw save image message
    if showSaveMessage:
      drawRectangle(0, 0, getScreenWidth(), getScreenHeight(), fade(Raywhite, 0.8))
      drawRectangle(0, 150, getScreenWidth(), 80, Black)
      drawText("IMAGE SAVED:  my_amazing_texture_painting.png", 150, 180, 20,
               Raywhite)
    endDrawing()
  ## ----------------------------------------------------------------------------------
  ##  De-Initialization
  ## --------------------------------------------------------------------------------------
  unloadRenderTexture(target)
  ##  Unload render texture
  closeWindow()
  ##  Close window and OpenGL context
  ## --------------------------------------------------------------------------------------


block textures_npatch_drawing:
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


block textures_particles_blending:
  #*******************************************************************************************
  #
  #   raylib example - particles blending
  #
  #   This example has been created using raylib 1.7 (www.raylib.com)
  #   raylib is licensed under an unmodified zlib/libpng license (View raylib.h for details)
  #
  #   Copyright (c) 2017 Ramon Santamaria (@raysan5)
  #   /Converted in 2*20 by Guevara-chan.
  #   Adapted in 2021 by greenfork
  #
  #*******************************************************************************************


  const MAX_PARTICLES = 200

  #  Particle structure with basic data
  type Particle = object
      position: Vector2
      color: Color
      alpha: float
      size: float
      rotation: float
      active: bool        #  NOTE: Use it to activate/deactive particle

  #  Initialization
  # --------------------------------------------------------------------------------------
  const screenWidth = 800
  const screenHeight = 450

  initWindow screenWidth, screenHeight, "raylib [textures] example - particles blending"

  #  Particles pool, reuse them!
  var mouseTail: array[MAX_PARTICLES, Particle]

  #  Initialize particles
  for i in 0..<MAX_PARTICLES:
      mouseTail[i].position = (x: 0.0, y: 0.0)
      mouseTail[i].color = Color(r: getRandomValue(0, 255).uint8, g: getRandomValue(0, 255).uint8,
          b: getRandomValue(0, 255).uint8, a: 255u8)
      mouseTail[i].alpha = 1.0
      mouseTail[i].size = getRandomValue(1, 30).float / 20.0
      mouseTail[i].rotation = getRandomValue(0, 360).float
      mouseTail[i].active = false

  let
      gravity = 3.0
      smoke = loadTexture("resources/smoke.png")

  var blending = BlendMode.ALPHA

  60.setTargetFPS
  # --------------------------------------------------------------------------------------

  #  Main game loop
  while not windowShouldClose():    #  Detect window close button or ESC key
      #  Update
      # ----------------------------------------------------------------------------------

      #  Activate one particle every frame and Update active particles
      #  NOTE: Particles initial position should be mouse position when activated
      #  NOTE: Particles fall down with gravity and rotation... and disappear after 2 seconds (alpha = 0)
      #  NOTE: When a particle disappears, active = false and it can be reused.

      for i in 0..<MAX_PARTICLES:
          if not mouseTail[i].active:
              mouseTail[i].active = true
              mouseTail[i].alpha = 1.0
              mouseTail[i].position = getMousePosition()
              break

      for i in 0..<MAX_PARTICLES:
          if mouseTail[i].active:
              mouseTail[i].position.y += gravity
              mouseTail[i].alpha -= 0.01
              if mouseTail[i].alpha <= 0.0: mouseTail[i].active = false
              mouseTail[i].rotation += 5.0

      if isKeyPressed(SPACE):
          blending = (if blending == ALPHA: ADDITIVE else: ALPHA)
      # ----------------------------------------------------------------------------------

      #  Draw
      # ----------------------------------------------------------------------------------
      beginDrawing()

      clearBackground DARKGRAY

      beginBlendMode blending

          #  Draw active particles
      for i in 0..<MAX_PARTICLES:
          if mouseTail[i].active: drawTexturePro smoke,
              Rectangle(x: 0.0, y: 0.0, width: smoke.width.float, height: smoke.height.float),
              Rectangle(x: mouseTail[i].position.x, y: mouseTail[i].position.y, width: smoke.width*mouseTail[i].size.cfloat,
                  height: smoke.height*mouseTail[i].size.cfloat),
              (x: smoke.width*mouseTail[i].size.cfloat/2.0, y: smoke.height*mouseTail[i].size.cfloat/2.0),
              mouseTail[i].rotation, fade(mouseTail[i].color, mouseTail[i].alpha)

      endBlendMode()

      drawText("PRESS SPACE to CHANGE BLENDING MODE", 180, 20, 20, BLACK)

      if (blending == ALPHA): drawText "ALPHA BLENDING", 290, screenHeight - 40, 20, BLACK
      else: drawText "ADDITIVE BLENDING", 280, screenHeight - 40, 20, RAYWHITE

      endDrawing()
      # ----------------------------------------------------------------------------------

  #  De-Initialization
  # --------------------------------------------------------------------------------------
  unloadTexture smoke

  closeWindow()        #  Close window and OpenGL context
  # --------------------------------------------------------------------------------------


block textures_raw_data:
  #*******************************************************************************************
  #
  #   raylib [textures] example - Load textures from raw data
  #
  #   NOTE: Images are loaded in CPU memory (RAM) textures are loaded in GPU memory (VRAM)
  #
  #   This example has been created using raylib 1.3 (www.raylib.com)
  #   raylib is licensed under an unmodified zlib/libpng license (View raylib.h for details)
  #
  #   Copyright (c) 2015 Ramon Santamaria (@raysan5)
  #   /Converted in 2*20 by Guevara-chan.
  #   Adapted in 2021 by greenfork
  #
  #*******************************************************************************************


  #  Initialization
  # --------------------------------------------------------------------------------------
  const screenWidth = 800
  const screenHeight = 450

  # Generate a checked texture by code
  let
    width: int32 = 960
    height: int32 = 480

  initWindow screenWidth, screenHeight, "raylib [textures] example - texture from raw data"

  # NOTE: Textures MUST be loaded after Window initialization (OpenGL context is required)

  # Load RAW image data (512x512, 32bit RGBA, no file header)
  let
    fudesumiRaw = loadImageRaw("resources/fudesumi.raw", 384, 512, UNCOMPRESSED_R8G8B8A8, 0)
    fudesumi = loadTextureFromImage(fudesumiRaw)  #  Upload CPU (RAM) image to GPU (VRAM)
  # unloadImage fudesumiRaw                           #  Unload CPU (RAM) image data

  # Dynamic memory allocation to store pixels data (Color type)
  var pixels = cast[ptr UncheckedArray[Color]](memAlloc(width*height * sizeof(Color)))

  for y in 0..<height:
    for x in 0..<width:
      pixels[y*width + x] = (if (((x div 32+y div 32) div 1) %% 2 == 0): Orange else: Gold)

  # Load pixels data into an image structure and create texture
  let
    checkedIm = Image(
      data: pixels,
      width: width,
      height: height,
      format: UNCOMPRESSED_R8G8B8A8,
      mipmaps: 1
    )
    checked = loadTextureFromImage(checkedIm)
  #UnloadImage checkedIm         #  Unload CPU (RAM) image data (do not do this in Nim, seriously)
  # ---------------------------------------------------------------------------------------

  #  Main game loop
  while not windowShouldClose(): #  Detect window close button or ESC key
    #  Update
    # ----------------------------------------------------------------------------------
    #  TODO: Update your variables here
    # ----------------------------------------------------------------------------------

    #  Draw
    # ----------------------------------------------------------------------------------
    beginDrawing()

    clearBackground(RAYWHITE)

    drawTexture(
      checked,
      screenWidth div 2 - checked.width div 2,
      screenHeight div 2 - checked.height div 2,
      fade(White, 0.5f)
    )
    drawTexture fudesumi, 430, -30, White

    drawText "CHECKED TEXTURE ", 84, 85, 30, Brown
    drawText "GENERATED by CODE", 72, 148, 30, Brown
    drawText "and RAW IMAGE LOADING", 46, 210, 30, Brown

    drawText "(c) Fudesumi sprite by Eiden Marsal", 310, screenHeight - 20, 10, Brown

    endDrawing()
  # ----------------------------------------------------------------------------------

  #  De-Initialization
  # --------------------------------------------------------------------------------------
  unloadTexture fudesumi     #  Texture unloading
  unloadTexture checked      #  Texture unloading

  closeWindow()              #  Close window and OpenGL context
  # --------------------------------------------------------------------------------------


block textures_rectangle:
  # ******************************************************************************************
  #
  #    raylib [textures] example - Texture loading and drawing a part defined by a rectangle
  #
  #    This example has been created using raylib 1.3 (www.raylib.com)
  #    raylib is licensed under an unmodified zlib/libpng license (View raylib.h for details)
  #
  #    Copyright (c) 2014 Ramon Santamaria (@raysan5)
  #    Converted in 2021 by greenfork
  #
  # ******************************************************************************************


  const
    MAX_FRAME_SPEED = 15
    MIN_FRAME_SPEED = 1


  ##  Initialization
  ## --------------------------------------------------------------------------------------
  var screenWidth = 800
  var screenHeight = 450
  initWindow(screenWidth, screenHeight,
             "raylib [texture] example - texture rectangle")
  ##  NOTE: Textures MUST be loaded after Window initialization (OpenGL context is requiRed)
  var scarfy: Texture2D = loadTexture("resources/scarfy.png")
  ##  Texture loading
  var position: Vector2 = (350.0, 280.0)
  var frameRec: Rectangle = (0.0, 0.0, (float)(scarfy.width div 6),
                         (float)(scarfy.height))
  var currentFrame = 0
  var framesCounter = 0
  var framesSpeed = 8
  ##  Number of spritesheet frames shown by second
  setTargetFPS(60)
  ##  Set our game to run at 60 frames-per-second
  ## --------------------------------------------------------------------------------------
  ##  Main game loop
  while not windowShouldClose(): ##  Detect window close button or ESC key
    ##  Update
    ## ----------------------------------------------------------------------------------
    inc(framesCounter)
    if framesCounter >= (60 div framesSpeed):
      framesCounter = 0
      inc(currentFrame)
      if currentFrame > 5:
        currentFrame = 0
      frameRec.x = (currentFrame * (scarfy.width div 6)).float
    if isKeyPressed(Right):
      inc(framesSpeed)
    elif isKeyPressed(Left):
      dec(framesSpeed)
    if framesSpeed > MAX_FRAME_SPEED:
      framesSpeed = MAX_FRAME_SPEED
    elif framesSpeed < MIN_FRAME_SPEED: ## ----------------------------------------------------------------------------------
                                    ##  Draw
                                    ## ----------------------------------------------------------------------------------
      framesSpeed = MIN_FRAME_SPEED
    beginDrawing()
    clearBackground(Raywhite)
    drawTexture(scarfy, 15, 40, White)
    drawRectangleLines(15, 40, scarfy.width, scarfy.height, Lime)
    drawRectangleLines(15 + frameRec.x.int, 40 + frameRec.y.int, frameRec.width.int,
                       frameRec.height.int, Red)
    drawText("FRAME SPEED: ", 165, 210, 10, Darkgray)
    drawText(textFormat("%02i FPS", framesSpeed), 575, 210, 10, Darkgray)
    drawText("PRESS RIGHT/LEFT KEYS to CHANGE SPEED!", 290, 240, 10, Darkgray)
    var i = 0
    while i < MAX_FRAME_SPEED:
      if i < framesSpeed:
        drawRectangle(250 + 21 * i, 205, 20, 20, Red)
      drawRectangleLines(250 + 21 * i, 205, 20, 20, Maroon)
      inc(i)
    drawTextureRec(scarfy, frameRec, position, White)
    ##  Draw part of the texture
    drawText("(c) Scarfy sprite by Eiden Marsal", screenWidth - 200,
             screenHeight - 20, 10, Gray)
    endDrawing()
  ## ----------------------------------------------------------------------------------
  ##  De-Initialization
  ## --------------------------------------------------------------------------------------
  unloadTexture(scarfy)
  ##  Texture unloading
  closeWindow()
  ##  Close window and OpenGL context
  ## --------------------------------------------------------------------------------------


block textures_sprite_button:
  # ******************************************************************************************
  #
  #    raylib [textures] example - sprite button
  #
  #    This example has been created using raylib 2.5 (www.raylib.com)
  #    raylib is licensed under an unmodified zlib/libpng license (View raylib.h for details)
  #
  #    Copyright (c) 2019 Ramon Santamaria (@raysan5)
  #    Converted in 2021 by greenfork
  #
  # ******************************************************************************************


  const
    NUM_FRAMES = 3

  ##  Initialization
  ## --------------------------------------------------------------------------------------
  var screenWidth = 800
  var screenHeight = 450
  initWindow(screenWidth, screenHeight,
             "raylib [textures] example - sprite button")
  initAudioDevice()
  ##  Initialize audio device
  var fxButton: Sound = loadSound("resources/buttonfx.wav")
  ##  Load button sound
  var button: Texture2D = loadTexture("resources/button.png")
  ##  Load button texture
  ##  Define frame rectangle for drawing
  var frameHeight = button.height div NUM_FRAMES
  var sourceRec: Rectangle = (0.0, 0.0, button.width.float, frameHeight.float)
  ##  Define button bounds on screen
  var btnBounds: Rectangle = ((float)screenWidth div 2 - button.width div 2, (float)screenHeight div 2 -
      button.height div NUM_FRAMES div 2, button.width.float, frameHeight.float)
  var btnState = 0
  ##  Button state: 0-NORMAL, 1-MOUSE_HOVER, 2-PRESSED
  var btnAction: bool = false
  ##  Button action should be activated
  var mousePoint: Vector2
  setTargetFPS(60)
  ## --------------------------------------------------------------------------------------
  ##  Main game loop
  while not windowShouldClose(): ##  Detect window close button or ESC key
    ##  Update
    ## ----------------------------------------------------------------------------------
    mousePoint = getMousePosition()
    btnAction = false
    ##  Check button state
    if checkCollisionPointRec(mousePoint, btnBounds):
      if isMouseButtonDown(Left_Button):
        btnState = 2
      else:
        btnState = 1
      if isMouseButtonReleased(Left_Button):
        btnAction = true
    else:
      btnState = 0
    if btnAction:
      playSound(fxButton)
      ##  TODO: Any desiRed action
    sourceRec.y = (float)btnState * frameHeight
    ## ----------------------------------------------------------------------------------
    ##  Draw
    ## ----------------------------------------------------------------------------------
    beginDrawing()
    clearBackground(Raywhite)
    drawTextureRec(button, sourceRec, (btnBounds.x.float, btnBounds.y.float), White)
    ##  Draw button frame
    endDrawing()
  ## ----------------------------------------------------------------------------------
  ##  De-Initialization
  ## --------------------------------------------------------------------------------------
  unloadTexture(button)
  ##  Unload button texture
  unloadSound(fxButton)
  ##  Unload sound
  closeAudioDevice()
  ##  Close audio device
  closeWindow()
  ##  Close window and OpenGL context
  ## --------------------------------------------------------------------------------------


block textures_sprite_explosion:
  # ******************************************************************************************
  #
  #    raylib [textures] example - sprite explosion
  #
  #    This example has been created using raylib 2.5 (www.raylib.com)
  #    raylib is licensed under an unmodified zlib/libpng license (View raylib.h for details)
  #
  #    Copyright (c) 2019 Anata and Ramon Santamaria (@raysan5)
  #    Converted in 2021 by greenfork
  #
  # ******************************************************************************************


  const
    NUM_FRAMES_PER_LINE = 5
    NUM_LINES = 5

  ##  Initialization
  ## --------------------------------------------------------------------------------------
  var screenWidth = 800
  var screenHeight = 450
  initWindow(screenWidth, screenHeight,
             "raylib [textures] example - sprite explosion")
  initAudioDevice()
  ##  Load explosion sound
  var fxBoom: Sound = loadSound("resources/boom.wav")
  ##  Load explosion texture
  var explosion: Texture2D = loadTexture("resources/explosion.png")
  ##  Init variables for animation
  var frameWidth = explosion.width div NUM_FRAMES_PER_LINE
  ##  Sprite one frame rectangle width
  var frameHeight = explosion.height div NUM_LINES
  ##  Sprite one frame rectangle height
  var currentFrame = 0
  var currentLine = 0
  var frameRec: Rectangle = (0.0, 0.0, frameWidth.float, frameHeight.float)
  var position: Vector2
  var active: bool = false
  var framesCounter = 0
  setTargetFPS(120)
  ## --------------------------------------------------------------------------------------
  ##  Main game loop
  while not windowShouldClose(): ##  Detect window close button or ESC key
    ##  Update
    ## ----------------------------------------------------------------------------------
    ##  Check for mouse button pressed and activate explosion (if not active)
    if isMouseButtonPressed(Left_Button) and not active:
      position = getMousePosition()
      active = true
      position.x -= (float)frameWidth div 2
      position.y -= (float)frameHeight div 2
      playSound(fxBoom)
    if active:
      inc(framesCounter)
      if framesCounter > 2:
        inc(currentFrame)
        if currentFrame >= NUM_FRAMES_PER_LINE:
          currentFrame = 0
          inc(currentLine)
          if currentLine >= NUM_LINES:
            currentLine = 0
            active = false
        framesCounter = 0
    frameRec.x = (float) frameWidth * currentFrame
    frameRec.y = (float) frameHeight * currentLine
    ## ----------------------------------------------------------------------------------
    ##  Draw
    ## ----------------------------------------------------------------------------------
    beginDrawing()
    clearBackground(Raywhite)
    ##  Draw explosion requiRed frame rectangle
    if active:
      drawTextureRec(explosion, frameRec, position, White)
    endDrawing()
  ## ----------------------------------------------------------------------------------
  ##  De-Initialization
  ## --------------------------------------------------------------------------------------
  unloadTexture(explosion)
  ##  Unload texture
  unloadSound(fxBoom)
  ##  Unload sound
  closeAudioDevice()
  closeWindow()
  ##  Close window and OpenGL context
  ## --------------------------------------------------------------------------------------


block textures_srcrec_dstrec:
  # ******************************************************************************************
  #
  #    raylib [textures] example - Texture source and destination rectangles
  #
  #    This example has been created using raylib 1.3 (www.raylib.com)
  #    raylib is licensed under an unmodified zlib/libpng license (View raylib.h for details)
  #
  #    Copyright (c) 2015 Ramon Santamaria (@raysan5)
  #    Converted in 2021 by greenfork
  #
  # ******************************************************************************************


  ##  Initialization
  ## --------------------------------------------------------------------------------------
  var screenWidth = 800
  var screenHeight = 450
  initWindow(screenWidth, screenHeight, "raylib [textures] examples - texture source and destination rectangles")
  ##  NOTE: Textures MUST be loaded after Window initialization (OpenGL context is requiRed)
  var scarfy: Texture2D = loadTexture("resources/scarfy.png")
  ##  Texture loading
  var frameWidth = scarfy.width div 6
  var frameHeight = scarfy.height
  ##  Source rectangle (part of the texture to use for drawing)
  var sourceRec: Rectangle = (0.0, 0.0, frameWidth.float, frameHeight.float)
  ##  Destination rectangle (screen rectangle where drawing part of texture)
  var destRec: Rectangle = ((float)screenWidth div 2, (float)screenHeight div 2, (float)frameWidth * 2,
                        (float)frameHeight * 2)
  ##  Origin of the texture (rotation/scale point), it's relative to destination rectangle size
  var origin: Vector2 = (frameWidth.float, frameHeight.float)
  var rotation = 0
  setTargetFPS(60)
  ## --------------------------------------------------------------------------------------
  ##  Main game loop
  while not windowShouldClose(): ##  Detect window close button or ESC key
    ##  Update
    ## ----------------------------------------------------------------------------------
    inc(rotation)
    ## ----------------------------------------------------------------------------------
    ##  Draw
    ## ----------------------------------------------------------------------------------
    beginDrawing()
    clearBackground(Raywhite)
    ##  NOTE: Using DrawTexturePro() we can easily rotate and scale the part of the texture we draw
    ##  sourceRec defines the part of the texture we use for drawing
    ##  destRec defines the rectangle where our texture part will fit (scaling it to fit)
    ##  origin defines the point of the texture used as reference for rotation and scaling
    ##  rotation defines the texture rotation (using origin as rotation point)
    drawTexturePro(scarfy, sourceRec, destRec, origin, rotation.float, White)
    drawLine(destRec.x.int, 0, destRec.x.int, screenHeight, Gray)
    drawLine(0, destRec.y.int, screenWidth, destRec.y.int, Gray)
    drawText("(c) Scarfy sprite by Eiden Marsal", screenWidth - 200,
             screenHeight - 20, 10, Gray)
    endDrawing()
  ## ----------------------------------------------------------------------------------
  ##  De-Initialization
  ## --------------------------------------------------------------------------------------
  unloadTexture(scarfy)
  ##  Texture unloading
  closeWindow()
  ##  Close window and OpenGL context
  ## --------------------------------------------------------------------------------------


block textures_to_image:
  # ******************************************************************************************
  #
  #    raylib [textures] example - Retrieve image data from texture: GetTextureData()
  #
  #    NOTE: Images are loaded in CPU memory (RAM); textures are loaded in GPU memory (VRAM)
  #
  #    This example has been created using raylib 1.3 (www.raylib.com)
  #    raylib is licensed under an unmodified zlib/libpng license (View raylib.h for details)
  #
  #    Copyright (c) 2015 Ramon Santamaria (@raysan5)
  #    Converted in 2021 by greenfork
  #
  # ******************************************************************************************


  ##  Initialization
  ## --------------------------------------------------------------------------------------
  var screenWidth = 800
  var screenHeight = 450
  initWindow(screenWidth, screenHeight,
             "raylib [textures] example - texture to image")
  ##  NOTE: Textures MUST be loaded after Window initialization (OpenGL context is requiRed)
  var image: Image = loadImage("resources/raylib_logo.png")
  ##  Load image data into CPU memory (RAM)
  var texture: Texture2D = loadTextureFromImage(image)
  ##  Image converted to texture, GPU memory (RAM -> VRAM)
  unloadImage(image)
  ##  Unload image data from CPU memory (RAM)
  image = getTextureData(texture)
  ##  Retrieve image data from GPU memory (VRAM -> RAM)
  unloadTexture(texture)
  ##  Unload texture from GPU memory (VRAM)
  texture = loadTextureFromImage(image)
  ##  Recreate texture from retrieved image data (RAM -> VRAM)
  unloadImage(image)
  ##  Unload retrieved image data from CPU memory (RAM)
  ## ---------------------------------------------------------------------------------------
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
    drawTexture(texture, screenWidth div 2 - texture.width div 2,
                screenHeight div 2 - texture.height div 2, White)
    drawText("this IS a texture loaded from an image!", 300, 370, 10, Gray)
    endDrawing()
  ## ----------------------------------------------------------------------------------
  ##  De-Initialization
  ## --------------------------------------------------------------------------------------
  unloadTexture(texture)
  ##  Texture unloading
  closeWindow()
  ##  Close window and OpenGL context
  ## --------------------------------------------------------------------------------------


