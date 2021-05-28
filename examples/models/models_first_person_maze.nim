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

import nimraylib_now

proc main() =
  const
    screenWidth = 1024
    screenHeight = 768

  initWindow(screenWidth, screenHeight, "raylib [models] example - first person maze")

  var camera = Camera3D(
    position: (0.2, 0.4, 0.2), target: (0.0, 0.0, 0.0), up: (0.0, 1.0, 0.0), fovy: 45.0, projection: Perspective
  )
  camera.setCameraMode(FIRST_PERSON)

  let imMap:Image = loadImage("resources/cubicmap.png") # load cubicmap image (RAM)
  let cubicMapTexture:Texture2D = loadTextureFromImage(imMap)  # convert image to texture (VRAM)
  let mesh = genMeshCubicmap(imMap, ( x:1.0, y:1.0, z:1.0))
  var model = loadModelFromMesh(mesh)

  # NOTE: By default each cube is mapped to one part of texture atlas
  let mapTexture = loadTexture("resources/cubicmap_atlas.png")
  model.materials[0].maps[int(Albedo)].texture = mapTexture

  # Get map image data to be used for collision detection
  let mapPixels = loadImageColors(imMap)
  unloadImage(imMap) # no need to keep imMap in RAM, once loaded

  var modelPosition = Vector3( x: -16.0, y:0.0, z: -8.0)


  setTargetFPS(60)

  while not windowShouldClose(): # detect window close button or ESC key
    var oldCamPos = camera.position
    camera.addr.updateCamera()

    # Check player collision (we simplify to 2D collision detection)
    let playerPos = (x: camera.position.x, y: camera.position.z)
    const playerRadius = 0.1  # Collision radius (player is modelled as a cilinder for collision)

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
        var collisionRect = Rectangle(x: modelPosition.x - 0.5 + x.float, y: modelPosition.z - 0.5 + y.float, width: 1.0, height: 1.0)
        # collision: white pixel, red channel
        if mapPixels[y*cubicMapTexture.width + x].r == 255 and checkCollisionCircleRec(playerPos, playerRadius, collisionRect) == true:
          camera.position = oldCamPos

    beginDrawing:
      clearBackground(Gray)
      camera.beginMode3D:
        drawModel(model, modelPosition, 1.0f, WHITE) # draw maze map
      drawTextureEx(cubicMapTexture, (x: getScreenWidth().float - cubicMapTexture.width.float*4.0 - 20.0, y: 20.0), 0.0, 4.0, White)
      drawRectangleLines(getScreenWidth() - cubicMapTexture.width*4 - 20, 20, cubicMapTexture.width*4, cubicMapTexture.height*4, Green)
      # Draw player position radar
      drawRectangle(getScreenWidth() - cubicMapTexture.width*4 - 20 + playerCellX*4, 20 + playerCellY*4, 4, 4, Yellow)
      drawFPS(10, 10)

  unloadImageColors(mapPixels) # Unload color array
  unloadTexture(cubicMapTexture) # Unload cubicmap texture
  unloadTexture(mapTexture) # Unload map texture
  unloadModel(model); # Unload map model

  closeWindow() # Close window and OpenGL context

main()
