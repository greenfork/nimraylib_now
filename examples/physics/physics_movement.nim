## ******************************************************************************************
##
##    Physac - Physics movement
##
##    Copyright (c) 2016-2018 Victor Fisac
##
## ******************************************************************************************

import nimraylib_now

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
