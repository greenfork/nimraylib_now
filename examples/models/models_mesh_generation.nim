#[*******************************************************************************************
*
*   raylib example - procedural mesh generation
*
*   This example has been created using raylib 1.8 (www.raylib.com)
*   raylib is licensed under an unmodified zlib/libpng license (View raylib.h for details)
*
*   Copyright (c) 2017 Ramon Santamaria (Ray San)
*   Adapted for Nim by jseb
*
********************************************************************************************]#

import nimraylib_now

var camera = Camera3D()
var texture:Texture2D
var models:seq[Model]

func allocateMeshData(mesh:var Mesh, triangleCount:int) =
    mesh.vertexCount = triangleCount * 3
    mesh.triangleCount = triangleCount

    mesh.vertices = cast[ptr cfloat](memAlloc(mesh.vertexCount * 3 * sizeof(float)) )
    mesh.normals = cast[ptr cfloat](memAlloc(mesh.vertexCount * 3 * sizeof(float)) )
    mesh.texcoords = cast[ptr cfloat](memAlloc(mesh.vertexCount * 2 * sizeof(float)) )


proc makeMesh() :Mesh =
  allocateMeshData(result, 1)

  var vertices = [0.cfloat,0,0, 1,0,2, 2,0,0]
  var normals = [0.cfloat,1,0, 0,1,0, 0,1,0]
  var texcoords = [0.cfloat,0, 0.5,1, 1,0]
  result.vertices = cast[ptr cfloat](vertices.addr)
  result.normals = cast[ptr cfloat](normals.addr)
  result.texcoords = cast[ptr cfloat](texcoords.addr)

proc init() =
  const
    screenWidth = 800
    screenHeight = 450

  initWindow(screenWidth, screenHeight, "raylib [models] example - mesh generation")

  let meshes = [ genMeshPlane(2,2,5,5), genMeshCube(2.0f, 1.0f, 2.0f), genMeshSphere(2, 32, 32),
                 genMeshHemiSphere(2, 16, 16), genMeshCylinder(1, 2, 16), genMeshTorus(0.25f, 4.0f, 16, 32),
                 genMeshKnot(1.0f, 2.0f, 16, 128), genMeshPoly(5, 2.0f), makeMesh() ]

  # We generate a checked image for texturing
  var checked:Image = genImageChecked(2, 2, 1, 1, RED, GREEN)
  texture = loadTextureFromImage(checked)
  unloadImage(checked)

  for mesh in meshes:
    var m = loadModelFromMesh(mesh)
    #m.materials[0].maps[ALBEDO].texture = texture # MATERIAL_MAP_DIFFUSE is now ALBEDO
    m.materials[0].maps[0].texture = texture # MATERIAL_MAP_DIFFUSE is now ALBEDO
    models.add(m)

  camera.position = (5.0, 5.0, 5.0)
  camera.target = (0.0, 0.0, 0.0)
  camera.up = (0.0, 1.0, 0.0)
  camera.fovy = 45.0
  camera.projection = Perspective
  camera.setCameraMode(Orbital)
  setTargetFPS(60)


proc run() =
  var currentModel = 0
  var position = Vector3(x:0.0, y:0.0, z:0.0)

  while not windowShouldClose():
    updateCamera(camera.addr)
    if isMouseButtonPressed(LEFT_BUTTON) or isKeyPressed(RIGHT):
      currentModel = (currentModel + 1) mod models.len
    if isKeyPressed(LEFT):
      currentModel = currentModel - 1
      if currentModel < 0: currentModel = models.len - 1

    beginDrawing:
      clearBackground(WHITE)
      camera.beginMode3D:
        drawModel(models[currentModel], position, 1.0, WHITE)
        drawGrid(10, 1.0)

      drawRectangle(30, 400, 310, 30, fade(SKYBLUE, 0.5f))
      drawRectangleLines(30, 400, 310, 30, fade(DARKBLUE, 0.5f))
      drawText("MOUSE LEFT BUTTON to CYCLE PROCEDURAL MODELS", 40, 410, 10, BLUE)

      let listeModels = [ ("PLANE",680), ("CUBE",680), ("SPHERE",680), ("HEMISPHERE",640), ("CYLINDER",680),
                          ("TORUS",680), ("KNOT",680), ("POLY",680), ("Parametric(custom)",580) ]
      drawText(listeModels[currentModel][0], listeModels[currentModel][1], 10, 20, DARKBLUE)


proc exit() =
  unloadTexture(texture)

  for i,m in models.pairs:
    echo i,m
    unloadModel(m)

  closeWindow()


init()
run()
exit()
