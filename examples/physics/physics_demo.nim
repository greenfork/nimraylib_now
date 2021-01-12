## ******************************************************************************************
##
##    Physac - Physics demo
##
##    NOTE 1: Physac requires multi-threading, when InitPhysics() a second thread is created to manage physics calculations.
##    NOTE 2: Physac requires static C library linkage to avoid dependency on MinGW DLL (-static -lpthread)
##
##    Use the following line to compile:
##
##    gcc -o $(NAME_PART).exe $(FILE_NAME) -s -static  /
##        -lraylib -lpthread -lglfw3 -lopengl32 -lgdi32 -lopenal32 -lwinmm /
##        -std=c99 -Wl,--subsystem,windows -Wl,-allow-multiple-definition
##
##    Copyright (c) 2016-2018 Victor Fisac
##
## ******************************************************************************************

import ../../src/nimraylib_now/[raylib, physac]

# const
#   PHYSAC_IMPLEMENTATION* = true
#   PHYSAC_NO_THREADS* = true

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
var floor = createPhysicsBodyCircle((screenWidth.float/2.0, screenHeight.float/2.0), 45.0, 10.0)
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
    floor = createPhysicsBodyCircle((screenWidth.float/2.0, screenHeight.float/2.0), 45.0, 10.0)
    circle.enabled = false
    needsReset = false
  if isKeyPressed(R):
    resetPhysics()
    needsReset = true
  if isMouseButtonPressed(LeftButton):
    createPhysicsBodyPolygon(getMousePosition(), getRandomValue(20, 80).float,
                             getRandomValue(3, 8).float, 10.0)
  elif isMouseButtonPressed(RightButton): ##  Destroy falling physics bodies
    createPhysicsBodyCircle(getMousePosition(), getRandomValue(10, 45).float, 10.0)
  var bodiesCount = getPhysicsBodiesCount()
  var i = bodiesCount - 1
  while i >= 0:
    var body: PhysicsBody = getPhysicsBody(i)
    if body != nil and (body.position.y > screenHeight * 2):
      destroyPhysicsBody(body)
    dec(i)
  ## ----------------------------------------------------------------------------------
  ##  Draw
  ## ----------------------------------------------------------------------------------
  beginDrawing()
  clearBackground(Black)
  drawFPS(screenWidth - 90, screenHeight - 30)
  ##  Draw created physics bodies
  bodiesCount = getPhysicsBodiesCount()
  var i = 0
  while i < bodiesCount:
    var body: PhysicsBody = getPhysicsBody(i)
    if body != nil:
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
