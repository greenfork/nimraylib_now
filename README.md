# NimraylibNow! - The Ultimate Raylib wrapper for Nim

The most idiomatic and up-to-date wrapper for [Raylib] gaming C library.
Use this library if you want to write games using [Raylib] in [Nim].

This library is an effort to create an automatically generated wrapper which can
be easily upgraded to any future version of [Raylib]. Anyone should be able to
upgrade it with some effort and [HACKING](HACKING.md) should be a guide on how
to do it. Please file a bug report if any of that is too far from the reality.

[Nim]: https://nim-lang.org/

## Features

* Automated generation of the wrapper using the power of (((Nim)))

* Idiomatic Nim naming and conventions so you write **Nim** code, not C

* 60+ [examples](examples/) converted from C to Nim

* Includes modules: [raylib], [raymath], [rlgl], [raygui], [physac]

* Supports Windows, Linux, MacOS, Emscripten (see [Emscripten example])

* Supports static compilation, dynamic linking - you choose

[raylib]: https://github.com/raysan5/raylib
[raymath]: https://github.com/raysan5/raylib/blob/master/src/raymath.h
[rlgl]: https://github.com/raysan5/raylib/blob/master/src/rlgl.h
[raygui]: https://github.com/raysan5/raygui
[physac]: https://github.com/raysan5/raylib/blob/master/src/physac.h
[Emscripten example]: examples/emscripten/

## Quickstart

1. Install NimraylibNow!
```shell
$ nimble install nimraylib_now  # wait 10 minutes for download, sorry
```
2. Copy any example to your file, for instance [crown.nim](examples/original/crown.nim)
3. Compile and run it:
```shell
$ nim c -r -d:release --gc:orc crown.nim
```

Explanation of flags:
- `-r` - run after compiling
- `-d:release` - for speed, but also cuts away debugging information
- `--gc:orc` - memory management without garbage collection and
  with better C interoperability

## Current version and upgrading from previous versions

NimraylibNow! v0.14 is a wrapper for [Raylib v4.0.0] and [Raygui v3.0].

See [CHANGELOG](CHANGELOG.md) for any tips on how to upgrade your code
from previous versions.

[Raylib v4.0.0]: https://github.com/raysan5/raylib/releases/tag/4.0.0
[Raygui v3.0]: https://github.com/raysan5/raygui/releases/tag/3.0

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

## How to use NimraylibNow!

Import any necessary modules and use it:

```nim
# Import everything but rlgl, should be enough for most cases!
import nimraylib_now

# Import only necessary modules for more granularity
import nimraylib_now/raylib
import nimraylib_now/[raylib, raymath, raygui]
from nimraylib_now/rlgl as rl import nil  # import rlgl with a mandatory prefix rl
```

See [examples](examples/) for how to use it.
You should generally be able to follow any tutorials for official C bindings,
just mind the [naming](#naming-differences-with-c). Also see official
[cheatsheet](https://www.raylib.com/cheatsheet/cheatsheet.html) and
directly inspect the binding sources, e.g. for
[raylib](src/nimraylib_now/not_mangled/raylib.nim).

Here is a long example to showcase most features
([crown.nim](examples/original/crown.nim)).

```nim
import math
import nimraylib_now

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
Vector2 Vector2Zero(void);
Vector3 Vector3Zero(void);

Vector2 Vector2Add(Vector2 v1, Vector2 v2);
Vector3 Vector3Add(Vector3 v1, Vector3 v2);
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
which can be enforced by the compiler by importing `rlgl` module like this:
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
Be careful and use "stropping" when using fields or functions which are also
reserved words in Nim:
```nim
`end`()
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

## Raylib, the original C library

If you would like to know more about how this wrapper uses [Raylib] library
and see all the different options, check [USING_RAYLIB](/USING_RAYLIB.md),
it should help.

## Contributing

Do you want to contribute but don't know how? Check out
[CONTRIBUTING](CONTRIBUTING.md)!

## How does wrapper work?

If you would like to know how this wrapper works or how to update it, check
out [HACKING](HACKING.md).

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
windows can't find correct library files.

This is because, by default, nim creates binaries that are dynamically linked.
Normally, this is fine since windows already has the libraries required for most
basic nim applications. It does not however have libwinpthread-1.dll, which causes an error here.
We can solve this by instructing nim to create binaries with the libraries 
linked statically.

To do this just pass in the `--passL:-static` to nim when compiling your file.

If you still want dynamic linking:

- If minGW is not in PATH
- Add nim's minGW toolchain to your PATH (You have to add the bin directory with .dll files not the one where nim.exe is located)

If you already a version of minGW (that is already on PATH and seperate from nim)
- Copy over `libwinpthread-1.dll` from nim's version of minGW into the bin directory of your version of minGW

## Community

Find us at `#raylib-nim` channel
in the official [Raylib discord server](https://discord.gg/raylib).

## Thanks

Many thanks to V.A. Guevara for the efforts on [Raylib-Forever] library which
was the initial inspiration for this library.

[Raylib-Forever]: https://github.com/Guevara-chan/Raylib-Forever

Thanks to everyone who contributed to this project!

## License

MIT licensed, see LICENSE.md.
