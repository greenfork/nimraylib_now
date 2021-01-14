## ******************************************************************************************
##
##    Physac - Physics restitution
##
##    Copyright (c) 2016-2018 Victor Fisac
##
## ******************************************************************************************

import ../../src/nimraylib_now/[raylib, physac]

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
