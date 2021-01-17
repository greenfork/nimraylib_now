discard """
  action: "compile"
  joinable: false
  matrix: "; --gc:orc; -d:release; --gc:orc -d:release; -d:release -d:danger; --gc:orc -d:release -d:danger"
"""
import lenientops, math, times, strformat, atomics, system/ansi_c
import ../../src/nimraylib_now/[raylib, raygui, raymath, physac]
from ../../src/nimraylib_now/rlgl as rl import nil

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
      circles[i].alpha = 0.0f;
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
          circles[i].alpha += circles[i].speed;
          circles[i].radius += circles[i].speed*10.0f;

          if circles[i].alpha > 1.0f: circles[i].speed *= -1

          if (circles[i].alpha <= 0.0f):
              circles[i].alpha = 0.0f;
              circles[i].radius = getRandomValue(10, 40).float
              circles[i].position.x = getRandomValue(circles[i].radius.int32, screenWidth - circles[i].radius.int32).float
              circles[i].position.y = getRandomValue(circles[i].radius.int32, screenHeight - circles[i].radius.int32).float
              circles[i].color = colors[getRandomValue(0, 13)];
              circles[i].speed = (float)getRandomValue(1, 100)/2000.0f;
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

  proc updatePlayer(player: var Player; envItems: var openArray[EnvItem];  delta: float)
  proc updateCameraCenter(camera: var Camera2D; player: var Player;
                          envItems: var openArray[EnvItem]; delta: float;
                          width: int; height: int)
  proc updateCameraCenterInsideMap(camera: var Camera2D; player: var Player;
                                   envItems: var openArray[EnvItem];
                                   delta: float; width: int; height: int)
  proc updateCameraCenterSmoothFollow(camera: var Camera2D; player: var Player;
                                      envItems: var openArray[EnvItem];
                                      delta: float; width: int; height: int)
  proc updateCameraEvenOutOnLanding(camera: var Camera2D; player: var Player;
                                    envItems: var openArray[EnvItem];
                                    delta: float; width: int; height: int)
  proc updateCameraPlayerBoundsPush(camera: var Camera2D; player: var Player;
                                    envItems: var openArray[EnvItem];
                                    delta: float; width: int; height: int)
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
      player.position = (x: 400.0, y: 280.0);
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

  proc updatePlayer(player: var Player; envItems: var openArray[EnvItem]; delta: float) =
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

  proc updateCameraCenter(camera: var Camera2D; player: var Player;
                          envItems: var openArray[EnvItem]; delta: float;
                          width: int; height: int) =
    camera.offset = (x: width/2, y: height/2);
    camera.target = player.position

  proc updateCameraCenterInsideMap(camera: var Camera2D; player: var Player;
                                   envItems: var openArray[EnvItem];
                                   delta: float; width: int; height: int) =
    camera.target = player.position
    camera.offset = (x: width/2, y: height/2);
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

  proc updateCameraCenterSmoothFollow(camera: var Camera2D; player: var Player;
                                      envItems: var openArray[EnvItem];
                                      delta: float; width: int; height: int) =
    var minSpeed = 30.0
    var minEffectLength = 10.0
    var fractionSpeed = 0.8
    camera.offset = (x: width/2, y: height/2);
    var diff: Vector2 = vector2Subtract(player.position, camera.target)
    var length = vector2Length(diff)
    if length > minEffectLength:
      var speed = max(fractionSpeed * length, minSpeed)
      camera.target = vector2Add(camera.target,
                               vector2Scale(diff, speed * delta / length))

  var eveningOut = false
  var evenOutTarget: float
  proc updateCameraEvenOutOnLanding(camera: var Camera2D; player: var Player;
                                    envItems: var openArray[EnvItem];
                                    delta: float; width: int; height: int) =
    var evenOutSpeed = 700.0
    camera.offset = (x: width/2, y: height/2);
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

  proc updateCameraPlayerBoundsPush(camera: var Camera2D; player: var Player;
                                    envItems: var openArray[EnvItem];
                                    delta: float; width: int; height: int) =
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
    camera.offset = (x: (1 - bbox.x)*0.5f * width, y: (1 - bbox.y)*0.5f*height);
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
  camera.`type` = Perspective

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
  camera.`type` = Perspective
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
  camera.`type` = Perspective
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
  camera.`type` = Perspective                    #  Camera mode type

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
        let ray = getMouseRay(getMousePosition(), camera);

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
  var currentGesture = GestureType.None
  var lastGesture = GestureType.None
  ## SetGesturesEnabled(0b0000000000001001);   // Enable only some gestures to be detected
  setTargetFPS(60)
  ##  Set our game to run at 60 frames-per-second
  ## --------------------------------------------------------------------------------------
  ##  Main game loop
  while not windowShouldClose(): ##  Detect window close button or ESC key
    ##  Update
    ## ----------------------------------------------------------------------------------
    lastGesture = currentGesture
    currentGesture = getGestureDetected().GestureType
    touchPosition = getTouchPosition(0)
    if checkCollisionPointRec(touchPosition, touchArea) and
        (currentGesture != GestureType.None):
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
    if currentGesture != GestureType.None:
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
  camera.`type` = Perspective
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
    q1 = quaternionFromEuler(v1.x, v1.y, v1.z)
    m1 = matrixRotateZYX(v1)
    m2 = quaternionToMatrix(q1)
    q1 = quaternionFromMatrix(m1)
    m3 = quaternionToMatrix(q1)
    v2 = quaternionToEuler(q1)
    v2.x = degToRad v2.x
    v2.y = degToRad v2.y
    v2.z = degToRad v2.z
    m4 = matrixRotateZYX(v2)
    ## --------------------------------------------------------------------------------------
    ##  Draw
    ## ----------------------------------------------------------------------------------
    beginDrawing:
      clearBackground(Raywhite)

      beginMode3D(camera):
        model.transform = m1
        drawModel(model, (-1.0, 0.0, 0.0), 1.0, Red);
        model.transform = m2
        drawModel(model, (1.0, 0.0, 0.0), 1.0, Red);
        model.transform = m3
        drawModel(model, (0.0, 0.0, 0.0), 1.0, Red);
        model.transform = m4
        drawModel(model, (0.0, 0.0, -1.0), 1.0, Red);
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
  ##  NOTE: screenWidth/screenHeight should match VR device aspect ratio
  setConfigFlags(Msaa4xHint)
  initWindow(screenWidth, screenHeight, "raylib [core] example - vr simulator")
  ##  Init VR simulator (Oculus Rift CV1 parameters)
  initVrSimulator()
  var hmd = VrDeviceInfo()

  ##  VR device parameters (head-mounted-device)
  ##  Oculus Rift CV1 parameters for simulator
  hmd.hResolution = 2160            ##  HMD horizontal resolution in pixels
  hmd.vResolution = 1200            ##  HMD vertical resolution in pixels
  hmd.hScreenSize = 0.133793        ##  HMD horizontal size in meters
  hmd.vScreenSize = 0.0669          ##  HMD vertical size in meters
  hmd.vScreenCenter = 0.04678       ##  HMD screen center in meters
  hmd.eyeToScreenDistance = 0.041   ##  HMD distance between eye and display in meters
  hmd.lensSeparationDistance = 0.07 ##  HMD lens separation distance in meters
  hmd.interpupillaryDistance = 0.07 ##  HMD IPD (distance between pupils) in meters

  ## NOTE: CV1 uses a Fresnel-hybrid-asymmetric lenses with specific distortion compute shaders.
  ## Following parameters are an approximation to distortion stereo rendering
  ## but results differ from actual device.
  hmd.lensDistortionValues[0] = 1.0  ##  HMD lens distortion constant parameter 0
  hmd.lensDistortionValues[1] = 0.22 ##  HMD lens distortion constant parameter 1
  hmd.lensDistortionValues[2] = 0.24 ##  HMD lens distortion constant parameter 2
  hmd.lensDistortionValues[3] = 0.0  ##  HMD lens distortion constant parameter 3
  hmd.chromaAbCorrection[0] = 0.996  ##  HMD chromatic aberration correction parameter 0
  hmd.chromaAbCorrection[1] = -0.004 ##  HMD chromatic aberration correction parameter 1
  hmd.chromaAbCorrection[2] = 1.014  ##  HMD chromatic aberration correction parameter 2
  hmd.chromaAbCorrection[3] = 0.0    ##  HMD chromatic aberration correction parameter 3

  ##  Distortion shader (uses device lens distortion and chroma)
  var distortion: Shader = loadShader("", textFormat("resources/distortion%i.fs", GlslVersion))
  setVrConfiguration(hmd, distortion)
  ##  Set Vr device parameters for stereo rendering
  ##  Define the camera to look into our 3d world
  var camera = Camera()
  camera.position = (5.0, 2.0, 5.0)    # Camera position
  camera.target = (0.0, 2.0, 0.0)      # Camera looking at point
  camera.up = (0.0, 1.0, 0.0)          # Camera up vector (rotation towards target)
  camera.fovy = 60.0
  ##  Camera field-of-view Y
  camera.`type` = Perspective
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
    if isKeyPressed(Space):
      toggleVrMode()
    beginDrawing()
    clearBackground(Raywhite)
    beginVrDrawing()
    beginMode3D(camera)
    drawCube(cubePosition, 2.0, 2.0, 2.0, Red)
    drawCubeWires(cubePosition, 2.0, 2.0, 2.0, Maroon)
    drawGrid(40, 1.0)
    endMode3D()
    endVrDrawing()
    drawFPS(10, 10)
    endDrawing()
  ## ----------------------------------------------------------------------------------
  ##  De-Initialization
  ## --------------------------------------------------------------------------------------
  unloadShader(distortion)
  ##  Unload distortion shader
  closeVrSimulator()
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
  ## SetTargetFPS(60);               // Set our game to run at 60 frames-per-second
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
    drawRectangleLinesEx((0.0, 0.0, getScreenWidth().float, getScreenHeight().float), 4, Raywhite);
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
  proc clampValue(value: Vector2; minV: Vector2; maxV: Vector2): Vector2 =
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
    color = Color(r: getRandomValue(100, 250).uint8, g: getRandomValue(100, 250).uint8,
                  b: getRandomValue(100, 250).uint8, a: 255'u8)
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
        color = Color(r: getRandomValue(100, 250).uint8, g: getRandomValue(100, 250).uint8,
                      b: getRandomValue(100, 250).uint8, a: 255'u8)
    var mouse: Vector2 = getMousePosition()
    var virtualMouse: Vector2
    virtualMouse.x = (mouse.x - (getScreenWidth() - (gameScreenWidth * scale)) * 0.5) / scale
    virtualMouse.y = (mouse.y - (getScreenHeight() - (gameScreenHeight * scale)) * 0.5) / scale
    virtualMouse = clampValue(virtualMouse, (0.0, 0.0), (gameScreenWidth.float, gameScreenHeight.float))
    ##  Apply the same transformation as the virtual mouse to the real mouse (i.e. to work with raygui)
    ## SetMouseOffset(-(GetScreenWidth() - (gameScreenWidth*scale))*0.5f, -(GetScreenHeight() - (gameScreenHeight*scale))*0.5f);
    ## SetMouseScale(1/scale, 1/scale);
    ##
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
    );
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
  camera.`type` = Perspective
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
    cubeScreenPosition = getWorldToScreen((cubePosition.x.float, cubePosition.y + 2.5, cubePosition.z.float), camera);
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
  camera.`type`   = PERSPECTIVE

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
  camera.`type`    = Perspective

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
  camera.`type`   = PERSPECTIVE

  #  Specify the amount of blocks in each direction
  const numBlocks = 15

  60.setTargetFPS
  # --------------------------------------------------------------------------------------

  #  Main game loop
  while not windowShouldClose():    #  Detect window close button or ESC key

      #  Update
      # ----------------------------------------------------------------------------------
      let
          time = raylib.getTime()

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
                    cubeSize = (2.4 - scale)*blockScale;

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
    type: Perspective            # Defines projection type, see CameraType
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
    runPhysicsStep()
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
    runPhysicsStep()
    if isKeyPressed(R):
      ##  Reset dynamic physics bodies position, velocity and rotation
      ##             bodyA->position = (Vector2){ 35, screenHeight*0.6f };
      ##             bodyA->velocity = (Vector2){ 0, 0 };
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
  ##     PhysicsBody body = CreatePhysicsBodyRectangle((Vector2){ screenWidth/2, screenHeight/2 }, 50, 50, 1);
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
    runPhysicsStep()
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
    runPhysicsStep()
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
    runPhysicsStep()
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


block models_raymarching:
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

  #  Get shader locations for required uniforms
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
  const VALUES_PER_COLOR   = 3

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

  #  Load shader to be used on some parts drawing
  #  NOTE 1: Using GLSL 330 shader version, on OpenGL ES 2.0 use GLSL 100 shader version
  #  NOTE 2: Defining 0 (NULL) for vertex shader forces usage of internal default vertex shader
  let
      shader = loadShader(nil, textFormat("resources/shaders/glsl%i/palette_switch.fs", GLSL_VERSION))
  #  Get variable (uniform) location on the shader to connect with the program
  #  NOTE: If uniform variable could not be found in the shader, function returns -1
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
      setShaderValueV shader, paletteLoc, palettes[currentPalette].addr, IVEC3, COLORS_PER_PALETTE
      # ----------------------------------------------------------------------------------

      #  Draw
      # ----------------------------------------------------------------------------------
      beginDrawing()

      clearBackground RAYWHITE

      beginShaderMode shader

      for i in 0..<COLORS_PER_PALETTE:
          #  Draw horizontal screen-wide rectangles with increasing "palette index"
          #  The used palette index is encoded in the RGB components of the pixel
          drawRectangle 0.int32, (int32)lineHeight*i, getScreenWidth(), lineHeight.int32, (r: i, g: i, b: i, a: 255)

      endShaderMode()

      drawText "< >", 10, 10, 30, DARKBLUE
      drawText "CURRENT PALETTE:", 60, 15, 20, RAYWHITE
      drawText paletteText[currentPalette], 300, 15, 20, RED

      drawFPS 700, 15

      endDrawing()
      # ----------------------------------------------------------------------------------

  #  De-Initialization
  # --------------------------------------------------------------------------------------
  unloadShader shader        #  Unload shader

  closeWindow()              #  Close window and OpenGL context
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
        drawRing(center, innerRadius, outerRadius, startAngle.int32, endAngle.int32, segments, fade(MAROON, 0.3))
      if doDrawRingLines:
        drawRingLines(center, innerRadius, outerRadius, startAngle.int32, endAngle.int32, segments, fade(BLACK, 0.4))
      if doDrawCircleLines:
        drawCircleSectorLines(center, outerRadius, startAngle.int32, endAngle.int32, segments, fade(BLACK, 0.4))

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
          dx = irisLeftPosition.x - scleraLeftPosition.x;
          dy = irisLeftPosition.y - scleraLeftPosition.y;

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

  #  Check if any key is pressed
  #  NOTE: We limit keys check to keys between 32 (KEY_SPACE) and 126
  proc isAnyKeyPressed(): bool =
      var
          keyPressed = false
          key = getKeyPressed()

      if key >= 32 and key <= 126: keyPressed = true

      return keyPressed


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

  initWindow screenWidth, screenHeight, "raylib [textures] example - texture from raw data"

  #  NOTE: Textures MUST be loaded after Window initialization (OpenGL context is required)

  #  Load RAW image data (512x512, 32bit RGBA, no file header)
  let
      fudesumiRaw = loadImageRaw("resources/fudesumi.raw", 384, 512, UNCOMPRESSED_R8G8B8A8, 0)
      fudesumi = loadTextureFromImage(fudesumiRaw)  #  Upload CPU (RAM) image to GPU (VRAM)
  unloadImage fudesumiRaw                           #  Unload CPU (RAM) image data

  #  Generate a checked texture by code
  let
      width: int32 = 960
      height: int32 = 480

  #  Dynamic memory allocation to store pixels data (Color type)
  var pixels = newSeq[Color](width*height)

  for y in 0..<height:
      for x in 0..<width:
          pixels[y*width + x] = (if (((x div 32+y div 32) div 1) %% 2 == 0): ORANGE else: GOLD)

  #  Load pixels data into an image structure and create texture
  let
      checkedIm = Image(data:cast[ptr Color](pixels), width: width, height: height, format: UNCOMPRESSED_R8G8B8A8, mipmaps: 1)
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

      drawTexture checked, screenWidth div 2 - checked.width div 2, screenHeight div 2 - checked.height div 2, 
          fade(WHITE, 0.5f)
      drawTexture fudesumi, 430, -30, WHITE

      drawText "CHECKED TEXTURE ", 84, 85, 30, BROWN
      drawText "GENERATED by CODE", 72, 148, 30, BROWN
      drawText "and RAW IMAGE LOADING", 46, 210, 30, BROWN

      drawText "(c) Fudesumi sprite by Eiden Marsal", 310, screenHeight - 20, 10, BROWN

      endDrawing()
      # ----------------------------------------------------------------------------------

  #  De-Initialization
  # --------------------------------------------------------------------------------------
  unloadTexture fudesumi     #  Texture unloading
  unloadTexture checked      #  Texture unloading

  closeWindow()              #  Close window and OpenGL context
  # --------------------------------------------------------------------------------------


