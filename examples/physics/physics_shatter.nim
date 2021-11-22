## ******************************************************************************************
##
##    Physac - Body shatter
##
##    Copyright (c) 2016-2018 Victor Fisac
##
## ******************************************************************************************

import nimraylib_now

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
  if isMouseButtonPressed(MouseButton.Left):
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
