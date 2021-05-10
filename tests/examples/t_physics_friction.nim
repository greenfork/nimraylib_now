discard """
  action: "compile"
  joinable: false
  matrix: "; -d:release; --gc:orc -d:release"
"""

## ******************************************************************************************
##
##    Physac - Physics friction
##
##    Copyright (c) 2016-2018 Victor Fisac
##
## ******************************************************************************************

import math
import ../../src/nimraylib_now

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
