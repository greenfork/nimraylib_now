import nimraylib_now

# Window, Title, FPS Setup
const screenWidth = 800
const screenHeight = 450
initWindow screenWidth, screenHeight, "Loading A 3D Model"
setTargetFPS(60)

# Camera Setup
var camera = Camera(
  position: (x: 50.0, y: 50.0, z: 50.0),
  target: (x: 0.0, y: 10.0, z: 0.0),
  up: (x: 0.0, y: 1.0, z: 0.0),
  fovy: 45
  )
camera.projection = Perspective
camera.setCameraMode Free

# Model Setup
var model = loadModel("resources/castle.obj") # load model
var texture: Texture2D = loadTexture("resources/castle_diffuse.png") # load model texture
model.materials[0].maps[MaterialMapIndex.Albedo.int].texture = texture # set map diffuse texture
  # NOTES ON ABOVE:
  # original C code: model.materials[0].maps[MATERIAL_MAP_DIFFUSE].texture = texture
  # MATERIAL_MAP_DIFFUSE is now ALBEDO (Raylib)
var position: Vector3 = (0.0, 0.0, 0.0) # set model position
var bounds: BoundingBox = getMeshBoundingBox(model.meshes[0]) # set model bounds
  # NOTE: bounds are calculated from the original size of the model,
  # if model is scaled on drawing, bounds must be also scaled

var selected = false # selected object flag

# Main Loop
while not windowShouldClose():

  # Update Camera
  camera.addr.updateCamera()

  # Load new models/textures on drag&drop
  if isFileDropped():
    var count: cint = 0
    var droppedFiles = getDroppedFiles(count.addr)

    if count == 1: # only support one file dropped
      # Model file formats supported
      if isFileExtension(fileName=droppedFiles[0], ext=".obj") or
        isFileExtension(fileName=droppedFiles[0], ext=".gltf") or
        isFileExtension(fileName=droppedFiles[0], ext=".iqm"):
          unloadModel(model) # unload previous model
          model = loadModel(droppedFiles[0]) # load new model
          model.materials[0].maps[MaterialMapIndex.Albedo.int].texture = texture # Set current map diffuse texture
          bounds = getMeshBoundingBox(model.meshes[0]) # set new model bounds
          # TODO: Move camera position from target enough distance to visualize model properly
      elif isFileExtension(droppedFiles[0],".png"): # Texture fil formats supported
        # unload current model texture and load new one
        unloadTexture(texture)
        texture = loadTexture(droppedFiles[0])
        model.materials[0].maps[MaterialMapIndex.Albedo.int].texture = texture

    clearDroppedFiles() # Clear internal buffers

  # Select model on mouse click
  if isMouseButtonPressed(MouseButton.Left):
    # Check collision between ray and box
    if getRayCollisionBox(getMouseRay(getMousePosition(),camera), bounds).hit:
      selected = not selected
    else:
      selected = false

  # Draw
  beginDrawing()
  clearBackground(Raywhite)
  beginMode3D(camera):
    drawModel(model, position, 1.0, White) # Draw 3d model with texture
    drawGrid(20,10.0) # Draw grid
    if selected: drawBoundingBox(bounds, Green) # Draw selection box
  endMode3D()
  drawText("Drag & drop model to load mesh/texture.", 10, getScreenHeight() - 20, 10, Darkgray)
  if selected:
    drawText("MODEL SELECTED", getScreenWidth() - 110, 10, 10, Green)
  drawText("Castle 3D Model", screenWidth - 200, screenHeight - 20, 10, Gray)
  drawFPS(10, 10)
  endDrawing()

# De-Initialization
unloadTexture(texture) # unload model texture
unloadModel(model) # unload model
closeWindow() # Close window and OpenGL context
