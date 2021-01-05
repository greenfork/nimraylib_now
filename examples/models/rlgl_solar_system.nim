#******************************************************************************************
#
#   raylib [models] example - rlgl module usage with push/pop matrix transformations
#
#   This example uses [rlgl] module funtionality (pseudo-OpenGL 1.1 style coding)
#
#   This example has been created using raylib 2.5 (www.raylib.com)
#   raylib is licensed under an unmodified zlib/libpng license (View raylib.h for details)
#
#   Copyright (c) 2018 Ramon Santamaria (@raysan5)
#   /Converted in 2*20 by Guevara-chan.
#
#*******************************************************************************************

import raylib, rlgl, math, lenientops

# ------------------------------------------------------------------------------------
#  Module Functions Declaration
# ------------------------------------------------------------------------------------
proc DrawSphereBasic(color: Color) #  Draw sphere without any matrix transformation

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

InitWindow screenWidth, screenHeight, "raylib [models] example - rlgl module usage with push/pop matrix transformations"

#  Define the camera to look into our 3d world
var camera      = Camera()
camera.position = Vector3(x: 16.0f, y: 16.0f, z: 16.0f)
camera.target   = Vector3(x: 0.0f, y: 0.0f, z: 0.0f)
camera.up       = Vector3(x: 0.0f, y: 1.0f, z: 0.0f)
camera.fovy     = 45.0f
camera.typex    = CAMERA_PERSPECTIVE

camera.SetCameraMode CAMERA_FREE

var 
    rotationSpeed = 0.2f          #  General system rotation speed

    earthRotation      = 0.0f     #  Rotation of earth around itself (days) in degrees
    earthOrbitRotation = 0.0f     #  Rotation of earth around the Sun (years) in degrees
    moonRotation       = 0.0f     #  Rotation of moon around itself
    moonOrbitRotation  = 0.0f     #  Rotation of moon around earth in degrees

60.SetTargetFPS                   #  Set our game to run at 60 frames-per-second
# --------------------------------------------------------------------------------------

#  Main game loop
while not WindowShouldClose():    #  Detect window close button or ESC key
    #  Update
    # ----------------------------------------------------------------------------------
    camera.addr.UpdateCamera

    earthRotation += (5.0f*rotationSpeed)
    earthOrbitRotation += (365/360.0f*(5.0f*rotationSpeed)*rotationSpeed)
    moonRotation += (2.0f*rotationSpeed)
    moonOrbitRotation += (8.0f*rotationSpeed)
    # ----------------------------------------------------------------------------------

    #  Draw
    # ----------------------------------------------------------------------------------
    BeginDrawing()

    ClearBackground RAYWHITE

    BeginMode3D camera

    rlPushMatrix()
    rlScalef sunRadius, sunRadius, sunRadius           #  Scale Sun
    GOLD.DrawSphereBasic                               #  Draw the Sun
    rlPopMatrix()

    rlPushMatrix()
    rlRotatef earthOrbitRotation, 0.0f, 1.0f, 0.0f     #  Rotation for Earth orbit around Sun
    rlTranslatef earthOrbitRadius, 0.0f, 0.0f          #  Translation for Earth orbit
    rlRotatef -earthOrbitRotation, 0.0f, 1.0f, 0.0f    #  Rotation for Earth orbit around Sun inverted

    rlPushMatrix()
    rlRotatef earthRotation, 0.25, 1.0, 0.0            #  Rotation for Earth itself
    rlScalef earthRadius, earthRadius, earthRadius     #  Scale Earth
    BLUE.DrawSphereBasic                               #  Draw the Earth
    rlPopMatrix()

    rlRotatef moonOrbitRotation, 0.0f, 1.0f, 0.0f      #  Rotation for Moon orbit around Earth
    rlTranslatef moonOrbitRadius, 0.0f, 0.0f           #  Translation for Moon orbit
    rlRotatef -moonOrbitRotation, 0.0f, 1.0f, 0.0f     #  Rotation for Moon orbit around Earth inverted
    rlRotatef moonRotation, 0.0f, 1.0f, 0.0f           #  Rotation for Moon itself
    rlScalef moonRadius, moonRadius, moonRadius        #  Scale Moon

    LIGHTGRAY.DrawSphereBasic                          #  Draw the Moon
    rlPopMatrix()

    #  Some reference elements (not affected by previous matrix transformations)
    DrawCircle3D Vector3(x: 0.0, y: 0.0, z: 0.0), earthOrbitRadius, Vector3(x: 1, y: 0, z: 0), 90.0f, Fade(RED, 0.5)
    DrawGrid 20, 1.0f

    EndMode3D()

    DrawText "EARTH ORBITING AROUND THE SUN!", 400, 10, 20, MAROON 
    DrawFPS 10, 10 

    EndDrawing()
    # ----------------------------------------------------------------------------------

