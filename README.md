# NimraylibNow! - The Ultimate Raylib wrapper for Nim

The most idiomatic and up-to-date wrapper for [Raylib] gaming C library.
Use this library if you want to write games using [Raylib] in [Nim].

This library is an effort to create an automatically generated wrapper which can
be easily upgraded to any future version of [Raylib]. Anyone should be able to
upgrade it with some effort and [HACKING](HACKING.md) should be a guide on how
to do it. Please file a bug report if any of that is too far from the reality.


[Nim]: https://nim-lang.org/

## Features

* Automated generation of the wrapper for the latest version of Raylib using
  the power of (((Nim)))
* Idiomatic Nim naming and conventions so you write **Nim** code, not C
* 60+ [examples](examples/) converted from C to Nim
* Includes modules: [raylib], [raymath], [rlgl], [raygui], [physac]
* Conversion script is included in the library, no manual work is required
  to update the bindings*

*_minor changes at most_

[raylib]: https://github.com/raysan5/raylib
[raymath]: https://github.com/raysan5/raylib/blob/master/src/raymath.h
[rlgl]: https://github.com/raysan5/raylib/blob/master/src/rlgl.h
[raygui]: https://github.com/raysan5/raygui
[physac]: https://github.com/raysan5/raylib/blob/master/src/physac.h

## Contributing

Do you want to contribute but don't know how? Check out [CONTRIBUTING](CONTRIBUTING.md)!

## How does it work?

If you would like to know how it works or how to update it, check out [HACKING](HACKING.md).

## Current version and upgrading from previous versions

This is a wrapper for [Raylib v3.7.0].

See [MIGRATION](MIGRATION.md) for any tips on how to upgrade your code.
There are not a lot of possibilities to use proper deprecation warnings
since it is not always possible to translate `#define` declarations from C.
Sadly upgrades of user code is a necessary part of migration. On the bright
side it should mainly consist of renaming, please try they wonderful tool
`nimgrep`, it is shipped with Nim and has a useful "replace" functionality.

[Raylib v3.7.0]: https://github.com/raysan5/raylib/releases/tag/3.7.0

## Install Raylib
### Windows
Download latest library from [raylib releases] page for MinGW compiler, for version 3.7.0
the name is `raylib-3.7.0_win64_mingw-w64.zip`. Extract it and **make sure**
that files `libraylibdll.a` and `raylib.dll` are always in the same directory
as your game `.exe` file.

### Linux
Use your package manager, for example for Arch Linux:
```shell
$ sudo pacman -Syu raylib
```

Alternatively download latest library from [raylib releases] page, for version 3.7.0
the name is `raylib-3.7.0_linux_amd64.tar.gz`. Extract it and put all `.so`
files into `/usr/local/lib`.

### MacOS
With brew package manager:
```shell
$ brew install raylib
```

Alternatively download latest library from [raylib releases] page, for version 3.7.0
the name is `raylib-3.7.0_macos.tar.gz`. Extract it and put all `.dylib`
files into `/usr/local/lib`.

## Install NimraylibNow!
Install this library with nimble (takes **6-10(!) minutes** because of huge
original raylib repository):
```shell
$ nimble install nimraylib_now
```

Or put it into your `.nimble` file:
```nim
requires "nimraylib_now"
```

[raylib releases]: https://github.com/raysan5/raylib/releases

## How to use

Import any necessary modules and use it:

```nim
import nimraylib_now/raylib
import nimraylib_now/[raylib, raymath, raygui]
from nimraylib_now/rlgl as rl import nil  # import rlgl with a mandatory prefix rl
```

