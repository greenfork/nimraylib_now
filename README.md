# NimraylibNow! - the Ultimate Raylib wrapper for Nim

The most idiomatic and up-to-date wrapper for [Raylib] gaming C library.
Use this library if you want to write games using [Raylib] in [Nim].

[Raylib]: https://www.raylib.com/
[Nim]: https://nim-lang.org/

## Features

* Automated generation of the wrapper for the latest version of Raylib using
  the power of (((Nim)))
* Idiomatic Nim naming so you write **Nim** code, not C
* A lot of examples converted to Nim
* Includes modules: raylib, raymath, rlgl, raygui
* Compiles raygui library for you
* Conversion script is included in the library, no manual work is required
  to update the bindings*

*_minor changes at most_

## Install

Install official [Raylib] library. For Arch Linux:
```shell
$ sudo pacman -Syu raylib
```

Install this library:
```shell
$ nimble install nimraylib_now
```

If you want to use [raygui] library, compile it:
```shell
$ git clone --recurse-submodules --shallow-submodules https://github.com/greenfork/nimraylib_now
$ cd nimraylib_now
$ nimble install --depsOnly
$ nimble buildRaygui # as it's not distributed as a dynamic library
# Run example, for Linux, LD_LIBRARY_PATH is set so that executable sees built raygui library
$ LD_LIBRARY_PATH=$(pwd) nim r examples/original/basic.nim
```

[raygui]: https://github.com/raysan5/raygui

## How to use

Here is a long example to showcase most features.
For more simple and narrow examples see [examples] folder.

[examples]: examples

```nim
import math
import nimraylib_now/raylib

const
  nimFg: Color = (0xff, 0xc2, 0x00) # use this shortcut with alpha = 255!
  nimBg: Color = (0x17, 0x18, 0x1f)

# Let's draw a Nim crown!
const
  crownSides = 8                             # low-polygon version
  centerAngle = 2.0 * PI / crownSides.float  # angle from the center of a circle
  lowerRadius = 2.0                          # lower crown circle
  upperRadius = lowerRadius * 1.4            # upper crown circle
  mainHeight = lowerRadius * 0.8             # height without teeth
  toothHeight = mainHeight * 1.3             # height with teeth
  toothSkew = 1.2                            # little angle for teeth

var
  lowerPoints, upperPoints: array[crownSides, tuple[x, y: float]]

# Get evenly spaced points on the lower and upper circles,
# use Nim's math module for that
for i in 0..<crownSides:
  let multiplier = i.float
  # Formulas are for 2D space, good enough for 3D since height is always same
  lowerPoints[i] = (
    lowerRadius * cos(centerAngle * multiplier),
    lowerRadius * sin(centerAngle * multiplier),
  )
  upperPoints[i] = (
    upperRadius * cos(centerAngle * multiplier),
    upperRadius * sin(centerAngle * multiplier),
  )

initWindow(800, 600, "[nim]RaylibNow!") # open window

var camera = Camera(
  position: (5.0, 8.0, 10.0),  # Camera position
  target: (0.0, 0.0, 0.0),     # Camera target it looks-at
  up: (0.0, 1.0, 0.0),         # Camera up vector (rotation over its axis)
  fovy: 45.0,                  # Camera field-of-view apperture in Y (degrees)
                               # in Perspective, used as near plane width
                               # in Orthographic
  `type`: Perspective          # Camera type, defines projection type:
                               # Perspective or Orthographic
)
camera.setCameraMode(Orbital)  # Several modes available, see CameraMode

setTargetFPS(60)

# Wait for Esc key press or when the window is closed
while not windowShouldClose():
  camera.addr.updateCamera     # rotate camera

  beginDrawing:                # use this sugar to insert endDrawing() automatically!
    clearBackground(RayWhite)  # set background color

    beginMode3D(camera):
      drawGrid(10, 1.0)

      for i in 0..<crownSides:
        # Define 5 points:
        # - Current lower circle point
        # - Current upper circle point
        # - Next lower circle point
        # - Next upper circle point
        # - Point for crown tooth
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
        drawLine3D(lowerCur, upperCur, fade(nimFg, 0.8))

        # Crown tooth front triangle (clockwise order)
        drawTriangle3D(upperCur, tooth, upperNext, nimFg)

        # Crown tooth back triangle (counter-clockwise order)
        drawTriangle3D(upperNext, tooth, upperCur, nimBg)

    block text:
      let verticalPos = (getScreenHeight().float * 0.5).int
      block:
        let
          text = "I AM NIM"
          fontSize = 60
          textWidth = measureText(text, fontSize)
        drawText(
          text,
          (getScreenWidth() - textWidth) div 2,  # center
          # Minus double `fontSize` for spacing for the next text
          (getScreenHeight() - fontSize - fontSize + verticalPos) div 2,
          fontSize,
          Black
        )
      block:
        let
          text = "OBEY"
          fontSize = 60
          textWidth = measureText(text, fontSize)
        drawText(
          text,
          (getScreenWidth() - textWidth) div 2,
          (getScreenHeight() + verticalPos) div 2,
          fontSize,
          Black
        )

closeWindow()
```

![](obey_nim.png?raw=true)

## Conversion and naming differences with C
Naming is converted to more Nim-pleasing style. Although some definitions in
this library's file may have names like `FULLSCREEN_MODE`, you can still use
them (and encouraged to) as `FullscreenMode` in code.

