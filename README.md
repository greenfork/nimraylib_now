# nimraylib_now - the Ultimate Raylib wrapper

Tries to be most idiomatic and up-to-date wrapper for [Raylib] gaming library.

[Raylib]: https://www.raylib.com/

## C types/Nim types
nimraylib_now heavily uses native Nim types in the wrapper. This is mostly done
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

### Enums
In C enums are regular numbers and used in functions which accept `int` as
their arguments. Some arguments allow concatenating several values into a
single `int` e.g. `SetWindowState(WINDOW_MAXIMIZED | WINDOW_UNDECORATED);`.
For this reason they are not going to be type-checked but instead each have
their converter from enum type to appropriate int type which should allow
seamless interaction:
```nim
type MouseButton* {.size: sizeof(int32), pure.} = enum
  LEFT_BUTTON = 0, RIGHT_BUTTON = 1, MIDDLE_BUTTON = 2
proc isMouseButtonPressed*(button: int32): bool {.cdecl,
    importc: "IsMouseButtonPressed", dynlib: raylibdll.}
converter MouseButtonToInt32*(self: MouseButton): int32 = self.int32
```

## Naming differences with C
Naming is converted to more Nim-pleasing style. Although some definitions in
this library's file may have names like `FULLSCREEN_MODE`, you can still use
them (and encouraged to) as `FullscreenMode` in code.

### C #define/Nim const
Naming is same. `#define` directives are mostly skipped, exceptions include
colors and some top-level definitions which might be useful.

### C structs/Nim objects
Prefixes are stripped if any. Be careful when invoking fields which are also
reserved words in Nim:
```nim
camera.`type` = CameraType.Perspective
```

### C enums/Nim enums
Prefixes are stripped if any, including prefixes for values themselves. All
enums are marked as `{.pure.}` which means it should be fully qualified when
compiler can't guess it.
```nim
camera.`type` = Perspective     # can be guessed
if isKeyDown(Right):            # can be guessed
if KeyboardKey.Right.isKeyDown: # cannot be guessed
```

### C functions/Nim procs
Prefixes are stripped if any. Names are converted from PascalCase to camelCase.
```
rlBegin -> begin
GuiSetState -> setState
InitWindow -> initWindow
```

For functions operating on global scope it could be convenient to use
fully qualified proc name:
```nim
rlgl.begin(rlgl.Triangles)
# draw anything
rlgl.end()
```
which can be enforced by compiler by importing it like this:
```nim
from rlgl import nil
```

## Develop

```shell
$ git clone --recurse-submodules --shallow-submodules <repository/path>
$ cd nimraylib_now
$ nimble install --depsOnly
$ nimble convert
$ nim r examples/original/basic.nim
```
