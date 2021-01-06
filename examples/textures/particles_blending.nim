#*******************************************************************************************
#
#   raylib example - particles blending
#
#   This example has been created using raylib 1.7 (www.raylib.com)
#   raylib is licensed under an unmodified zlib/libpng license (View raylib.h for details)
#
#   Copyright (c) 2017 Ramon Santamaria (@raysan5)
#   /Converted in 2*20 by Guevara-chan.
#
#*******************************************************************************************

import lenientops
import ../../src/nimraylib_now/raylib

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
    mouseTail[i].position = Vector2(x: 0, y: 0)
    mouseTail[i].color = Color(r: getRandomValue(0, 255).uint8, g: getRandomValue(0, 255).uint8,
        b: getRandomValue(0, 255).uint8, a: 255)
    mouseTail[i].alpha = 1.0f
    mouseTail[i].size = getRandomValue(1, 30).float / 20.0f
    mouseTail[i].rotation = getRandomValue(0, 360).float
    mouseTail[i].active = false

let
    gravity = 3.0f
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
            mouseTail[i].alpha = 1.0f
            mouseTail[i].position = getMousePosition()
            break

    for i in 0..<MAX_PARTICLES:
        if mouseTail[i].active:
            mouseTail[i].position.y += gravity
            mouseTail[i].alpha -= 0.01f
            if mouseTail[i].alpha <= 0.0f: mouseTail[i].active = false
            mouseTail[i].rotation += 5.0f

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
            Rectangle(x: 0.0f, y: 0.0f, width: smoke.width.float, height: smoke.height.float),
            Rectangle(x: mouseTail[i].position.x, y: mouseTail[i].position.y, width: smoke.width*mouseTail[i].size,
                height: smoke.height*mouseTail[i].size),
            Vector2(x: smoke.width*mouseTail[i].size.float/2.0f, y: smoke.height*mouseTail[i].size.float/2.0f),
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
