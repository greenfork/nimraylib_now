discard """
  action: "compile"
  joinable: false
  matrix: "; -d:release; --gc:orc -d:release"
"""

## ******************************************************************************************
##
##    Physac - Physics demo
##
##    Copyright (c) 2016-2018 Victor Fisac
##
## ******************************************************************************************

import ../../src/nimraylib_now

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
  if isMouseButtonPressed(MouseButton.Left):
    discard createPhysicsBodyPolygon(getMousePosition(), getRandomValue(20, 80).float,
                                     getRandomValue(3, 8), 10.0)
  elif isMouseButtonPressed(MouseButton.Right): ##  Destroy falling physics bodies
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
