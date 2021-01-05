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
#
#*******************************************************************************************

import ../../raylib/raylib, ../../raylib/rlgl, math, lenientops

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

    sunRadius        = 4.0f
    earthRadius      = 0.6f
    earthOrbitRadius = 8.0f
    moonRadius       = 0.16f
    moonOrbitRadius  = 1.5f

initWindow screenWidth, screenHeight, "raylib [models] example - gl module usage with push/pop matrix transformations"

#  Define the camera to look into our 3d world
var camera      = Camera()
camera.position = Vector3(x: 16.0f, y: 16.0f, z: 16.0f)
camera.target   = Vector3(x: 0.0f, y: 0.0f, z: 0.0f)
camera.up       = Vector3(x: 0.0f, y: 1.0f, z: 0.0f)
camera.fovy     = 45.0f
camera.`type`    = CAMERA_PERSPECTIVE

camera.setCameraMode CAMERA_FREE

var
    rotationSpeed = 0.2f          #  General system rotation speed

    earthRotation      = 0.0f     #  Rotation of earth around itself (days) in degrees
    earthOrbitRotation = 0.0f     #  Rotation of earth around the Sun (years) in degrees
    moonRotation       = 0.0f     #  Rotation of moon around itself
    moonOrbitRotation  = 0.0f     #  Rotation of moon around earth in degrees

60.setTargetFPS                   #  Set our game to run at 60 frames-per-second
# --------------------------------------------------------------------------------------

#  Main game loop
while not windowShouldClose():    #  Detect window close button or ESC key
    #  Update
    # ----------------------------------------------------------------------------------
    camera.addr.updateCamera

    earthRotation += (5.0f*rotationSpeed)
    earthOrbitRotation += (365/360.0f*(5.0f*rotationSpeed)*rotationSpeed)
    moonRotation += (2.0f*rotationSpeed)
    moonOrbitRotation += (8.0f*rotationSpeed)
    # ----------------------------------------------------------------------------------

    #  Draw
    # ----------------------------------------------------------------------------------
    beginDrawing()

    clearBackground RAYWHITE

    beginMode3D camera

    pushMatrix()
    scalef sunRadius, sunRadius, sunRadius           #  Scale Sun
    Gold.drawSphereBasic                               #  Draw the Sun
    popMatrix()

    pushMatrix()
    rotatef earthOrbitRotation, 0.0f, 1.0f, 0.0f     #  Rotation for Earth orbit around Sun
    translatef earthOrbitRadius, 0.0f, 0.0f          #  Translation for Earth orbit
    rotatef -earthOrbitRotation, 0.0f, 1.0f, 0.0f    #  Rotation for Earth orbit around Sun inverted

    pushMatrix()
    rotatef earthRotation, 0.25, 1.0, 0.0            #  Rotation for Earth itself
    scalef earthRadius, earthRadius, earthRadius     #  Scale Earth
    Blue.drawSphereBasic                               #  Draw the Earth
    popMatrix()

    rotatef moonOrbitRotation, 0.0f, 1.0f, 0.0f      #  Rotation for Moon orbit around Earth
    translatef moonOrbitRadius, 0.0f, 0.0f           #  Translation for Moon orbit
    rotatef -moonOrbitRotation, 0.0f, 1.0f, 0.0f     #  Rotation for Moon orbit around Earth inverted
    rotatef moonRotation, 0.0f, 1.0f, 0.0f           #  Rotation for Moon itself
    scalef moonRadius, moonRadius, moonRadius        #  Scale Moon

    Lightgray.drawSphereBasic                          #  Draw the Moon
    popMatrix()

    #  Some reference elements (not affected by previous matrix transformations)
    drawCircle3D Vector3(x: 0.0, y: 0.0, z: 0.0), earthOrbitRadius, Vector3(x: 1, y: 0, z: 0), 90.0f, fade(RED, 0.5)
    drawGrid 20, 1.0f

    endMode3D()

    drawText "EARTH ORBITING AROUND THE SUN!", 400, 10, 20, MAROON
    drawFPS 10, 10

    endDrawing()
    # ----------------------------------------------------------------------------------

#  De-Initialization
# --------------------------------------------------------------------------------------
closeWindow()        #  Close window and OpenGL context
# --------------------------------------------------------------------------------------

# --------------------------------------------------------------------------------------------
#  Module Functions Definitions (local)
# --------------------------------------------------------------------------------------------

#  Draw sphere without any matrix transformation
#  NOTE: Sphere is drawn in world position ( 0, 0, 0 ) with radius 1.0f
proc drawSphereBasic(color: Color) =
    const
        rings = 16
        slices = 16

    begin Triangles
    color4ub color.r, color.g, color.b, color.a

    for i in 0..<rings+2:
        for j in 0..<slices:
            vertex3f(cos(degToRad(270+(180/(rings + 1))*i))*sin(degToRad(j*360/slices)),
                       sin(degToRad(270+(180/(rings + 1))*i)),
                       cos(degToRad(270+(180/(rings + 1))*i))*cos(degToRad(j*360/slices)))
            vertex3f(cos(degToRad(270+(180/(rings + 1))*(i+1)))*sin(degToRad((j+1)*360/slices)),
                       sin(degToRad(270+(180/(rings + 1))*(i+1))),
                       cos(degToRad(270+(180/(rings + 1))*(i+1)))*cos(degToRad((j+1)*360/slices)))
            vertex3f(cos(degToRad(270+(180/(rings + 1))*(i+1)))*sin(degToRad(j*360/slices)),
                       sin(degToRad(270+(180/(rings + 1))*(i+1))),
                       cos(degToRad(270+(180/(rings + 1))*(i+1)))*cos(degToRad(j*360/slices)))

            vertex3f(cos(degToRad(270+(180/(rings + 1))*i))*sin(degToRad(j*360/slices)),
                       sin(degToRad(270+(180/(rings + 1))*i)),
                       cos(degToRad(270+(180/(rings + 1))*i))*cos(degToRad(j*360/slices)))
            vertex3f(cos(degToRad(270+(180/(rings + 1))*(i)))*sin(degToRad((j+1)*360/slices)),
                       sin(degToRad(270+(180/(rings + 1))*(i))),
                       cos(degToRad(270+(180/(rings + 1))*(i)))*cos(degToRad((j+1)*360/slices)))
            vertex3f(cos(degToRad(270+(180/(rings + 1))*(i+1)))*sin(degToRad((j+1)*360/slices)),
                       sin(degToRad(270+(180/(rings + 1))*(i+1))),
                       cos(degToRad(270+(180/(rings + 1))*(i+1)))*cos(degToRad((j+1)*360/slices)))
    rlgl.end()
