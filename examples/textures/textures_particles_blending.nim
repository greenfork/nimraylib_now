#*******************************************************************************************
#
#   raylib example - particles blending
#
#   This example has been created using raylib 1.7 (www.raylib.com)
#   raylib is licensed under an unmodified zlib/libpng license (View raylib.h for details)
#
#   Copyright (c) 2017 Ramon Santamaria (@raysan5)
#   /Converted in 2*20 by Guevara-chan.
#   Adapted in 2021 by greenfork
#
#*******************************************************************************************

import lenientops
import nimraylib_now

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
    mouseTail[i].position = (x: 0.0, y: 0.0)
    mouseTail[i].color = Color(r: getRandomValue(0, 255).uint8, g: getRandomValue(0, 255).uint8,
        b: getRandomValue(0, 255).uint8, a: 255u8)
    mouseTail[i].alpha = 1.0
    mouseTail[i].size = getRandomValue(1, 30).float / 20.0
    mouseTail[i].rotation = getRandomValue(0, 360).float
    mouseTail[i].active = false

let
    gravity = 3.0
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
            mouseTail[i].alpha = 1.0
            mouseTail[i].position = getMousePosition()
            break

    for i in 0..<MAX_PARTICLES:
        if mouseTail[i].active:
            mouseTail[i].position.y += gravity
            mouseTail[i].alpha -= 0.01
            if mouseTail[i].alpha <= 0.0: mouseTail[i].active = false
            mouseTail[i].rotation += 5.0

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
            Rectangle(x: 0.0, y: 0.0, width: smoke.width.float, height: smoke.height.float),
            Rectangle(x: mouseTail[i].position.x, y: mouseTail[i].position.y, width: smoke.width*mouseTail[i].size.cfloat,
                height: smoke.height*mouseTail[i].size.cfloat),
            (x: smoke.width*mouseTail[i].size.cfloat/2.0, y: smoke.height*mouseTail[i].size.cfloat/2.0),
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
