# NimraylibNow! - the Ultimate Raylib wrapper for Nim

The most idiomatic and up-to-date wrapper for [Raylib] gaming C library.
Use this library if you want to write games using Raylib in [Nim].

[Raylib]: https://www.raylib.com/
[Nim]: https://nim-lang.org/

## Features

* Automated generation of the wrapper for the latest version of Raylib using
  the power of (((Nim)))
* Idiomatic Nim naming so you write **Nim** code, not C
* Includes modules: raymath, rlgl, raygui
* Compiles raygui library for you
* Conversion script is included in the library, no manual work is required
  to update the bindings

## Install

tobedone

## How to use

tobedone

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
#define LIGHTGRAY  CLITERAL(Color){ 200, 200, 200, 255 }   // Light Gray
```
to
```nim
const Lightgray* = Color(r: 200, g: 200, b: 200, a: 255)
```

### C structs/Nim objects
Prefixes are stripped if any.

```c
typedef struct Vector2 {
    float x;
    float y;
} Vector2;
```
to
```nim
type
  Vector2* = object
    x*: float32
    y*: float32
```

Be careful when invoking fields which are also reserved words in Nim:
```nim
camera.`type` = CameraType.Perspective
```

### C enums/Nim enums
Prefixes are stripped if any, including prefixes for values themselves.

```c
typedef enum {
    FONT_DEFAULT = 0,       // Default font generation, anti-aliased
    FONT_BITMAP,            // Bitmap font generation, no anti-aliasing
    FONT_SDF                // SDF font generation, requires external shader
} FontType;
```
to
```nim
type
  FontType* {.pure.} = enum
    DEFAULT = 0,              ##  Default font generation, anti-aliased
    BITMAP,                   ##  Bitmap font generation, no anti-aliasing
    SDF                       ##  SDF font generation, requires external shader
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
from rlgl as rl import nil # to use a shorter `rl`
```

## How this works

There are 4 steps:

1. Get C header files
2. Modify C header files (preprocessing)
3. Run [c2nim] on modified C header files (processing)
4. Modify resulting Nim files (postprocessing)

[c2nim]: https://github.com/nim-lang/c2nim

## Develop

```shell
$ git clone --recurse-submodules --shallow-submodules <repository/path>
$ cd nimraylib_now
$ nimble install --depsOnly
$ nimble convert
$ nim r examples/original/basic.nim
```

## Thanks

Many thanks to V.A. Guevara for the efforts on [Raylib-Forever] library which
was the initial inspiration for this library.

[Raylib-Forever]: https://github.com/Guevara-chan/Raylib-Forever

## License

MIT licensed, see LICENSE.md.
