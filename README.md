# NimraylibNow! - The Ultimate Raylib wrapper for Nim

The most idiomatic and up-to-date wrapper for [Raylib] gaming C library.
Use this library if you want to write games using [Raylib] in [Nim].

[Raylib]: https://www.raylib.com/
[Nim]: https://nim-lang.org/

## Features

* Automated generation of the wrapper for the latest version of Raylib using
  the power of (((Nim)))
* Idiomatic Nim naming and conventions so you write **Nim** code, not C
* A lot of examples converted to Nim
* Includes modules: raylib, raymath, rlgl, raygui
* Compiles raygui library for you (it is not distributed as dll)
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

Import any necessary modules and use it!

```nim
import nimraylib_now/raylib
import nimraylib_now/[raylib, raymath, raygui]
from nimraylib_now/rlgl as rl import nil  # import rlgl with a mandatory prefix rl
```

Here is a long example to showcase most features
([crown](examples/original/crown.nim)). For more simple and narrow examples see
[examples](examples/) directory.

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

var pause = false

setTargetFPS(60)

# Wait for Esc key press or when the window is closed
while not windowShouldClose():
  if not pause:
    camera.addr.updateCamera   # rotate camera

  if isKeyPressed(Space):
    pause = not pause

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

![](crown.png?raw=true)

## Conversion and naming differences with C
Naming is converted to more Nim-pleasing style. Although some definitions in
this library's file may have names like `FULLSCREEN_MODE`, you can still use
them (and encouraged to) as `FullscreenMode` in code.

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

### Enums
Enums are not type-checked but instead each have their converter from enum type
to appropriate int type which should allow seamless interaction:
```nim
type MouseButton* {.pure.} = enum
  LeftButton = 0, RightButton = 1, MiddleButton = 2

converter MouseButtonToInt*(self: MouseButton): cint = self.cint

proc isMouseButtonPressed*(button: cint): bool
```

Prefixes are stripped for enum values too. All enums are marked as `{.pure.}`
which means they should be fully qualified when compiler can't guess their type:
```nim
camera.`type` = Perspective      # can be guessed
if isKeyDown(Right):             # can be guessed
if KeyboardKey.Right.isKeyDown:  # cannot be guessed
```

### Reserved words
Be careful when invoking fields which are also reserved words in Nim:
```nim
camera.`type` = CameraType.Perspective
```

### Passing values by addresses
**BE VERY CAREFUL** with values which are passed as addresses, **always** convert
them to approapriate C-compatible types:
```nim
# Will do incorrect things!
var
  xPos = 0.0  # this is `float`, will not be converted to cfloat automatically
  cameraPos = [xPos, camera.position.y, camera.position.z]
setShaderValue(shader, viewEyeLoc, cameraPos.addr, Vec3) # cameraPos.addr is a pointer

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

## How wrapping works

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
3. Run `nimble testExamples` and fix everything if necessary

## Contribute

Any ideas are welcome. Open an issue to ask a question or suggest an idea.

### Convert examples
You can help by converting missing examples from original C library doing
the following:
1. Find a missing example in C.
2. Compile and run `tools/c2nim_example_converter.nim` on this C file, it helps
   with conversion.
3. Edit resulting Nim file, make sure it runs.
4. Put this file into a correct category in `examples` (`original` is for
   self-developed examples).
5. Compile and run `tools/make_tests_from_examples.nim` without any arguments,
   it should create a test file in `tests/examples/yourcategory`.
6. Run `nimble testExamples` and make sure that your example passes the test.
   If it doesn't pass the test, create an issue or ask me any other way, I will
   help.

I cannot port a number of examples:
* `core_drop_files.c` - I can't test it on my machine (Wayland on Linux)
* `core_input_gamepad.c` - I don't have a gamepad
* `core_input_multitouch.c` - probably requires a phone to test it?
* `core_storage_values.c` - I can't compile the original C example, values
  are reset to 0,0 when I press Space
* `core_basic_window_web.c` - need emscripten dev tools

Also see examples in original libraries, you can port the missing ones.

### Work on converter script
If something is broken or you see an opportunity to improve the wrapper, you
can help with converter script.

Clone and run tests:

```shell
$ git clone --recurse-submodules --shallow-submodules https://github.com/greenfork/nimraylib_now
$ cd nimraylib_now
$ nimble install --depsOnly
$ nimble convert
$ nimble testExamples
```

Then workflow is as follows:
1. Change `src/converter.nim` file
2. Run `nimble convert` and see if you achieved desired changes
3. Run `nimble testExamples` to see that all examples are still compiled

## Thanks

Many thanks to V.A. Guevara for the efforts on [Raylib-Forever] library which
was the initial inspiration for this library.

[Raylib-Forever]: https://github.com/Guevara-chan/Raylib-Forever

Thanks to Nim community, it's very nice to get the answers to questions
rather quickly.

## License

MIT licensed, see LICENSE.md.