Generally just omit any prefixes you see in official docs and use camelCase for
procs, everything else stays the same.

### C types/Nim types
NimraylibNow! heavily uses native Nim types in the wrapper. This is mostly done
to avoid conversions to C types in code so we can write
```nim
const
  screenWidth = 800
  screenHeight = 640
```
instead of
```nim
const
  screenWidth = 800.cint
  screenHeight = 640.cint
```
Compiler should help you with warnings when conversion is not performed
implicitly. Mostly you will need to convert types to `int32`, `float32` and
`cstring` should the compiler shout at you.

### C #define/Nim const
Naming is same. `#define` directives are mostly skipped, exceptions include
colors and some top-level definitions which might be useful.

```c
#define LIGHTGRAY  CLITERAL(Color){ 200, 200, 200, 255 }
```
to
```nim
const Lightgray*: Color = (r: 200, g: 200, b: 200, a: 255)
```

### C structs/Nim objects and tuples
Most structs are converted to Nim objects. Prefixes are stripped if any.

Vector2, Vector3, Vector4 (Quaternion), Matrix, Rectangle, Color are better
fit as a tuple to save on typing as they have pretty much standard parameter
sequence:
```c
typedef struct Vector2 {
    float x;
    float y;
} Vector2;
```
to
```nim
type
  Vector2* = tuple
    x: float32
    y: float32

# All are valid:
var v1: Vector2 = (x: 3.0, y: 5.0)
var v2 = (x: 3.0, y: 5.0)
var v3 = (3f, 5f)

# Tuples can't be constructed as objects, following invalid:
var invalid = Vector2(x: 3.0, y: 5.0)

# But you can do this instead:
var valid = (x: 3.0, y: 5.0).Vector2
```

Be careful when invoking fields which are also reserved words in Nim:
```nim
camera.`type` = CameraType.Perspective
```

### C enums/Nim enums
Prefixes are stripped if any, including prefixes for values themselves.

```c
typedef enum {
    FONT_DEFAULT = 0,
    FONT_BITMAP,
    FONT_SDF
} FontType;
```
to
```nim
type
  FontType* {.pure.} = enum
    DEFAULT = 0,
    BITMAP,
    SDF
```

All enums are marked as `{.pure.}` which means they should be fully qualified
when compiler can't guess it:
```nim
camera.`type` = Perspective     # can be guessed
if isKeyDown(Right):            # can be guessed
if KeyboardKey.Right.isKeyDown: # cannot be guessed
```

In C enums are regular numbers and used in functions which accept `int` as
their arguments. Some arguments allow concatenating several values into a
single `int` e.g. `SetWindowState(WINDOW_MAXIMIZED | WINDOW_UNDECORATED);`.
For this reason they are not going to be type-checked but instead each have
their converter from enum type to appropriate int type which should allow
seamless interaction:
```nim
type MouseButton* {.pure.} = enum
  LEFT_BUTTON = 0, RIGHT_BUTTON = 1, MIDDLE_BUTTON = 2

proc isMouseButtonPressed*(button: int32): bool

converter MouseButtonToInt32*(self: MouseButton): int32 = self.int32
```

### C functions/Nim procs
Prefixes are stripped if any. Names are converted from PascalCase to camelCase:

```c
void InitWindow(int width, int height, const char *title);
void GuiSetState(int state);
void rlBegin(int mode);
```
to
```nim
proc initWindow*(width: int32; height: int32; title: cstring)
proc setState*(state: int32)
proc begin*(mode: int32)
```

For functions operating on global scope it could be convenient to use
fully qualified proc name:
```nim
rlgl.begin(rlgl.Triangles)
# draw something
rlgl.end()
```
which can be enforced by compiler by importing `rlgl` module like this:
```nim
from rlgl import nil

# or to use a shorter `rl`
from rlgl as rl import nil
```

## How this works

`nimble convert` runs `src/converter.nim` script and checks that the resulting
files are valid Nim files.

There are 4 steps during conversion:

1. Get C header files
2. Modify C header files (preprocessing)
3. Run [c2nim] on modified C header files (processing)
4. Modify resulting Nim files (postprocessing)

[c2nim]: https://github.com/nim-lang/c2nim

Since every step is done automatically, updating to the next version should
be a comparatively easy task.

## How to update this library

1. Do `git pull` for all git submodules (see `.gitmodules`), which are
   different Raylib libraries. Optionally checkout the needed commit version.
2. Run `nimble convert`

## Contribute

Any ideas are welcome. Open an issue to ask a question or tell a suggestion.

### Convert examples
There's a helper script to do that: `tools/example_converter.nim`. Compile it
and run from terminal with a C file as an argument, then edit the resulting
Nim file.

I cannot port a number of examples:
* `core_drop_files.c` - I can't test it on my machine (Wayland on Linux)
* `core_input_gamepad.c` - I don't have a gamepad
* `core_input_multitouch.c` - probably requires a phone to test it?
* `core_storage_values.c` - I can't compile the original C example, values
  are reset to 0,0 when I press Space
* `core_basic_window_web.c` - need emscripten dev tools

Also see examples in original libraries, you can port the missing ones.

## Thanks

Many thanks to V.A. Guevara for the efforts on [Raylib-Forever] library which
was the initial inspiration for this library.

[Raylib-Forever]: https://github.com/Guevara-chan/Raylib-Forever

Thanks to Nim community, it's very nice to get the answers to questions
rather quickly.

## License

MIT licensed, see LICENSE.md.
