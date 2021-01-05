# -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- #
# Raylib Forever basic usage sample
# Developed in 2*20 by Guevara-chan
# -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- #
import lenientops, raylib, raygui
InitWindow 800, 600, "RayLib/[nim]"
60.SetTargetFPS


# Camera setup.
var camera = Camera(position: Vector3(z: -15.0f, y: 10), up: Vector3(y: 0.5), fovy: 45.0)
camera.SetCameraMode CAMERA_ORBITAL

# ==Main code==
while not WindowShouldClose():
    camera.addr.UpdateCamera
    BeginDrawing()
    GuiLabel Rectangle(x: 10, y: 0, width: 100, height: 25), "by V.A. Guevara"
    BLACK.ClearBackground
    BeginMode3D(camera)
    DrawGrid 10, 1.0f
    DrawSphere Vector3(), 0.5f, RED
    EndMode3D()
    let 
        (slogan, size) = ("/Hello from Nim/", 20)
        width          = MeasureText(slogan, size)
    slogan.DrawText (GetScreenWidth() - width) div 2, GetScreenHeight() div 2 - 100, size, LIGHTGRAY
    DrawRectangleV Vector2(x: 10, y: 10), Vector2(x:GetScreenWidth()-20.0, y:GetScreenHeight()-20.0), Color(r:255, a:20)
    EndDrawing()