#  De-Initialization
# --------------------------------------------------------------------------------------
CloseWindow()        #  Close window and OpenGL context
# --------------------------------------------------------------------------------------

# --------------------------------------------------------------------------------------------
#  Module Functions Definitions (local)
# --------------------------------------------------------------------------------------------

#  Draw sphere without any matrix transformation
#  NOTE: Sphere is drawn in world position ( 0, 0, 0 ) with radius 1.0f
proc DrawSphereBasic(color: Color) =
    const
        rings = 16
        slices = 16

    rlBegin RL_TRIANGLES
    rlColor4ub color.r, color.g, color.b, color.a

    for i in 0..<rings+2:
        for j in 0..<slices:
            rlVertex3f(cos(DEG2RAD*(270+(180/(rings + 1))*i))*sin(DEG2RAD*(j*360/slices)),
                       sin(DEG2RAD*(270+(180/(rings + 1))*i)),
                       cos(DEG2RAD*(270+(180/(rings + 1))*i))*cos(DEG2RAD*(j*360/slices)))
            rlVertex3f(cos(DEG2RAD*(270+(180/(rings + 1))*(i+1)))*sin(DEG2RAD*((j+1)*360/slices)),
                       sin(DEG2RAD*(270+(180/(rings + 1))*(i+1))),
                       cos(DEG2RAD*(270+(180/(rings + 1))*(i+1)))*cos(DEG2RAD*((j+1)*360/slices)))
            rlVertex3f(cos(DEG2RAD*(270+(180/(rings + 1))*(i+1)))*sin(DEG2RAD*(j*360/slices)),
                       sin(DEG2RAD*(270+(180/(rings + 1))*(i+1))),
                       cos(DEG2RAD*(270+(180/(rings + 1))*(i+1)))*cos(DEG2RAD*(j*360/slices)))

            rlVertex3f(cos(DEG2RAD*(270+(180/(rings + 1))*i))*sin(DEG2RAD*(j*360/slices)),
                       sin(DEG2RAD*(270+(180/(rings + 1))*i)),
                       cos(DEG2RAD*(270+(180/(rings + 1))*i))*cos(DEG2RAD*(j*360/slices)))
            rlVertex3f(cos(DEG2RAD*(270+(180/(rings + 1))*(i)))*sin(DEG2RAD*((j+1)*360/slices)),
                       sin(DEG2RAD*(270+(180/(rings + 1))*(i))),
                       cos(DEG2RAD*(270+(180/(rings + 1))*(i)))*cos(DEG2RAD*((j+1)*360/slices)))
            rlVertex3f(cos(DEG2RAD*(270+(180/(rings + 1))*(i+1)))*sin(DEG2RAD*((j+1)*360/slices)),
                       sin(DEG2RAD*(270+(180/(rings + 1))*(i+1))),
                       cos(DEG2RAD*(270+(180/(rings + 1))*(i+1)))*cos(DEG2RAD*((j+1)*360/slices)))
    rlEnd()