See [examples](examples/) for how to use it.
You should generally be able to follow any tutorials for official C bindings,
just mind the [naming](#naming-differences-with-c). Also see official
[cheatsheet](https://www.raylib.com/cheatsheet/cheatsheet.html) and
directly inspect the binding sources, e.g. for
[raylib](src/nimraylib_now/raylib.nim).

Here is a long example to showcase most features
([crown.nim](examples/original/crown.nim)).

```nim
import math
import nimraylib_now/raylib

const
  nimFg: Color = (0xff, 0xc2, 0x00)          # Use this shortcut with alpha = 255!
  nimBg: Color = (0x17, 0x18, 0x1f)

# Let's draw a Nim crown!
const
  crownSides = 8                             # Low-polygon version
  centerAngle = 2.0 * PI / crownSides.float  # Angle from the center of a circle
  lowerRadius = 2.0                          # Lower crown circle
  upperRadius = lowerRadius * 1.4            # Upper crown circle
  mainHeight = lowerRadius * 0.8             # Height without teeth
  toothHeight = mainHeight * 1.3             # Height with teeth
  toothSkew = 1.2                            # Little angle for teeth

var
  lowerPoints, upperPoints: array[crownSides, tuple[x, y: float]]

# Get evenly spaced points on the lower and upper circles,
# use Nim's math module for that
for i in 0..<crownSides:
  let multiplier = i.float
  # Formulas are for 2D space, good enough for 3D since height is always same
  lowerPoints[i] = (
    x: lowerRadius * cos(centerAngle * multiplier),
    y: lowerRadius * sin(centerAngle * multiplier),
  )
  upperPoints[i] = (
    x: upperRadius * cos(centerAngle * multiplier),
    y: upperRadius * sin(centerAngle * multiplier),
  )

initWindow(800, 600, "[nim]RaylibNow!")  # Open window

var camera = Camera(
  position: (5.0, 8.0, 10.0),  # Camera position
  target: (0.0, 0.0, 0.0),     # Camera target it looks-at
  up: (0.0, 1.0, 0.0),         # Camera up vector (rotation over its axis)
  fovy: 45.0,                  # Camera field-of-view apperture in Y (degrees)
  projection: Perspective      # Defines projection type, see CameraProjection
)
camera.setCameraMode(Orbital)  # Several modes available, see CameraMode

var pause = false              # Pausing the game will stop animation

setTargetFPS(60)               # Set the game to run at 60 frames per second

# Wait for Esc key press or when the window is closed
while not windowShouldClose():
  if not pause:
    camera.addr.updateCamera   # Rotate camera

  if isKeyPressed(Space):      # Pressing Space will stop/resume animation
    pause = not pause

  beginDrawing:                # Use drawing functions inside this block
    clearBackground(RayWhite)  # Set background color

    beginMode3D(camera):       # Use 3D drawing functions inside this block
      drawGrid(10, 1.0)

      for i in 0..<crownSides:
        # Define 5 points:
        # - Current lower circle point
        # - Current upper circle point
        # - Next lower circle point
        # - Next upper circle point
        # - Point for peak of crown tooth
        let
          nexti = if i == crownSides - 1: 0 else: i + 1
          lowerCur: Vector3 = (lowerPoints[i].x, 0.0, lowerPoints[i].y)
          upperCur: Vector3 = (upperPoints[i].x, mainHeight, upperPoints[i].y)
          lowerNext: Vector3 = (lowerPoints[nexti].x, 0.0, lowerPoints[nexti].y)
          upperNext: Vector3 = (upperPoints[nexti].x, mainHeight, upperPoints[nexti].y)
          tooth: Vector3 = (
            (upperCur.x + upperNext.x) / 2.0 * toothSkew,
            toothHeight,
            (upperCur.z + upperNext.z) / 2.0 * toothSkew
          )

        # Front polygon (clockwise order)
        drawTriangle3D(lowerCur, upperCur, upperNext, nimFg)
        drawTriangle3D(lowerCur, upperNext, lowerNext, nimFg)

        # Back polygon (counter-clockwise order)
        drawTriangle3D(lowerCur, upperNext, upperCur, nimBg)
        drawTriangle3D(lowerCur, lowerNext, upperNext, nimBg)

        # Wire line for polygons
        drawLine3D(lowerCur, upperCur, Gray)

        # Crown tooth front triangle (clockwise order)
        drawTriangle3D(upperCur, tooth, upperNext, nimFg)

        # Crown tooth back triangle (counter-clockwise order)
        drawTriangle3D(upperNext, tooth, upperCur, nimBg)

    block text:
      block:
        let
          text = "I AM NIM"
          fontSize = 60
          textWidth = measureText(text, fontSize)
          verticalPos = (getScreenHeight().float * 0.4).int
        drawText(
          text,
          (getScreenWidth() - textWidth) div 2,  # center
          (getScreenHeight() + verticalPos) div 2,
          fontSize,
          Black
        )
      block:
        let text =
          if pause: "Press Space to continue"
          else: "Press Space to pause"
        drawText(text, 10, 10, 20, Black)

closeWindow()
```

![Nim crown drawn with polygons](crown.png?raw=true)

## Naming differences with C
Naming is converted to more Nim conventional style but in a predictable manner.
Generally just omit any prefixes you see in official docs and use camelCase for
procs, everything else stays the same:
```c
void InitWindow(int width, int height, const char *title);
void GuiSetState(int state);
void rlBegin(int mode);
```
to
```nim
proc initWindow*(width: cint; height: cint; title: cstring)
proc setState*(state: cint)
proc begin*(mode: cint)
```

Although some definitions may have names like `FULLSCREEN_MODE`, you can still
use them (and encouraged to) as `FullscreenMode` in code.

### Raymath

All prefixes specific to types were omitted where possible:
```c
Vector2 Vector2Zero(void)
Vector3 Vector3Zero(void)

Vector2 Vector2Add(Vector2 v1, Vector2 v2)
Vector3 Vector3Add(Vector3 v1, Vector3 v2)
```
to
```nim
proc vector2Zero*(): Vector2
proc vector3Zero*(): Vector3

proc add*(v1: Vector2; v2: Vector2): Vector2
proc add*(v1: Vector3; v2: Vector3): Vector3
```

## Passing values by addresses
**BE VERY CAREFUL** with values which are passed as addresses, **always** convert
them to approapriate C-compatible types:
```nim
# Will do incorrect things!
var
  xPos = 0.0  # this is `float` type, will not be converted to `cfloat` automatically
  cameraPos = [xPos, camera.position.y, camera.position.z]
setShaderValue(shader, viewEyeLoc, cameraPos.addr, Vec3)  # cameraPos.addr is a pointer

# Convert values instead
var xPos: cfloat = 0.0
# or
var cameraPos = [xPos.cfloat, camera.position.y, camera.position.z]
# So this finally works as intended:
setShaderValue(shader, viewEyeLoc, cameraPos.addr, Vec3)
```

## Tips and tricks
### Tuple to object converters for geometry
Vector2, Vector3, Vector4 (Quaternion), Matrix, Rectangle, Color can be written
as a tuple to save on typing as they have pretty much standard parameter
sequence:

```nim
# All are valid:
var
  v1: Vector2 = (x: 3.0, y: 5.0)
  v2 = Vector2(x: 3.0, y: 5.0)
  v3 = (3.0, 5.0)
  c: Color = (0xc9, 0xc9, 0xc9)  # color can be written as a tuple even without the alpha value!
```

### Require fully qualified procs
For functions operating on global scope it could be convenient to use
fully qualified proc name:
```nim
rlgl.begin(rlgl.Triangles)
# draw something
rlgl.end()
```
which can be enforced by compiler by importing `rlgl` module like this:
```nim
from nimraylib_now/rlgl import nil

# or to use a shorter `rl`
from nimraylib_now/rlgl as rl import nil
```

### Begin-End pairs sugar
There are pairs like `beginDrawing()` - `endDrawing()`, each have helping
templates to automatically insert `end`-proc at the end:
```nim
beginDrawing:
  drawLine(...)
```
is same as
```nim
beginDrawing()
drawLine(...)
endDrawing()
```

### Reserved words
Be careful when using fields or functions which are also reserved words in Nim:
```nim
camera.projection = CameraProjection.Perspective
```

### Enums
All enums are marked as `{.pure.}` which means they should be fully qualified
when compiler can't guess their type:
```nim
camera.projection = Perspective  # can be guessed, no need for CameraProjection.Perspective
if isKeyDown(Right):             # can be guessed, no need for KeyboardKey.Right
if KeyboardKey.Right.isKeyDown:  # cannot be guessed
```

### Raymath infix operators
You can use infix operators like `+`, `-`, `*`, `/` for operations on vectors,
matrices and quaternions:
```nim
let
  v1 = Vector3(x: 5, y: 2, z: 1)
  v2 = Vector3(x: 3, y: 0, z: 0)
assert v1 - v2 == Vector3(x: 2.0, y: 2.0, z: 1.0)
```

## Troubleshooting
### Freezes on Wayland
Random freezes when everything stops being responsive can be caused by glfw
compiled against Wayland library. Try X11 version of glfw.

[GLFW] is a raylib dependency that was installed by your package manager, you
can uninstall raylib with clearing all of its dependencies and install it again
choosing X11 version of glfw.

[GLFW]: https://www.glfw.org/

### Windows error: The application was unable to start correctly (0x00000007b)
Or similar errors which point to missing `libwinpthread-1.dll` file mean that
you do not have path set correctly and MinGW can't find correct library files.

Make sure to include MinGW's bin folder in your PATH. The path to MinGW's bin
folder looks something like this by default:
`C:\Program Files\mingw-w64\x86_64-8.1.0-posix-seh-rt_v6-rev0\mingw64\bin`.

## Thanks

Many thanks to V.A. Guevara for the efforts on [Raylib-Forever] library which
was the initial inspiration for this library.

[Raylib-Forever]: https://github.com/Guevara-chan/Raylib-Forever

Thanks to everyone who contributed to this project!

## License

MIT licensed, see LICENSE.md.
